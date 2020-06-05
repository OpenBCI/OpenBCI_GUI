import java.lang.Math;


public class Buffer<T> extends LinkedList<T> {

    private int samplingRate;
    private int maxSize;
    private Long msSinceLastCall;

    Buffer(int samplingRate, int maxSize) {
        this.samplingRate = samplingRate;
        this.maxSize = maxSize;
        msSinceLastCall = null;
    }

    Buffer(int samplingRate) {
        // max delay smth like 2 seconds
        this(samplingRate, samplingRate * 2);
    }

    public void addNewEntry(T object) {
        this.add(object);
    }

    public T popFirstEntry() {
        return this.poll();
    }

    public int getDataCount() {
        long currentTime = millis();
        int numSamples = 0;
        // skip first call to set time
        if (msSinceLastCall != null) {
            double deltaTimeSeconds = (currentTime - msSinceLastCall.longValue()) / 1000.0;
            numSamples = (int)(samplingRate * deltaTimeSeconds);
        }
        msSinceLastCall = currentTime;
        // ensure that buffer is not bigger than maxSize
        if (this.size() > maxSize) {
            numSamples += this.size() - maxSize;
        }
        return Math.min(numSamples, this.size());
    }
}