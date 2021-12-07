public enum DataWriterBFEnum implements IndexingInterface
{
    DEFAULT (0, "Default"),
    CUSTOM (1, "Custom"),
    NONE (2, "None");

    private int index;
    private String label;

    DataWriterBFEnum(int _index, String _label) {
        this.index = _index;
        this.label = _label;
    }

    @Override
    public String getString() {
        return label;
    }

    @Override
    public int getIndex() {
        return index;
    }

    public boolean getIsDefaultLocation() {
        return label.equals("Default");
    }

    public boolean getIsCustomLocation() {
        return label.equals("Custom");
    }

    public boolean getIsTurnedOff() {
        return label.equals("None");
    }
}

public class DataWriterBF {
    private String folderPath = "";
    private String folderName = "";
    private StringBuilder fileName = null;
    private final String brainflowWriteOption = "w";
    private int fileNumber = 0;

    //variation on constructor to have custom name
    DataWriterBF() {
        
    }

    public void setBrainFlowStreamerFileName(String _folderName, String _folderPath) {
        //settings.setSessionPath(directoryManager.getRecordingsPath() + "OpenBCISession_" + _sessionName + File.separator);
        folderName = _folderName;
        folderPath = _folderPath;

        if (folderName == null || folderPath == null) {
            println("Error setting BrainFlow Streamer file output path. Try selecting the custom path again.");
            fileName = null;
            return;
        }

        fileName = new StringBuilder(folderPath);
        fileName.append(File.separator);
        fileName.append("BrainFlow-RAW_");
        fileName.append(folderName);
        if (fileNumber > 0) {
            fileName.append("_");
            fileName.append(fileNumber);
        }
        fileName.append(".csv");
        //println(fileName.toString());
    }

    public void incrementBrainFlowStreamerRecordingNumber() {
        fileNumber++;
    }

    public void resetBrainFlowStreamerRecordingNumber() {
        fileNumber = 0;
    }

    public String getBrainFlowStreamerRecordingFileName() {
        return fileName == null ? null : fileName.toString();
    }
}

//Called when user selects a folder from controlPanel dialog box
void bfSelectedFolder(File selection) {

    if (selection == null) {
        outputError("BrainFlow File Streamer: Window was closed or the user hit cancel. Please select a new file location or choose Default.");
        dataLogger.setBfWriterFolder(null, null);
        return;
    }

    println("DataLogging: bfSelectedFolder: User selected " + selection.getAbsolutePath());

    dataLogger.setBfWriterFolder(selection.getName(), selection.getAbsolutePath());
}