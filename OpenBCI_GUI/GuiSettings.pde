import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.io.*;


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
    public ExpertModeEnum expertMode;

    public GuiSettingsValues() {
    }
}

class GuiSettings {

    public GuiSettingsValues values;
    private String filename;

    GuiSettings(String settingsDirectory) {

        values = new GuiSettingsValues();
        values.expertMode = ExpertModeEnum.OFF;
        
        StringBuilder settingsFilename = new StringBuilder(settingsDirectory);
        settingsFilename.append("GuiWideSettings.txt");
        filename = settingsFilename.toString();
        File fileToCheck = new File(filename);
        boolean fileExists = fileToCheck.exists();
        if (fileExists) {
            loadSettingsValues();
            println("OpenBCI_GUI::Settings: Found and loaded existing GUI settings from.");
        } else {
            println("OpenBCI_GUI::Settings: Creating new GUI default settings file.");
            saveToFile();
        }
    }

    public boolean loadSettingsValues() {
        try {
            File file = new File(filename);
            StringBuilder fileContents = new StringBuilder((int)file.length());        
            Scanner scanner = new Scanner(file);
            while(scanner.hasNextLine()) {
                fileContents.append(scanner.nextLine() + System.lineSeparator());
            }
            Gson gson = new Gson();
            values = gson.fromJson(fileContents.toString(), GuiSettingsValues.class);
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            outputWarn("OpenBCI_GUI::Settings: Error loading GUI-wide settings from file. Attempting to create a new one.");
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

    //Call this method at the end of GUI main Setup in OpenBCI_GUI.pde to make sure everything exists
    public void applySettingsToFrontEnd() {
        topNav.configSelector.toggleExpertModeFrontEnd(values.expertMode.getBooleanValue());
    }

    public void setExpertMode(ExpertModeEnum val) {
        values.expertMode = val;
        saveToFile();
    }

    
    public boolean getExpertModeBoolean() {
        return values.expertMode.getBooleanValue();
    }

}