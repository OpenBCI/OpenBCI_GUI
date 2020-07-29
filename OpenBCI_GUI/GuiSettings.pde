class GuiSettings {

    GuiSettings() {
        initSampleData();
    }

    public void initSampleData() {
        // Create GUI data folder in Users' Documents and copy sample data if it doesn't already exist
        String directoryName = settings.guiDataPath + File.separator + "Sample_Data" + File.separator;
        String guiv4fileName = directoryName + "OpenBCI-sampleData-2-meditation.txt";
        String guiv5fileName = directoryName + "OpenBCI_GUI-v5-meditation.txt";
        File directory = new File(directoryName);
        File guiv4_fileToCheck = new File(guiv4fileName);
        File guiv5_fileToCheck = new File(guiv5fileName);

        if (guiv4_fileToCheck.exists()) {
            //Delete old gui v4 files in Documents folder
            try {
                List<File> results = new ArrayList<File>();
                File[] filesFound = directory.listFiles();
                //If this pathname does not denote a directory, then listFiles() returns null.
                for (File file : filesFound) {
                    file.delete();
                }
                println("Setup: Successfully deleted old GUI v4 sample data files!");
            } catch (SecurityException e) {
                outputError("Setup: Error trying to delete old GUI Sample Data in Documents folder.");
            }
            copySampleDataFiles(directory, directoryName);
        } else {
            //Do nothing
        }
        
        if (!guiv5_fileToCheck.exists()) {
            copySampleDataFiles(directory, directoryName);
        } else {
            println("OpenBCI_GUI::Setup: GUI v5 Sample Data exists in Documents folder.");
        }

        //Create \Documents\OpenBCI_GUI\Recordings\ if it doesn't exist
        String recordingDirString = settings.guiDataPath + File.separator + "Recordings";
        File recDirectory = new File(recordingDirString);
        if (!recDirectory.exists()) {
            if (recDirectory.mkdir()) {
                println("OpenBCI_GUI::Setup: Created \\Documents\\OpenBCI_GUI\\Recordings\\");
            }
        }
    }

    private void copySampleDataFiles(File directory, String directoryName) {
        println("OpenBCI_GUI::Setup: Copying sample data to Documents/OpenBCI_GUI/Sample_Data");
        // Make the entire directory path including parents
        directory.mkdirs();
        try {
            List<File> results = new ArrayList<File>();
            File[] filesFound = new File(dataPath("EEG_Sample_Data")).listFiles();
            //If this pathname does not denote a directory, then listFiles() returns null.
            for (File file : filesFound) {
                if (file.isFile()) {
                    results.add(file);
                }
            }
            for(File file : results) {
                Files.copy(file.toPath(),
                    (new File(directoryName + file.getName())).toPath(),
                    StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (IOException e) {
            outputError("Setup: Error trying to copy Sample Data to Documents directory.");
        }
    }
}