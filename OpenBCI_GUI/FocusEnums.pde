/// Here are the enums used by the Focus Widget, found in W_Focus.pde 

// color enums
public enum FocusColors {
    GREEN, CYAN, ORANGE
}

interface FocusEnum {
    public int getIndex();
    public String getString();
}

public enum FocusXLim implements FocusEnum
{
    FIVE (0, 5, "5 sec"),
    TEN (1, 10, "10 sec"),
    TWENTY (2, 20, "20 sec");

    private int index;
    private int value;
    private String label;

    private static FocusXLim[] vals = values();

    FocusXLim(int _index, int _value, String _label) {
        this.index = _index;
        this.value = _value;
        this.label = _label;
    }

    public int getValue() {
        return value;
    }

    @Override
    public String getString() {
        return label;
    }

    @Override
    public int getIndex() {
        return index;
    }

    public static List<String> getEnumStringsAsList() {
        List<String> enumStrings = new ArrayList<String>();
        for (FocusEnum val : vals) {
            enumStrings.add(val.getString());
        }
        return enumStrings;
    }
}

public enum FocusMetric implements FocusEnum
{
    CONCENTRATION (0, "Concentration", BrainFlowMetrics.CONCENTRATION, "Concentrating"),
    RELAXATION (1, "Relaxation", BrainFlowMetrics.RELAXATION, "Relaxing");

    private int index;
    private String label;
    private BrainFlowMetrics metric;
    private String idealState;

    private static FocusMetric[] vals = values();

    FocusMetric(int _index, String _label, BrainFlowMetrics _metric, String _idealState) {
        this.index = _index;
        this.label = _label;
        this.metric = _metric;
        this.idealState = _idealState;
    }

    @Override
    public String getString() {
        return label;
    }

    @Override
    public int getIndex() {
        return index;
    }

    public BrainFlowMetrics getMetric() {
        return metric;
    }

    public String getIdealStateString() {
        return idealState;
    }

    public static List<String> getEnumStringsAsList() {
        List<String> enumStrings = new ArrayList<String>();
        for (FocusEnum val : vals) {
            enumStrings.add(val.getString());
        }
        return enumStrings;
    }
}

public enum FocusClassifier implements FocusEnum
{
    REGRESSION (0, "Regression", BrainFlowClassifiers.REGRESSION),
    KNN (1, "KNN", BrainFlowClassifiers.KNN),
    SVM (2, "SVM", BrainFlowClassifiers.SVM),
    LDA (3, "LDA", BrainFlowClassifiers.LDA);

    private int index;
    private int value;
    private String label;
    private BrainFlowClassifiers classifier;

    private static FocusClassifier[] vals = values();

    FocusClassifier(int _index, String _label, BrainFlowClassifiers _classifier) {
        this.index = _index;
        this.label = _label;
        this.classifier = _classifier;
    }

    @Override
    public String getString() {
        return label;
    }

    @Override
    public int getIndex() {
        return index;
    }

    public BrainFlowClassifiers getClassifier() {
        return classifier;
    }

    public static List<String> getEnumStringsAsList() {
        List<String> enumStrings = new ArrayList<String>();
        for (FocusEnum val : vals) {
            enumStrings.add(val.getString());
        }
        return enumStrings;
    }
}

public enum FocusThreshold implements FocusEnum
{
    FIVE_TENTHS (0, .5, "0.5"),
    SIX_TENTHS (1, .6, "0.6"),
    SEVEN_TENTHS (2, .7, "0.7"),
    EIGHT_TENTHS (3, .8, "0.8"),
    NINE_TENTHS (4, .9, "0.9");

    private int index;
    private float value;
    private String label;

    private static FocusThreshold[] vals = values();

    FocusThreshold(int _index, float _value, String _label) {
        this.index = _index;
        this.value = _value;
        this.label = _label;
    }

    public float getValue() {
        return value;
    }

    @Override
    public String getString() {
        return label;
    }

    @Override
    public int getIndex() {
        return index;
    }

    public static List<String> getEnumStringsAsList() {
        List<String> enumStrings = new ArrayList<String>();
        for (FocusEnum val : vals) {
            enumStrings.add(val.getString());
        }
        return enumStrings;
    }
}