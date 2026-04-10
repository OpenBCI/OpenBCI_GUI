import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;
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
    public boolean showGanglionUpgradePopup = true;
    public boolean showStopStreamHardwareSettingsPopup = true;
    public boolean showConfirmExitAppPopup = true;
    public boolean autoStartDataStream = false;
    public boolean autoStartNetworkStream = false;
    public boolean autoLoadSessionSettings = false;

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
        try {

            File file = new File(filename);
            StringBuilder fileContents = new StringBuilder((int)file.length());        
            Scanner scanner = new Scanner(file);

            while(scanner.hasNextLine()) {
                fileContents.append(scanner.nextLine() + System.lineSeparator());
            }

            //Check for incompatible or old settings
            if (validateJsonKeys(fileContents.toString())) {
                Gson gson = new Gson();
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

    private boolean validateJsonKeys(String stringToSearch) {
        List<String> valueKeys = new ArrayList<String>();
        Gson valueGson = new Gson();
        Map<String, Object> valueMap = valueGson.fromJson(getJson(), new TypeToken<Map<String, Object>>() {}.getType());
        for (String mapKey : valueMap.keySet()) {
            valueKeys.add(mapKey);
        }

        List<String> foundKeys = new ArrayList<String>();
        Gson foundGson = new Gson();
        Map<String, Object> foundMap = foundGson.fromJson(stringToSearch, new TypeToken<Map<String, Object>>() {}.getType());
        for (String mapKey : foundMap.keySet()) {
            foundKeys.add(mapKey);
        }

        Collections.sort(valueKeys);
        Collections.sort(foundKeys);

        boolean isEqual = valueKeys.equals(foundKeys);

        return isEqual;
    }

    public void resetAllSettings() {
        values = new GuiSettingsValues();
        applySettings();
    }

    //Call this method at the end of GUI main Setup in OpenBCI_GUI.pde to make sure everything exists
    //Has to be in this class to make sure other classes exist
    public void applySettings() {
        topNav.configSelector.toggleExpertModeFrontEnd(getExpertModeBoolean());
        topNav.configSelector.toggleAutoStartDataStreamFrontEnd(getAutoStartDataStream());
        topNav.configSelector.toggleAutoStartNetworkStreamFrontEnd(getAutoStartNetworkStream());
        topNav.configSelector.toggleAutoLoadSessionSettingsFrontEnd(getAutoLoadSessionSettings());
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

    public void setShowGanglionUpgradePopup(boolean b) {
        values.showGanglionUpgradePopup = b;
        saveToFile();
    }

    public boolean getShowCytonSmoothingPopup() {
        return values.showCytonSmoothingPopup;
    }

    public boolean getShowGanglionUpgradePopup() {
        return values.showGanglionUpgradePopup;
    }

    public void setShowStopStreamHardwareSettingsPopup(boolean b) {
        values.showStopStreamHardwareSettingsPopup = b;
        saveToFile();
    }

    public boolean getShowStopStreamHardwareSettingsPopup() {
        return values.showStopStreamHardwareSettingsPopup;
    }

    public void setShowConfirmExitAppPopup(boolean b) {
        values.showConfirmExitAppPopup = b;
        saveToFile();
    }

    public boolean getShowConfirmExitAppPopup() {
        return values.showConfirmExitAppPopup;
    }

    public void setAutoStartDataStream(boolean b) {
        values.autoStartDataStream = b;
        saveToFile();
    }

    public boolean getAutoStartDataStream() {
        return values.autoStartDataStream;
    }

    public void setAutoStartNetworkStream(boolean b) {
        values.autoStartNetworkStream = b;
        saveToFile();
    }

    public boolean getAutoStartNetworkStream() {
        return values.autoStartNetworkStream;
    }

    public boolean getAutoLoadSessionSettings() {
        return values.autoLoadSessionSettings;
    }

    public void setAutoLoadSessionSettings(boolean b) {
        values.autoLoadSessionSettings = b;
        saveToFile();
    }
}