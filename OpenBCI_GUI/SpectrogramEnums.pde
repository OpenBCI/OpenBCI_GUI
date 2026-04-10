public enum SpectrogramMaxFrequency implements IndexingInterface {
    MAX_20 (0, 20, "20 Hz", new int[]{20, 15, 10, 5, 0, 5, 10, 15, 20}),
    MAX_40 (1, 40, "40 Hz", new int[]{40, 30, 20, 10, 0, 10, 20, 30, 40}),
    MAX_60 (2, 60, "60 Hz", new int[]{60, 45, 30, 15, 0, 15, 30, 45, 60}),
    MAX_100 (3, 100, "100 Hz", new int[]{100, 75, 50, 25, 0, 25,  50, 75, 100}),
    MAX_120 (4, 120, "120 Hz", new int[]{120, 90, 60, 30, 0, 30, 60, 90, 120}),
    MAX_250 (5, 250, "250 Hz", new int[]{250, 188, 125, 63, 0, 63, 125, 188, 250});

    private int index;
    private final int value;
    private String label;
    private final int[] axisLabels;

    SpectrogramMaxFrequency(int index, int value, String label, int[] axisLabels) {
        this.index = index;
        this.value = value;
        this.label = label;
        this.axisLabels = axisLabels;
    }

    public int getValue() {
        return value;
    }

    public int[] getAxisLabels() {
        return axisLabels;
    }

    @Override
    public String getString() {
        return label;
    }

    @Override
    public int getIndex() {
        return index;
    }
}

public enum SpectrogramWindowSize implements IndexingInterface {
    ONE_MINUTE (0, 1f, "1 Min.", new float[]{1, .5, 0}, 25),
    ONE_MINUTE_THIRTY (1, 1.5f, "1.5 Min.", new float[]{1.5, 1, .5, 0}, 50),
    THREE_MINUTES (2, 3f, "3 Min.", new float[]{3, 2, 1, 0}, 100),
    SIX_MINUTES (3, 6f, "6 Min.", new float[]{6, 5, 4, 3, 2, 1, 0}, 200),
    THIRTY_MINUTES (4, 30f, "30 Min.", new float[]{30, 25, 20, 15, 10, 5, 0}, 1000);

    private int index;
    private final float value;
    private String label;
    private final float[] axisLabels;
    private final int scrollSpeed;

    SpectrogramWindowSize(int index, float value, String label, float[] axisLabels, int scrollSpeed) {
        this.index = index;
        this.value = value;
        this.label = label;
        this.axisLabels = axisLabels;
        this.scrollSpeed = scrollSpeed;
    }

    public float getValue() {
        return value;
    }

    public float[] getAxisLabels() {
        return axisLabels;
    }

    public int getScrollSpeed() {
        return scrollSpeed;
    }

    @Override
    public String getString() {
        return label;
    }

    @Override
    public int getIndex() {
        return index;
    }
}
