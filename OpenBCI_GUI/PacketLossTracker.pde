import java.util.List;

class PacketLossTracker {

    private int sampleIndexChannel;
    private int timestampChannel;
    private double[] lastSample = null;
    private int lastSampleIndexLocation;
    private boolean newStream = false;

    private int receivedSamplesSession = 0;
    private int receivedSamplesStream = 0;
    private int lostSamplesSession = 0;
    private int lostSamplesStream = 0;

    protected ArrayList<Integer> sampleIndexArray = new ArrayList<Integer>();

    PacketLossTracker(int _sampleIndexChannel, int _timestampChannel, int _minSampleIndex, int _maxSampleIndex) {        
        this(_sampleIndexChannel, _timestampChannel);

        // add indices to array of indices
        for (int i = _minSampleIndex; i <= _maxSampleIndex; i++) {
            sampleIndexArray.add(i);
        }
    }

    PacketLossTracker(int _sampleIndexChannel, int _timestampChannel) {
        sampleIndexChannel = _sampleIndexChannel;
        timestampChannel = _timestampChannel;
    }

    public void onStreamStart() {
        receivedSamplesStream = 0;
        lostSamplesStream = 0;
        newStream = true;
        reset();
    }

    public int getReceivedSamplesSession() {
        return receivedSamplesSession;
    }

    public int getReceivedSamplesStream() {
        return receivedSamplesStream;
    }

    public int getLostSamplesSession() {
        return lostSamplesSession;
    }

    public int getLostSamplesStream() {
        return lostSamplesStream;
    }

    public void addSamples(List<double[]> newSamples) {
        receivedSamplesSession += newSamples.size();
        receivedSamplesStream += newSamples.size();

        for (double[] sample : newSamples) {
            int currentSampleIndex = (int)(sample[sampleIndexChannel]);

            // handle new stream start
            if (newStream) {
                // wait until we restart the sample index array. this handles the case
                // of starting a new stream and there are still samples from the
                // previous stream in the serial buffer
                if (currentSampleIndex == sampleIndexArray.get(0)) {
                    lastSample = sample;
                    lastSampleIndexLocation = 0;
                    newStream = false;
                }
                continue;
            }

            // handle first call
            if (lastSample == null) {
                lastSample = sample;
                lastSampleIndexLocation = sampleIndexArray.indexOf(currentSampleIndex);
                continue;
            }

            incrementLastSampleIndexLocation();

            int numSamplesLost = 0;

            while (sampleIndexArray.get(lastSampleIndexLocation) != currentSampleIndex) {
                incrementLastSampleIndexLocation();
                numSamplesLost++;

                if (numSamplesLost > sampleIndexArray.size()) {
                    // we looped the entire array, the new sample is not part of the current array
                    println("WATRNING: LOOPED AROUJD");
                    break;
                }
            }

            if (numSamplesLost > 0) {
                // we lost some samples
                onSamplesLost(numSamplesLost, lastSample, sample);
            }

            lastSample = sample;
        }
    }

    private void incrementLastSampleIndexLocation() {
        // increment index location, advance through list of indexes
        // make sure to loop around if we reach the end of the list
        lastSampleIndexLocation ++;
        lastSampleIndexLocation = lastSampleIndexLocation % sampleIndexArray.size();
    }

    private void onSamplesLost(int numLostSamples, double[] previousSample, double[] nextSample) {
        lostSamplesSession += numLostSamples;
        lostSamplesStream += numLostSamples;

        // TODO: for now, print the packet loss event. We will need to store packet loss event data
        // to report it in the widget.
        println("WARNING: Lost " + numLostSamples + " Samples Between " +  (int)previousSample[sampleIndexChannel] + "-" + (int)nextSample[sampleIndexChannel]);
    }

    protected void reset() {
        lastSample = null;
    }
}

// sample index range 1-255, odd numbers only (skips evens)
class PacketLossTrackerCytonSerialDaisy extends PacketLossTracker {

    PacketLossTrackerCytonSerialDaisy(int _sampleIndexChannel, int _timestampChannel) {
        super(_sampleIndexChannel, _timestampChannel);

        // add indices to array of indices
        // 1-255, odd numbers only (skips evens)
        int firstIndex = 1;
        int lastIndex = 255;
        for (int i = firstIndex; i <= lastIndex; i += 2) {
            sampleIndexArray.add(i);
        }
    }
}

// sample index range 0-254, even numbers only (skips odds)
class PacketLossTrackerCytonWifiDaisy extends PacketLossTracker {

    PacketLossTrackerCytonWifiDaisy(int _sampleIndexChannel, int _timestampChannel) {
        super(_sampleIndexChannel, _timestampChannel);

        // add indices to array of indices
        // 0-254, even numbers only (skips odds)
        int firstIndex = 0;
        int lastIndex = 254;
        for (int i = firstIndex; i <= lastIndex; i += 2) {
            sampleIndexArray.add(i);
        }
    }
}

// with accel: sample index range 0-100, all sample indexes are duplicated except for zero.
// eg 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, ... , 99, 99, 100, 100, 0, 1, 1, 2, 2, 3, 3, ...
// without acceL: sample 0, then 101-200
class PacketLossTrackerGanglion extends PacketLossTracker {

    ArrayList<Integer> sampleIndexArrayAccel = new ArrayList<Integer>();
    ArrayList<Integer> sampleIndexArrayNoAccel = new ArrayList<Integer>();

    PacketLossTrackerGanglion(int _sampleIndexChannel, int _timestampChannel) {
        super(_sampleIndexChannel, _timestampChannel);

        {
            // add indices to array of indices
            //  With accel: 0-100, all sample indexes are duplicated except for zero
            sampleIndexArrayAccel.add(0);
            int firstIndex = 1;
            int lastIndex = 100;
            for (int i = firstIndex; i <= lastIndex; i++) {
                sampleIndexArrayAccel.add(i);
                sampleIndexArrayAccel.add(i);
            }
        }

        {
            // add indices to array of indices
            // Without accel: 0, then 101 to 200, all sample indexes are duplicated except for zero
            sampleIndexArrayNoAccel.add(0);
            int firstIndex = 101;
            int lastIndex = 200;
            for (int i = firstIndex; i <= lastIndex; i++) {
                sampleIndexArrayNoAccel.add(i);
                sampleIndexArrayNoAccel.add(i);
            }
        }

        setAccelerometerActive(true);
    }

    public void setAccelerometerActive(boolean active) {
        // choose correct array based on wether accel is active or not
        if (active) {
            sampleIndexArray = sampleIndexArrayAccel;
        }
        else {
            sampleIndexArray = sampleIndexArrayNoAccel;
        }

        reset();
    }
}