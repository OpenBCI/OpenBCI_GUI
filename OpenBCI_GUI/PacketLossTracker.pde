import java.util.List;

class PacketLossTracker {

    private int sampleIndexChannel;
    private int timestampChannel;
    protected int minSampleIndex;
    protected int maxSampleIndex;
    private double[] lastSample = null;

    private int totalReceivedSamples = 0;
    private int totalLostSamples = 0;

    PacketLossTracker(int _sampleIndexChannel, int _timestampChannel, int _minSampleIndex, int _maxSampleIndex) {
        sampleIndexChannel = _sampleIndexChannel;
        timestampChannel = _timestampChannel;
        minSampleIndex = _minSampleIndex;
        maxSampleIndex = _maxSampleIndex;
    }

    public int getTotalReceivedSamples() {
        return totalReceivedSamples;
    }

    public int getTotalLostSamples() {
        return totalLostSamples;
    }

    public void addSamples(List<double[]> newSamples) {
        for (double[] sample : newSamples) {

            totalReceivedSamples++;

            // handle first call
            if (lastSample == null) {
                lastSample = sample;
                continue;
            }

            int sampleIndex = (int)(sample[sampleIndexChannel]);
            int lastSampleIndex = (int)(lastSample[sampleIndexChannel]);

            int numLostSamples = calculateLostSamples(lastSampleIndex, sampleIndex);
            if (numLostSamples > 0) {
                onSamplesLost(numLostSamples, lastSample, sample);
            }

            lastSample = sample;

        }
    }

    protected int calculateLostSamples(int previousSampleIndex, int nextSampleIndex) {
        int numLostSamples = 0;

        // special case: loop back
        if (nextSampleIndex < previousSampleIndex) {
            // add up the count of any lost samples
            // eg, if maxSampleIndex is 255, previousSampleIndex is 252 and nextSampleIndex is 4
            // we will count 7 lost samples
            numLostSamples += maxSampleIndex - previousSampleIndex;
            numLostSamples += nextSampleIndex - minSampleIndex;
        }
        else {
            numLostSamples = nextSampleIndex - previousSampleIndex - 1;
        }

        return numLostSamples;
    }

    private void onSamplesLost(int numLostSamples, double[] previousSample, double[] nextSample) {
        totalLostSamples += numLostSamples;

        // TODO: for now, print the packet loss event. We will need to store packet loss event data
        // to report it in the widget.
        println("WARNING: Lost " + numLostSamples + " Samples Between " +  (int)previousSample[sampleIndexChannel] + "-" + (int)nextSample[sampleIndexChannel]);
    }
}

// sample index range 1-255, odd numbers only (skips evens)
class PacketLossTrackerCytonSerialDaisy extends PacketLossTracker {

    PacketLossTrackerCytonSerialDaisy(int _sampleIndexChannel, int _timestampChannel) {
        super(_sampleIndexChannel, _timestampChannel, 1, 255);
    }

    @Override
    protected int calculateLostSamples(int previousSampleIndex, int nextSampleIndex) {
        int numLostSamples = 0;
        
        // special case: loop back
        if (nextSampleIndex < previousSampleIndex) {
            // add up the count of any lost samples
            // eg, if maxSampleIndex is 255, previousSampleIndex is 253 and nextSampleIndex is 3
            // we will count 2 lost samples (255 and 1)
            numLostSamples += (maxSampleIndex - previousSampleIndex) / 2;
            numLostSamples += (nextSampleIndex - minSampleIndex) / 2;
        }
        else {
            numLostSamples = (nextSampleIndex - previousSampleIndex - 2) / 2;
        }

        return numLostSamples;
    }
}

// sample index range 0-254, even numbers only (skips odds)
class PacketLossTrackerCytonWifiDaisy extends PacketLossTracker {

    PacketLossTrackerCytonWifiDaisy(int _sampleIndexChannel, int _timestampChannel) {
        super(_sampleIndexChannel, _timestampChannel, 0, 254);
    }

    @Override
    protected int calculateLostSamples(int previousSampleIndex, int nextSampleIndex) {
        int numLostSamples = 0;
        
        // special case: loop back
        if (nextSampleIndex < previousSampleIndex) {
            // add up the count of any lost samples
            // eg, if maxSampleIndex is 254, previousSampleIndex is 252 and nextSampleIndex is 4
            // we will count 3 lost samples (254, 0, 2)
            numLostSamples += (maxSampleIndex - previousSampleIndex) / 2;
            numLostSamples += (nextSampleIndex - minSampleIndex) / 2;
        }
        else {
            numLostSamples = (nextSampleIndex - previousSampleIndex - 2) / 2;
        }

        return numLostSamples;
    }
}

// sample index range 0-100, all sample indexes are duplicated except for zero.
// eg 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, ... , 99, 99, 100, 100, 0, 1, 1, 2, 2, 3, 3, ...
class PacketLossTrackerGanglion extends PacketLossTracker {

    PacketLossTrackerGanglion(int _sampleIndexChannel, int _timestampChannel) {
        super(_sampleIndexChannel, _timestampChannel, 0, 100);
    }

    @Override
    protected int calculateLostSamples(int previousSampleIndex, int nextSampleIndex) {
        int numLostSamples = 0;

        // special case: loop back
        if (nextSampleIndex < previousSampleIndex) {
            // add up the count of any lost samples
            // eg, if maxSampleIndex is 100, previousSampleIndex is 98 and nextSampleIndex is 2
            // we will count 7 lost samples (99, 99, 100, 100, 0, 1, 1)
            numLostSamples += (maxSampleIndex - previousSampleIndex) * 2;
            if (nextSampleIndex > minSampleIndex) {
                numLostSamples ++;
                numLostSamples += (nextSampleIndex - minSampleIndex - 1) * 2;
            }
        }
        else {
            numLostSamples = (nextSampleIndex - previousSampleIndex - 1 ) * 2;
        }

        return numLostSamples;
    }
}