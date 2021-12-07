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
    private final String brainflowWriteOption = ":w";
    private int fileNumber = 0;

    //variation on constructor to have custom name
    DataWriterBF() {
        
    }

    public void setBrainFlowStreamerFolderName(String _folderName, String _folderPath) {
        //settings.setSessionPath(directoryManager.getRecordingsPath() + "OpenBCISession_" + _sessionName + File.separator);
        folderName = _folderName;
        folderPath = _folderPath;

        if (folderName == null || folderPath == null) {
            println("Error setting BrainFlow Streamer file output path. Try selecting the custom path again.");
            fileName = null;
            return;
        }

        generateBrainFlowStreamerFileName();
    }
    
    private void generateBrainFlowStreamerFileName() {
        fileName = new StringBuilder("file://");
        fileName.append(folderPath);
        fileName.append(File.separator);
        fileName.append("BrainFlow-RAW_");
        fileName.append(folderName);
        fileName.append("_");
        fileName.append(fileNumber);
        fileName.append(".csv");
        fileName.append(brainflowWriteOption);
    }

    public void incrementBrainFlowStreamerFileNumber() {
        fileNumber++;
        generateBrainFlowStreamerFileName();
    }

    public void resetBrainFlowStreamer() {
        fileNumber = -1;
        folderName = "";
        folderPath = "";
        fileName = null;
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

    File directory = new File(selection.getAbsolutePath());
    if (!directory.exists()){
        directory.mkdirs();
        // If you require it to make the entire directory path including parents,
        // use directory.mkdirs(); here instead.
    }


    println("DataLogging: bfSelectedFolder: User selected " + selection.getAbsolutePath());

    dataLogger.setBfWriterFolder(selection.getName(), selection.getAbsolutePath());
}