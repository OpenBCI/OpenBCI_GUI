import java.util.Stack;
import java.util.concurrent.locks.ReentrantLock;

public class FixedStack<T> extends Stack<T> {

    protected int maxSize;

    public FixedStack(int size) {
        super();
        this.maxSize = size;
    }

    public FixedStack() {
        super();
        maxSize = 1000;
    }

    // not thread safe with push but its temporary
    public void setSize(int size) {
        maxSize = size;
    }

    public void fill(T object) {
        for (int i = 0; i < maxSize; i++) {
            push(object);
        }
    }

    @Override
    public T push(T object) {
        while (this.size() >= maxSize) {
            this.remove(0);
        }
        return super.push(object);
    }
}

public class BufferedStack<T> extends FixedStack<T> implements Runnable {

    // idea-  push to internalStack when user calls push
    // pop from main stack and push to the main stack in another thread with timeout
    private FixedStack<T> internalStack;
    private int fps;
    private int samplingRate;
    private volatile boolean keepAlive;
    private ReentrantLock mutex = new ReentrantLock();

    public BufferedStack(int fps, int samplingRate, int size) {
        super(size);
        this.fps = fps;
        this.samplingRate = samplingRate;
        keepAlive = true;
        internalStack = new FixedStack<T>(size);
    }

    public BufferedStack(int fps, int samplingRate) {
        this(fps, samplingRate, 1000);
    }

    public BufferedStack(int samplingRate) {
        this(25, samplingRate, 1000);
    }

    @Override
    public void fill(T object) {
        List<T> data = new ArrayList<T>();
        for (int i = 0; i < maxSize; i++) {
            data.add (object);
        }

        this.addAll(data);
        internalStack.addAll(data);
    }

    @Override
    public T push(T object) {
        while (internalStack.size() >= maxSize) {
            internalStack.remove(0);
        }
        return internalStack.push(object);
    }

    @Override
    public void run() {
        int sleepTime = 1000 / fps;
        int packagesPerFrame = (samplingRate * fps) / 1000;
        while (keepAlive) {
            try {
                Thread.sleep(sleepTime);
            } catch (InterruptedException e) {
                e.printStackTrace();
                return;
            }
            List<T> data = internalStack.subList(0, packagesPerFrame);
            // need to sync write and read to\from this buffer
            mutex.lock();
            this.removeRange(0, data.size());
            this.addAll(data);
            mutex.unlock();
        }
    }

    @Override
    public T pop()
    {
        mutex.lock();
        T val = super.pop();
        mutex.unlock();
        return val;
    }

    @Override
    public int size()
    {
        mutex.lock();
        int size = super.size();
        mutex.unlock();
        return size;
    }

    @Override
    public List<T> subList(int fromIndex, int toIndex) {
        mutex.lock();
        List<T> res = super.subList(fromIndex, toIndex);
        mutex.unlock();
        List<T> cloned = new ArrayList(res);
        return cloned;
    }

    // can be done in finalize but its not good
    public void stop() {
        keepAlive = false;
    }
}
