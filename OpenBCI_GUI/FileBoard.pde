interface FileBoard {

    public int getTotalSamples();

    public float getTotalTimeSeconds();

    public int getCurrentSample();

    public float getCurrentTimeSeconds();

    public void goToIndex(int index);

    public boolean endOfFileReached();
};
