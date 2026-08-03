import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Immutable description of the processing pipeline used for one filtered
 * recording epoch.  A new epoch is opened whenever this description changes.
 */
class FilteredDataMetadata {
    public final int sampleRate;
    public final String boardClass;
    public final String guiVersion;
    public final String brainFlowVersion;
    public final boolean smoothingActive;
    public final String filterConfigurationJson;
    public final String configurationSha256;

    FilteredDataMetadata(
        int _sampleRate,
        String _boardClass,
        String _guiVersion,
        String _brainFlowVersion,
        boolean _smoothingActive,
        String _filterConfigurationJson
    ) {
        sampleRate = _sampleRate;
        boardClass = _boardClass;
        guiVersion = _guiVersion;
        brainFlowVersion = _brainFlowVersion;
        smoothingActive = _smoothingActive;

        Gson gson = new Gson();
        filterConfigurationJson = gson.toJson(
            new JsonParser().parse(_filterConfigurationJson)
        );

        StringBuilder fingerprint = new StringBuilder();
        fingerprint.append("sampleRate=").append(sampleRate).append('\n');
        fingerprint.append("boardClass=").append(boardClass).append('\n');
        fingerprint.append("guiVersion=").append(guiVersion).append('\n');
        fingerprint.append("brainFlowVersion=").append(brainFlowVersion).append('\n');
        fingerprint.append("smoothingActive=").append(smoothingActive).append('\n');
        fingerprint.append("pipeline=bandstop,bandpass,environmental-notch").append('\n');
        fingerprint.append("precision=float32").append('\n');
        fingerprint.append(filterConfigurationJson);
        configurationSha256 = sha256(fingerprint.toString());
    }

    private String sha256(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] encoded = digest.digest(value.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (byte b : encoded) {
                hex.append(String.format("%02x", b & 0xff));
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 is not available.", e);
        }
    }
}

/**
 * Writes only filtered EXG values to a companion OpenBCI text file.  The raw
 * writer and raw file format remain unchanged for playback compatibility.
 */
class DataWriterFilteredODF {
    private PrintWriter output;
    private String fileName;
    private long rowsWritten;
    private DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
    private FilteredDataSequence sequence;

    DataWriterFilteredODF(
        String sessionPath,
        String rawFileName,
        String recordingName,
        int epochNumber,
        long firstSampleIndex,
        FilteredDataMetadata metadata
    ) {
        String epochSuffix = String.format("-epoch-%03d", epochNumber);
        fileName = sessionPath + "OpenBCI-FILTERED-" + recordingName + epochSuffix + ".txt";
        output = createWriter(fileName);
        sequence = new FilteredDataSequence(firstSampleIndex);
        rowsWritten = 0;
        writeHeader(rawFileName, firstSampleIndex, metadata);
    }

    private void writeHeader(
        String rawFileName,
        long firstSampleIndex,
        FilteredDataMetadata metadata
    ) {
        output.println("%OpenBCI Filtered EXG Data");
        output.println("%Schema = openbci-filtered-timeseries/1");
        output.println("%Source Raw File = " + new File(rawFileName).getName());
        output.println("%First Sample Index = " + firstSampleIndex);
        output.println("%Number of channels = " + currentBoard.getNumEXGChannels());
        output.println("%Sample Rate = " + metadata.sampleRate + " Hz");
        output.println("%Board = " + metadata.boardClass);
        output.println("%OpenBCI GUI Version = " + metadata.guiVersion);
        output.println("%BrainFlow Version = " + metadata.brainFlowVersion);
        output.println("%Board Smoothing Active = " + metadata.smoothingActive);
        output.println("%Display Pipeline Precision = float32");
        output.println("%Filter Pipeline = BandStop -> BandPass -> Environmental Notch");
        output.println("%Filter Configuration SHA-256 = " + metadata.configurationSha256);
        output.println("%Filter Configuration JSON = " + metadata.filterConfigurationJson);

        output.print("Sample Index, ");
        int[] exgChannels = currentBoard.getEXGChannels();
        String[] channelNames = ((Board)currentBoard).getChannelNames();
        for (int i = 0; i < exgChannels.length; i++) {
            output.print("Filtered " + channelNames[exgChannels[i]] + ", ");
        }
        output.println("Timestamp, Marker, Timestamp (Formatted)");
    }

    /**
     * Append the filtered tail that corresponds exactly to rawFrameData.
     * Returns the number of samples written.
     */
    public int append(
        float[][] filteredDisplayData,
        double[][] rawFrameData,
        long firstSampleIndex
    ) {
        int[] exgChannels = currentBoard.getEXGChannels();
        if (exgChannels.length == 0 || rawFrameData.length == 0) {
            return 0;
        }

        int sampleCount = rawFrameData[exgChannels[0]].length;
        if (sampleCount == 0) {
            return 0;
        }
        if (filteredDisplayData.length != exgChannels.length) {
            throw new IllegalArgumentException("Filtered EXG channel count does not match the board.");
        }

        int filteredStart = filteredDisplayData[0].length - sampleCount;
        if (filteredStart < 0) {
            throw new IllegalArgumentException("Filtered display buffer is shorter than the raw frame.");
        }

        sequence.accept(firstSampleIndex, sampleCount);
        int timestampChannel = currentBoard.getTimestampChannel();
        int markerChannel = currentBoard.getMarkerChannel();

        for (int iSample = 0; iSample < sampleCount; iSample++) {
            StringBuilder row = new StringBuilder();
            row.append(firstSampleIndex + iSample).append(", ");
            for (int iChannel = 0; iChannel < exgChannels.length; iChannel++) {
                row.append(filteredDisplayData[iChannel][filteredStart + iSample]).append(", ");
            }

            double timestamp = rawFrameData[timestampChannel][iSample];
            double marker = rawFrameData[markerChannel][iSample];
            row.append(timestamp).append(", ");
            row.append(marker).append(", ");
            row.append(dateFormat.format(new Date((long)(timestamp * 1000.0))));
            output.println(row.toString());
            rowsWritten++;
        }
        return sampleCount;
    }

    public void closeFile() {
        output.flush();
        output.close();
    }

    public String getFileName() {
        return fileName;
    }

    public long getRowsWritten() {
        return rowsWritten;
    }
}
