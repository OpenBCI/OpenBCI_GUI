import java.util.LinkedList;

public class TimeTrackingQueue<T> extends Thread {
    private int maxTimeMillis;
    private LinkedList<Integer> timeList;
    private LinkedList<T> objectList;

    public TimeTrackingQueue(int _maxTimeMillis) {
        this.maxTimeMillis = _maxTimeMillis;
        start(); // start thread the checks expiration
    }

    public void push(T object) {
        timeList.push(millis());
        objectList.push(object);
    }

    public void run() {
        while(true) {
            // if we have an item to expire, remove it
            if (!timeList.isEmpty() && timeList.peekLast() + maxTimeMillis < millis()) {
                timeList.removeLast();
                objectList.removeLast();
            }
            // otherwise wait
            else {
                delay(1); // wait one millisecond
            }
        }
    }

    public int size() {
        return objectList.size();
    }
}