public enum DownsamplingRateEnum {
    NONE (1),
    TWO (2),
    FOUR (4),
    EIGHT (8);

    public final int value;

    DownsamplingRateEnum(int _value) {
        value = _value;
    }
}