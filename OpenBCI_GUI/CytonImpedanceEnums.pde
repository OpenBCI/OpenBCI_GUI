
public enum CytonSignalCheckMode implements IndexingInterface
{
    LIVE (0, "Live"),
    IMPEDANCE (1, "Impedance");

    private int index;
    private String label;

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
}

public enum CytonImpedanceLabels implements IndexingInterface
{
    ADS_CHANNEL (0, "Channel"),
    ANATOMICAL (1, "Anatomical")
    ;

    private int index;
    private String label;
    private boolean boolean_value;

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
}

public enum CytonImpedanceInterval implements IndexingInterface
{
    FOUR (0, 4000, "4 sec"),
    FIVE (1, 5000, "5 sec"),
    SEVEN (2, 7000, "7 sec"),
    TEN (3, 10000, "10 sec");

    private int index;
    private int value;
    private String label;
    private boolean boolean_value;

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
}