
public enum CytonSignalCheckMode implements IndexingInterface
{
    LIVE (0, "Live"),
    IMPEDANCE (1, "Impedance");

    private int index;
    private String label;
    private static CytonSignalCheckMode[] vals = values();

    CytonSignalCheckMode(int _index, String _label) {
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

    public boolean getIsImpedanceMode() {
        return label.equals("Impedance");
    }

    private static List<String> getEnumStringsAsList() {
        List<String> enumStrings = new ArrayList<String>();
        for (IndexingInterface val : vals) {
            enumStrings.add(val.getString());
        }
        return enumStrings;
    }
}

public enum CytonImpedanceLabels implements IndexingInterface
{
    ADS_CHANNEL (0, "Channel"),
    ANATOMICAL (1, "Anatomical")
    ;

    private int index;
    private String label;
    private boolean boolean_value;
    private static CytonImpedanceLabels[] vals = values();

    CytonImpedanceLabels(int _index, String _label) {
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

    public boolean getIsAnatomicalName() {
        return label.equals("Anatomical");
    }

    private static List<String> getEnumStringsAsList() {
        List<String> enumStrings = new ArrayList<String>();
        for (IndexingInterface val : vals) {
            enumStrings.add(val.getString());
        }
        return enumStrings;
    }
}

public enum CytonImpedanceInterval implements IndexingInterface
{
    FOUR (1, 4000, "4 sec"),
    FIVE (2, 5000, "5 sec"),
    SEVEN (3, 7000, "7 sec"),
    TEN (4, 10000, "10 sec")
    ;

    private int index;
    private int value;
    private String label;
    private boolean boolean_value;
    private static CytonImpedanceInterval[] vals = values();

    CytonImpedanceInterval(int _index, int _val, String _label) {
        this.index = _index;
        this.value = _val;
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

    public int getValue() {
        return value;
    }

    private static List<String> getEnumStringsAsList() {
        List<String> enumStrings = new ArrayList<String>();
        for (IndexingInterface val : vals) {
            enumStrings.add(val.getString());
        }
        return enumStrings;
    }
}