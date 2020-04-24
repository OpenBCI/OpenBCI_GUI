import java.util.Stack;


public class FixedStack<T> extends Stack<T> {
    private int maxSize;

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