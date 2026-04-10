public class CircularFIFODataBuffer {

    private float[][] buffer;
    private int numChannels;
    private int maxSamples;
    private int[] front;
    private int[] rear;
    private int[] count;

    // Constructor to initialize the circular FIFO buffer with a specified maxSamples
    public CircularFIFODataBuffer(int numChannels, int maxSamples) {
        this.numChannels = numChannels;
        this.maxSamples = maxSamples;
        initArrays();
    }

    // Method to add a new float value to the buffer
    public void add(int channel, float newValue) {
        if (count[channel] < maxSamples) {
            rear[channel] = (rear[channel] + 1) % maxSamples;
            buffer[channel][rear[channel]] = newValue;
            count[channel]++;
        } else {
            // Buffer is full, remove the oldest value
            front[channel] = (front[channel] + 1) % maxSamples;
            rear[channel] = (rear[channel] + 1) % maxSamples;
            buffer[channel][rear[channel]] = newValue;
        }
    }

    // Method to get the 2D float array from the buffer
    public float[][] getBuffer() {
        float[][] result = new float[numChannels][maxSamples];
        for (int channel = 0; channel < numChannels; channel++) {
            int index = front[channel];
            for (int sample = 0; sample < count[channel]; sample++) {
                result[channel][sample] = buffer[channel][index];
                index = (index + 1) % maxSamples;
            }
        }
        return result;
    }

    // Method to get the last 'lastSamples' samples from the buffer
    public float[][] getBuffer(int lastSamples) {
        float[][] result = new float[numChannels][lastSamples];
        for (int channel = 0; channel < numChannels; channel++) {
            int index = (rear[channel] - lastSamples + 1 + maxSamples) % maxSamples;
            for (int sample = 0; sample < lastSamples; sample++) {
                result[channel][sample] = buffer[channel][index];
                index = (index + 1) % maxSamples;
            }
        }
        return result;
    }

    public void initArrays() {
        this.buffer = new float[numChannels][maxSamples];
        this.front = new int[numChannels];
        this.rear = new int[numChannels];
        this.count = new int[numChannels];
        Arrays.fill(front, 0);
        Arrays.fill(rear, -1);
        Arrays.fill(count, 0);

        for (int i = 0; i < numChannels; i++) {
            for (int j = 0; j < maxSamples; j++) {
                add(i, 0.0f);
            }
        }
    }
}
