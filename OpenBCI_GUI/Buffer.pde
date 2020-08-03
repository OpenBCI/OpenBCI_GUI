import java.lang.Math;


public class Buffer<T> extends LinkedList<T> {

    private int samplingRate;
    private int maxSize;
    private Long timeOfLastCallMS;

    Buffer(int samplingRate, int maxSize) {
        this.samplingRate = samplingRate;
        this.maxSize = maxSize;
        timeOfLastCallMS = null;
    }

    Buffer(int samplingRate) {
        // max delay 1 second
        this(samplingRate, samplingRate /*max size*/);
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
        if (timeOfLastCallMS != null) {
            float deltaTimeSeconds = (currentTime - timeOfLastCallMS.longValue()) / 1000.0;
            // for safety, err on the side of delivering more samples (hence the use of ceil())
            numSamples = ceil(samplingRate * deltaTimeSeconds);
        }
        timeOfLastCallMS = currentTime;
        // ensure that buffer is not bigger than maxSize
        if (this.size() > maxSize) {
            numSamples += this.size() - maxSize;
        }
        return Math.min(numSamples, this.size());
    }
}