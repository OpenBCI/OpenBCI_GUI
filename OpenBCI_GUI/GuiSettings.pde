import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.io.*;
import java.util.regex.*;


interface GuiSettingsEnum {
    public String getName();
}

enum ExpertModeEnum implements GuiSettingsEnum {
    ON("Active", true),
    OFF("Inactive", false);

    private String name;
    private boolean val;

    ExpertModeEnum(String _name, boolean _val) {
        this.name = _name;
        this.val = _val;
    }

    @Override
    public String getName() {
        return name;
    }

    public boolean getBooleanValue() {
        return val;
    }
}

public class GuiSettingsValues {
    public ExpertModeEnum expertMode = ExpertModeEnum.OFF;
    public boolean showCytonSmoothingPopup = true;

    public GuiSettingsValues() {
    }
}

class GuiSettings {

    private GuiSettingsValues values;
    private String filename;

    GuiSettings(String settingsDirectory) {

        values = new GuiSettingsValues();
        StringBuilder settingsFilename = new StringBuilder(settingsDirectory);
        settingsFilename.append("GuiWideSettings.json");
        filename = settingsFilename.toString();
        File fileToCheck = new File(filename);
        boolean fileExists = fileToCheck.exists();
        if (fileExists) {
            loadSettingsValues();
        } else {
            println("OpenBCI_GUI::Settings: Creating new GUI-wide Settings file.");
            saveToFile();
        }
    }

    public boolean loadSettingsValues() {
        // Get the number of lines in the JSON file that should exist.
        // Used to check if JSON is different when settings are added or removed from this class.
        int linesByDefault = getNumberOfLines(getJson());

        try {
            File file = new File(filename);
            StringBuilder fileContents = new StringBuilder((int)file.length());        
            Scanner scanner = new Scanner(file);
            int tempNumLines = 0;
            while(scanner.hasNextLine()) {
                fileContents.append(scanner.nextLine() + System.lineSeparator());
                tempNumLines++;
            }
            Gson gson = new Gson();

            if (linesByDefault == tempNumLines) {
                values = gson.fromJson(fileContents.toString(), GuiSettingsValues.class);
                println("OpenBCI_GUI::Settings: Found and loaded existing GUI-wide Settings from file.");
            } else {
                println("OpenBCI_GUI::Settings: Incompatible GUI-wide Settings found. Creating new file and resetting defaults.");
                saveToFile();
            }
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            outputWarn("OpenBCI_GUI::Settings: Error loading GUI-wide settings from file. Attempting to create a new one.");
            //If there is an error, attempt to overwrite the file or create a new one
            saveToFile();
            return false;
        }
        
    }

    public String getJson() {
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        return gson.toJson(values);
    }

    public boolean saveToFile() {
        String json = getJson();

        try {
            final File file = new File(filename);
            final File parent_directory = file.getParentFile();

            if (null != parent_directory)
            {
                parent_directory.mkdirs();
            }
        } catch (Exception e) {
            e.printStackTrace();
            outputWarn("OpenBCI_GUI::Settings: Error creating /Documents/OpenBCI_GUI/Settings/ folder. Please make an issue on GitHub.");
            return false;
        }
 
        try {
            FileWriter writer = new FileWriter(filename);
            writer.write(json);
            writer.close();
            println("OpenBCI_GUI::Settings: Successfully saved GUI-wide settings to file!");
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            outputWarn("OpenBCI_GUI::Settings: Error saving GUI-wide settings to file. Please make an issue on GitHub.");
            return false;
        }
    }

    private int getNumberOfLines(String s) {
        Matcher m = Pattern.compile("\r\n|\r|\n").matcher(s);
        int lines = 1;
        while (m.find()) {
            lines++;
        }
        return lines;
    }

    //Call this method at the end of GUI main Setup in OpenBCI_GUI.pde to make sure everything exists
    //Has to be in this class to make sure other classes exist
    public void applySettings() {
        topNav.configSelector.toggleExpertModeFrontEnd(getExpertModeBoolean());
    }

    public void setExpertMode(ExpertModeEnum val) {
        values.expertMode = val;
        saveToFile();
    }
    
    public boolean getExpertModeBoolean() {
        return values.expertMode.getBooleanValue();
    }

    public void setShowCytonSmoothingPopup(boolean b) {
        values.showCytonSmoothingPopup = b;
        saveToFile();
    }

    public boolean getShowCytonSmoothingPopup() {
        return values.showCytonSmoothingPopup;
    }
}