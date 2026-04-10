//Used for Widget Dropdown Enums
interface IndexingInterface {
    public int getIndex();
    public String getString();
}

/**
 * Helper class for working with IndexingInterface enums
 */
public static class EnumHelper {
    /**
     * Generic method to get enum strings as a list
     */
    public static <T extends IndexingInterface> List<String> getListAsStrings(T[] values) {
        List<String> enumStrings = new ArrayList<>();
        for (T enumValue : values) {
            enumStrings.add(enumValue.getString());
        }
        return enumStrings;
    }
    
    /**
     * Get list of strings for an enum class that implements IndexingInterface
     */
    public static <T extends Enum<T> & IndexingInterface> List<String> getEnumStrings(Class<T> enumClass) {
        return getListAsStrings(enumClass.getEnumConstants());
    }
}