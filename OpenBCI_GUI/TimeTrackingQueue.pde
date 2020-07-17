import java.util.LinkedList;
import java.util.ListIterator;

public class TimeTrackingQueue<T> extends Thread {
    private boolean freeze = false;
    private int maxTimeMillis;
    private LinkedList<Integer> timeList = new LinkedList<Integer>();
    private LinkedList<T> objectList = new LinkedList<T>();

    public TimeTrackingQueue(int _maxTimeMillis) {
        this.maxTimeMillis = _maxTimeMillis;
        start(); // start thread the checks expiration
    }

    public synchronized void push(T object) {
        timeList.push(millis());
        objectList.push(object);
    }

    public void run() {
        while(true) {
            if(!expireLast()) {
                delay(1); // wait one millisecond
            }
        }
    }

    // if we have an item to expire, remove it
    private synchronized boolean expireLast() {
        if (!freeze && !timeList.isEmpty() && timeList.peekLast() + maxTimeMillis < millis()) {
            timeList.removeLast();
            objectList.removeLast();
            return true;
        }

        return false;
    }

    public synchronized int size() {
        return objectList.size();
    }

    public synchronized List<T> getLastData(int milliseconds) {
        int endIndex = 0;

        if(objectList.size() == 0) {
            return objectList.subList(0, 0);
        }

        ListIterator<Integer> iter = timeList.listIterator();
        while(iter.hasNext()) {
            int nextIndex = iter.nextIndex();
            if(iter.next() + milliseconds <= millis()) {
                break; // we are done
            }
            else {
                endIndex = nextIndex;
            }
        }

        // sublist excludes the last index so we need to add 1 to be accurate
        return objectList.subList(0, endIndex + 1);
    }

    public void setFreeze_UNITTEST(boolean shouldFreeze) {
        freeze = shouldFreeze;
    }
}