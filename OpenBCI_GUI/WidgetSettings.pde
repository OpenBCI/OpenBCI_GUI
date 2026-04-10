import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

/**
 * Unified settings storage for widgets that handles enum settings, channel selections,
 * and other types of settings with JSON serialization
 */
class WidgetSettings {
    private String widgetName;
    // Enum settings
    private HashMap<String, Enum<?>> enumSettings;
    private HashMap<String, Enum<?>> defaults;
    // Channel settings
    private HashMap<String, List<Integer>> channelSettings;
    private HashMap<String, List<Integer>> defaultChannelSettings;
    // Other settings
    private HashMap<String, Object> otherSettings;
    private HashMap<String, Object> defaultOtherSettings;

    public static final String KEY_ACTIVE_CHANNELS = "activeChannels";

    public WidgetSettings(String widgetName) {
        this.widgetName = widgetName;
        this.enumSettings = new HashMap<String, Enum<?>>();
        this.defaults = new HashMap<String, Enum<?>>();
        this.channelSettings = new HashMap<String, List<Integer>>();
        this.defaultChannelSettings = new HashMap<String, List<Integer>>();
        this.otherSettings = new HashMap<String, Object>();
        this.defaultOtherSettings = new HashMap<String, Object>();
    }

    //
    // ENUM SETTINGS
    //

    /**
     * Store a setting using enum class as key
     * @return this WidgetSettings instance for method chaining
     */
    public <T extends Enum<?>> WidgetSettings set(Class<T> enumClass, T value) {
        enumSettings.put(enumClass.getName(), value);
        return this;
    }

    /**
     * Store a setting using the enum class and index
     * Useful for setting values from UI components like dropdowns
     * 
     * @param enumClass The enum class to look up values
     * @param index The index of the enum constant to set
     * @return this WidgetSettings instance for method chaining
     */
    public <T extends Enum<?>> WidgetSettings setByIndex(Class<T> enumClass, int index) {
        T[] enumConstants = enumClass.getEnumConstants();
        
        // Check if index is valid
        if (index >= 0 && index < enumConstants.length) {
            // Get the enum value at the specified index
            T value = enumConstants[index];
            // Set it using the regular set method
            set(enumClass, value);
        } else {
            // Index was out of bounds
            println("Warning: Invalid index " + index + " for enum " + enumClass.getName());
        }
        
        return this;
    }

    /**
     * Get a setting using enum class as key
     */
    public <T extends Enum<?>> T get(Class<T> enumClass, T defaultValue) {
        String key = enumClass.getName();
        if (enumSettings.containsKey(key)) {
            Object value = enumSettings.get(key);
            if (value != null && enumClass.isInstance(value)) {
                return enumClass.cast(value);
            }
        }
        return defaultValue;
    }

    /**
     * Get a setting using enum class as key (returns null if not found)
     */
    public <T extends Enum<?>> T get(Class<T> enumClass) {
        return get(enumClass, null);
    }

    //
    // CHANNEL SETTINGS
    //

    /**
     * Store active channels
     * @param channels List of selected channel indices
     * @return this WidgetSettings instance for method chaining
     */
    public WidgetSettings setActiveChannels(List<Integer> channels) {
        // Create a copy to prevent external modification
        channelSettings.put(KEY_ACTIVE_CHANNELS, new ArrayList<Integer>(channels));
        return this;
    }

    /**
     * Get active channels
     * @return List of selected channel indices or empty list if not found
     */
    public List<Integer> getActiveChannels() {
        if (channelSettings.containsKey(KEY_ACTIVE_CHANNELS)) {
            // Return a copy to prevent external modification
            return new ArrayList<Integer>(channelSettings.get(KEY_ACTIVE_CHANNELS));
        }
        return new ArrayList<Integer>(); // Empty list if not found
    }

    /**
     * Check if active channels exist
     * @return true if active channels exist, false otherwise
     */
    public boolean hasActiveChannels() {
        return channelSettings.containsKey(KEY_ACTIVE_CHANNELS) && 
               !channelSettings.get(KEY_ACTIVE_CHANNELS).isEmpty();
    }

    /**
     * Store active channels with a specific name identifier
     * @param name Identifier for this channel selection (e.g., "top", "bottom")
     * @param channels List of selected channel indices
     * @return this WidgetSettings instance for method chaining
     */
    public WidgetSettings setNamedChannels(String name, List<Integer> channels) {
        // Create a copy to prevent external modification
        channelSettings.put(name, new ArrayList<Integer>(channels));
        return this;
    }

    /**
     * Get active channels for a specific named selection
     * @param name Identifier for the channel selection
     * @return List of selected channel indices or empty list if not found
     */
    public List<Integer> getNamedChannels(String name) {
        if (channelSettings.containsKey(name)) {
            // Return a copy to prevent external modification
            return new ArrayList<Integer>(channelSettings.get(name));
        }
        return new ArrayList<Integer>(); // Empty list if not found
    }

    /**
     * Check if a named channel selection exists
     * @param name Identifier for the channel selection
     * @return true if the named selection exists, false otherwise
     */
    public boolean hasNamedChannels(String name) {
        return channelSettings.containsKey(name) && 
               !channelSettings.get(name).isEmpty();
    }

    //
    // OTHER SETTINGS
    //

    /**
     * Store a generic object setting with the given key
     * @param key Name of the setting
     * @param value Value to store
     * @return this WidgetSettings instance for method chaining
     */
    public <T> WidgetSettings setObject(String key, T value) {
        otherSettings.put(key, value);
        return this;
    }

    /**
     * Get a generic object setting by key
     * @param key Name of the setting to retrieve
     * @param defaultValue Value to return if setting doesn't exist
     * @return The stored value or the default if not found
     */
    @SuppressWarnings("unchecked")
    public <T> T getObject(String key, T defaultValue) {
        if (otherSettings.containsKey(key)) {
            try {
                return (T) otherSettings.get(key);
            } catch (ClassCastException e) {
                println("Type mismatch for setting " + key + ": " + e.getMessage());
            }
        }
        return defaultValue;
    }

    /**
     * Check if a generic object setting exists
     * @param key Name of the setting to check
     * @return true if the setting exists, false otherwise
     */
    public boolean hasObject(String key) {
        return otherSettings.containsKey(key);
    }

    //
    // DEFAULT HANDLING
    //

    /**
     * Save current settings as defaults
     * @return this WidgetSettings instance for method chaining
     */
    public WidgetSettings saveDefaults() {
        // Save enum defaults
        defaults = new HashMap<String, Enum<?>>(enumSettings);
        
        // Save channel defaults
        defaultChannelSettings = new HashMap<String, List<Integer>>();
        saveDefaultChannels();
        
        // Save other settings defaults
        defaultOtherSettings = new HashMap<String, Object>(otherSettings);
        
        return this;
    }

    // Helper method for saving default channel settings
    private void saveDefaultChannels() {
        for (String key : channelSettings.keySet()) {
            defaultChannelSettings.put(key, new ArrayList<Integer>(channelSettings.get(key)));
        }
    }

    /**
     * Restore to default settings
     * @return this WidgetSettings instance for method chaining
     */
    public WidgetSettings restoreDefaults() {
        // Restore enum settings
        enumSettings = new HashMap<String, Enum<?>>(defaults);
        
        // Restore channel settings
        restoreDefaultChannels();
        
        // Restore other settings
        otherSettings = new HashMap<String, Object>(defaultOtherSettings);
        
        return this;
    }

    // Helper method for restoring default channel settings
    private void restoreDefaultChannels() {
        channelSettings = new HashMap<String, List<Integer>>();
        
        for (String key : defaultChannelSettings.keySet()) {
            channelSettings.put(key, new ArrayList<Integer>(defaultChannelSettings.get(key)));
        }
    }

    //
    // SERIALIZATION
    //

    /**
     * Convert settings to JSON string
     */
    public String toJSON() {
        JSONObject json = new JSONObject();
        json.setString("widgetTitle", widgetName);
        
        // Serialize settings
        serializeEnumSettings(json);
        serializeChannelSettings(json);
        serializeOtherSettings(json);
        
        return json.toString();
    }

    // Helper method for enum serialization
    private void serializeEnumSettings(JSONObject json) {
        if (enumSettings.isEmpty()) {
            return;
        }
        
        JSONArray enumItems = new JSONArray();
        int i = 0;
        for (String key : enumSettings.keySet()) {
            Enum<?> value = enumSettings.get(key);
            JSONObject item = new JSONObject();
            item.setString("class", key);
            item.setString("value", value.name());
            enumItems.setJSONObject(i++, item);
        }
        json.setJSONArray("enumSettings", enumItems);
    }

    // Helper method for channel serialization
    private void serializeChannelSettings(JSONObject json) {
        if (channelSettings.isEmpty()) {
            return;
        }
        
        JSONObject channelsJson = new JSONObject();
        for (String key : channelSettings.keySet()) {
            List<Integer> channels = channelSettings.get(key);
            JSONArray channelArray = new JSONArray();
            
            for (int i = 0; i < channels.size(); i++) {
                channelArray.setInt(i, channels.get(i));
            }
            channelsJson.setJSONArray(key, channelArray);
        }
        json.setJSONObject("channelSettings", channelsJson);
    }

    // Helper method for other settings serialization
    private void serializeOtherSettings(JSONObject json) {
        if (otherSettings.isEmpty()) {
            return;
        }
        
        JSONObject othersJson = new JSONObject();
        
        for (String key : otherSettings.keySet()) {
            Object value = otherSettings.get(key);
            
            // Handle basic types that JSONObject supports
            if (value instanceof String) {
                othersJson.setString(key, (String)value);
            } else if (value instanceof Integer) {
                othersJson.setInt(key, (Integer)value);
            } else if (value instanceof Float) {
                othersJson.setFloat(key, (Float)value);
            } else if (value instanceof Boolean) {
                othersJson.setBoolean(key, (Boolean)value);
            } else {
                println("WARNING: Couldn't save setting '" + key + "' with value type " + 
                       (value != null ? value.getClass().getName() : "null"));
            }
        }
        
        if (othersJson.size() > 0) {
            json.setJSONObject("otherSettings", othersJson);
        }
    }

    /**
     * Attempts to load settings from a JSON string
     * @param jsonString The JSON string containing settings
     * @return true if settings were loaded successfully, false otherwise
     */
    public boolean loadFromJSON(String jsonString) {
        try {
            JSONObject json = parseJSONObject(jsonString);
            if (json == null) {
                return false;
            }
            
            validateWidgetName(json);
            
            boolean enumSuccess = loadEnumSettings(json);
            boolean channelSuccess = loadChannelSettings(json);
            boolean otherSuccess = loadOtherSettings(json);
            
            return enumSuccess || channelSuccess || otherSuccess;
        } catch (Exception e) {
            println("Error parsing JSON: " + e.getMessage());
            return false;
        }
    }

    // Helper method to validate widget name
    private void validateWidgetName(JSONObject json) {
        String loadedWidget = json.getString("widgetTitle", "");
        if (!loadedWidget.equals(widgetName)) {
            println("Warning: Widget mismatch. Expected: " + widgetName + ", Found: " + loadedWidget);
        }
    }

    // Helper method to load enum settings
    private boolean loadEnumSettings(JSONObject json) {
        if (!json.hasKey("enumSettings")) {
            return false;
        }
        
        JSONArray enumItems = json.getJSONArray("enumSettings");
        if (enumItems == null) {
            return false;
        }
        
        boolean anySuccess = false;
        for (int i = 0; i < enumItems.size(); i++) {
            JSONObject item = enumItems.getJSONObject(i);
            if (item == null) {
                continue;
            }
            
            String className = item.getString("class", null);
            String valueName = item.getString("value", null);
            
            if (className == null || valueName == null) {
                continue;
            }
            
            anySuccess |= loadSingleEnum(className, valueName);
        }
        
        return anySuccess;
    }

    // Helper method to load a single enum value
    private boolean loadSingleEnum(String className, String valueName) {
        try {
            Class<?> enumClass = Class.forName(className);
            if (!enumClass.isEnum()) {
                return false;
            }
            
            @SuppressWarnings("unchecked")
            Enum<?> enumValue = Enum.valueOf((Class<Enum>)enumClass, valueName);
            enumSettings.put(className, enumValue);
            return true;
        } catch (Exception e) {
            println("Error loading enum setting: " + e.getMessage());
            return false;
        }
    }

    // Helper method to load channel settings
    private boolean loadChannelSettings(JSONObject json) {
        if (!json.hasKey("channelSettings")) {
            return false;
        }
        
        JSONObject channelsJson = json.getJSONObject("channelSettings");
        // Fixed this line
        if (channelsJson == null || channelsJson.size() == 0) {
            return false;
        }
        
        // Clear existing settings only when we have valid data
        channelSettings.clear();
        
        boolean anySuccess = false;
        for (Object key : channelsJson.keys()) {
            String channelKey = key.toString();
            JSONArray channelArray = channelsJson.getJSONArray(channelKey);
            
            if (channelArray == null) {
                continue;
            }
            
            List<Integer> channels = new ArrayList<Integer>();
            for (int i = 0; i < channelArray.size(); i++) {
                channels.add(channelArray.getInt(i));
            }
            
            channelSettings.put(channelKey, channels);
            anySuccess = true;
        }
        
        return anySuccess;
    }

    // Helper method to load other settings - simplified version
    private boolean loadOtherSettings(JSONObject json) {
        if (!json.hasKey("otherSettings")) {
            return false;
        }
        
        JSONObject othersJson = json.getJSONObject("otherSettings");
        if (othersJson == null || othersJson.size() == 0) {
            return false;
        }
        
        boolean anySuccess = false;
        
        // Get all keys
        for (Object keyObj : othersJson.keys()) {
            String key = keyObj.toString();
            Object value = null;
            
            // Try each type in sequence
            value = tryLoadAnyType(othersJson, key);
            if (value != null) {
                otherSettings.put(key, value);
                anySuccess = true;
            } else {
                println("Could not determine type for key: " + key);
            }
        }
        
        return anySuccess;
    }

    /**
     * Try to load a value from JSON as any supported type
     */
    private Object tryLoadAnyType(JSONObject json, String key) {
        // Try as String
        try {
            return json.getString(key);
        } catch (Exception e) { /* Not a string */ }
        
        // Try as Integer
        try {
            return json.getInt(key);
        } catch (Exception e) { /* Not an integer */ }
        
        // Try as Float
        try {
            return json.getFloat(key);
        } catch (Exception e) { /* Not a float */ }
        
        // Try as Boolean
        try {
            return json.getBoolean(key);
        } catch (Exception e) { /* Not a boolean */ }
        
        return null; // No type worked
    }
}
