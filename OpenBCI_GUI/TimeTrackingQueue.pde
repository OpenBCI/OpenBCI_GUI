import java.util.LinkedList;
import java.util.ListIterator;

// For unit testing, we can pass a unique implementation of TTQTimeProvider
// that controls time
interface TTQTimeProvider {
    public int getMS();
}

class RealTimeProvider implements TTQTimeProvider {
    public int getMS() {
        return millis();
    }
}

class FakeTimeProvider implements TTQTimeProvider {
    private int ms = 0;

    public int getMS() {
        return ms;
    }

    public void addMS(int _ms) {
        ms += _ms;
    }
}

public class TimeTrackingQueue<T> extends Thread {
    private int maxTimeMillis;
    private LinkedList<Integer> timeList = new LinkedList<Integer>();
    private LinkedList<T> objectList = new LinkedList<T>();
    private TTQTimeProvider timeProvider;

    public TimeTrackingQueue(int _maxTimeMillis) {
        this(_maxTimeMillis, new RealTimeProvider());
    }

    public TimeTrackingQueue (int _maxTimeMillis, TTQTimeProvider _timeProvider) {
        this.maxTimeMillis = _maxTimeMillis;
        this.timeProvider = _timeProvider;
        start(); // start thread the checks expiration
    }

    public synchronized void push(T object) {
        timeList.push(timeProvider.getMS());
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
        if (!timeList.isEmpty() && timeList.peekLast() + maxTimeMillis < timeProvider.getMS()) {
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
            if(iter.next() + milliseconds < timeProvider.getMS()) {
                break; // we are done
            }
            else {
                endIndex = nextIndex;
            }
        }

        // sublist excludes the last index so we need to add 1 to be accurate
        return objectList.subList(0, endIndex + 1);
    }
}