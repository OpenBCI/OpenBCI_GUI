import java.lang.Math;
import java.util.Date;


public class Buffer<T> extends LinkedList<T> {

    private int samplingRate;
    private int maxSize;
    private Long msSinceLastCall;

    Buffer(int samplingRate, int maxSize) {
        this.samplingRate = samplingRate;
        this.maxSize = maxSize;
        Date date = new Date();
        msSinceLastCall = null;
    }

    Buffer(int samplingRate) {
        // max delay smth like 2 seconds
        this(samplingRate, samplingRate * 2);
    }

    public void addNewEntry(T object) {
        while (this.size() >= maxSize) {
            this.popFirstEntry();
        }
        this.add(object);
    }

    public T popFirstEntry() {
        return this.poll();
    }

    public int getDataCount() {
        Date date = new Date();
        long currentTime = date.getTime();
        int numSamples = 0;
        // skip first call to set time
        if (msSinceLastCall != null) {
            double deltaTimeSeconds = (currentTime - msSinceLastCall.longValue()) / 1000.0;
            numSamples = (int)(samplingRate * deltaTimeSeconds);
        }
        msSinceLastCall = currentTime;
        return Math.min(numSamples, this.size());
    }
}