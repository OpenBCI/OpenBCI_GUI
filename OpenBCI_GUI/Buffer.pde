import java.lang.Math;


public class Buffer<T> extends LinkedList<T> {

    private int samplingRate;
    private int fps;
    private int dataPerUpdate;

    Buffer(int fps, int samplingRate) {
        this.fps = fps;
        this.samplingRate = samplingRate;
        dataPerUpdate = Math.max(samplingRate / fps, 1);
    }

    public void addNewEntry(T object) {
        this.add(object);
    }

    public T popFirstEntry() {
        return this.poll();
    }

    public int getDataCount() {
        return Math.min(this.size(), dataPerUpdate);
    }
}