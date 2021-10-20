interface CytonImpedanceEnum {
    public int getIndex();
    public String getString();
}

public enum CytonSignalCheckMode implements CytonImpedanceEnum
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

public enum CytonImpedanceLabels implements CytonImpedanceEnum
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

public enum CytonImpedanceInterval implements CytonImpedanceEnum
{
    MONKEY_MODE (0, 500, "0.5 sec"),
    TWO (1, 2000, "2 sec"),
    THREE (2, 3000, "3 sec"),
    FOUR (3, 4000, "4 sec"),
    FIVE (4, 5000, "5 sec"),
    SEVEN (5, 7000, "7 sec"),
    TEN (6, 10000, "10 sec")
    ;

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