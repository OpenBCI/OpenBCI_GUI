import javax.swing.JFileChooser;
import java.awt.FileDialog;

public enum FileChooserMode {
    SAVE, LOAD;
}

public enum FileChooserType {
    NATIVE, JFILECHOOSER;
}

class FileChooser implements Runnable {
    FileChooserMode mode;
    FileChooserType type;
    String prompt;
    File defaultSelection;
    String callbackMethod;
    File selectedFile;

    FileChooser(FileChooserMode _mode, String _callbackMethod) {
        this(FileChooserType.NATIVE, _mode, _callbackMethod, null, null);
    }

    FileChooser(FileChooserMode _mode, String _callbackMethod, File _defaultSelection) {
        this(FileChooserType.NATIVE, _mode, _callbackMethod, _defaultSelection, null);
    }

    FileChooser(FileChooserMode _mode, String _callbackMethod, File _defaultSelection, String _prompt) {
        this(FileChooserType.NATIVE, _mode,  _callbackMethod, _defaultSelection, _prompt);
    }

    FileChooser(FileChooserType _type, FileChooserMode _mode,  String _callbackMethod, File _defaultSelection, String _prompt) {
        mode = _mode;
        type = _type;
        callbackMethod = _callbackMethod;
        defaultSelection = _defaultSelection;
        if (_prompt == null) {
            prompt = mode == FileChooserMode.SAVE ? "Save file" : "Load file";
        } else {
            prompt = _prompt;
        }
        Thread t = new Thread(this);
        t.start();
    }

    @Override
    public void run() {
        switch (type) {
            case JFILECHOOSER:
                createJFileChooser();
                break;
            case NATIVE:
                createNativeFileChooser();
                break;
        }
    }

    private void createJFileChooser() {
        JFileChooser fileChooser = new JFileChooser();
        if (mode == FileChooserMode.SAVE) {
            fileChooser.showSaveDialog(null);
        } else {
            fileChooser.showOpenDialog(null);
        }
        PApplet.selectCallback(selectedFile, callbackMethod, ourApplet);
    }

    private void createNativeFileChooser() {
        int nativeDialogMode = mode == FileChooserMode.SAVE ? FileDialog.SAVE : FileDialog.LOAD;
        
        // Create a dummy frame to parent the file dialog. The main GUI window is JOGL's GLWindow, which is not a Frame.
        Frame ourAppletDummyFrame = new Frame();
        ourAppletDummyFrame.setUndecorated(true);
        ourAppletDummyFrame.setOpacity(0.0f);
        ourAppletDummyFrame.setVisible(true);
        ourAppletDummyFrame.toFront();
        
        // Create the file dialog
        FileDialog dialog = new FileDialog(ourAppletDummyFrame, prompt, nativeDialogMode);
        if (defaultSelection != null) {
            
            println("FileChooser: Setting directory to " + defaultSelection.getAbsolutePath());
            if (defaultSelection.isDirectory()) {
                dialog.setDirectory(defaultSelection.getAbsolutePath());
                dialog.setFile("");
            } else {
                dialog.setDirectory(defaultSelection.getParent());
                dialog.setFile(defaultSelection.getName());
            }
        }

        // Show the dialog. This method does not return until the dialog is closed by the user.
        dialog.setVisible(true);

        // Dispose the dummy frame
        ourAppletDummyFrame.setVisible(false);
        ourAppletDummyFrame.dispose();

        // Get the selected file
        String directory = dialog.getDirectory();
        String filename = dialog.getFile();
        if (filename != null) {
            selectedFile = new File(directory, filename);
        }

        // If the user cancelled the dialog, the directory and filename will be null
        if (directory == null && filename == null) {
            println("FileChooser: No file selected");
            return;
        }

        println("FileChooser: User selected " + selectedFile.getAbsolutePath());
       
        PApplet.selectCallback(selectedFile, callbackMethod, ourApplet);
    }
}