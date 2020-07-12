import java.util.List;
import java.util.Arrays;
import org.junit.Assert;
import org.junit.Test;
import org.junit.Before;

public static class PacketLossTracker_UnitTests{

    PacketLossTracker packetLossTracker;

    @Before
    public void setUp() {
        int sampleIndexChannel = 0;
        int timestampChannel = 1;
        int minSampleIndex = 0;
        int maxSampleIndex = 255;
        packetLossTracker = currentApplet.new PacketLossTracker(
                sampleIndexChannel, timestampChannel, minSampleIndex, maxSampleIndex);
    }

    @Test
    public void testNoPacketLoss() {
        double[][] data =  {
            {0, 0},
            {1, 1},
            {2, 2},
            {3, 3},
            {4, 4},
            {5, 5},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        Assert.assertEquals(input.size(), packetLossTracker.getReceivedSamplesSession());
        Assert.assertEquals(0, packetLossTracker.getLostSamplesSession());
    }

    @Test
    public void testNoPacketLossLooping() {
        double[][] data =  {
            {252, 252},
            {253, 253},
            {254, 254},
            {255, 255},
            {0, 0},
            {1, 1},
            {2, 2},
            {3, 3},
            {4, 4},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        Assert.assertEquals(input.size(), packetLossTracker.getReceivedSamplesSession());
        Assert.assertEquals(0, packetLossTracker.getLostSamplesSession());
    }

    @Test
    public void testPacketLoss() {
        double[][] data =  {
            {0, 0},
            {1, 1},
            {2, 2},
            {7, 7},
            {8, 8},
            {9, 9},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        Assert.assertEquals(input.size(), packetLossTracker.getReceivedSamplesSession());
        Assert.assertEquals(4, packetLossTracker.getLostSamplesSession());
    }

    @Test
    public void testPacketLossLooping() {
        double[][] data =  {
            {249, 249},
            {250, 250},
            {251, 251},
            {252, 252},
            {6, 6},
            {7, 7},
            {8, 8},
            {9, 9},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        Assert.assertEquals(input.size(), packetLossTracker.getReceivedSamplesSession());
        Assert.assertEquals(9, packetLossTracker.getLostSamplesSession());
    }

    @Test
    public void testPacketLossEndOnly() {
        double[][] data =  {
            {247, 247},
            {248, 248},
            {249, 249},
            {250, 250},
            {0, 0},
            {1, 1},
            {2, 2},
            {3, 3},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        Assert.assertEquals(input.size(), packetLossTracker.getReceivedSamplesSession());
        Assert.assertEquals(5, packetLossTracker.getLostSamplesSession());
    }

    @Test
    public void testPacketLossBeginningOnly() {
        double[][] data =  {
            {252, 252},
            {253, 253},
            {254, 254},
            {255, 255},
            {6, 6},
            {7, 7},
            {8, 8},
            {9, 9},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        Assert.assertEquals(input.size(), packetLossTracker.getReceivedSamplesSession());
        Assert.assertEquals(6, packetLossTracker.getLostSamplesSession());
    }

    @Test
    public void testPacketLossMultiple() {
        double[][] data1 =  {
            {249, 249},
            {250, 250},
            {251, 251},
            {252, 252},
        };

        double[][] data2 = {
            {6, 6},
            {7, 7},
            {8, 8},
            {9, 9},
        };

        double[][] data3 =  {
            {15, 15},
            {16, 16},
            {17, 17},
            {18, 18},
            {19, 19},
        };

        List<double[]> input1 = new ArrayList<double[]>(Arrays.asList(data1));
        packetLossTracker.addSamples(input1);
        
        List<double[]> input2 = new ArrayList<double[]>(Arrays.asList(data2));
        packetLossTracker.addSamples(input2);
        
        List<double[]> input3 = new ArrayList<double[]>(Arrays.asList(data3));
        packetLossTracker.addSamples(input3);

        int totalSize = input1.size() + input2.size() + input3.size();
        Assert.assertEquals(totalSize, packetLossTracker.getReceivedSamplesSession());
        Assert.assertEquals(14, packetLossTracker.getLostSamplesSession());
    }

    @Test
    public void testPacketLossAcrossStreams() {
        double[][] data1 =  {
            {0, 0},
            {1, 1},
            {2, 2},
            {7, 7},
            {8, 8},
            {9, 9},
        };

        double[][] data2=  {
            {10, 10},
            {11, 11},
            {0, 0},
            {1, 1},
            {2, 2},
            {8, 8},
            {9, 9},
            {10, 10},
        };

        List<double[]> input1 = new ArrayList<double[]>(Arrays.asList(data1));
        packetLossTracker.addSamples(input1);

        // start a new stream
        packetLossTracker.onStreamStart();

        List<double[]> input2 = new ArrayList<double[]>(Arrays.asList(data2));
        packetLossTracker.addSamples(input2);

        // we lost 9 samples in the entire session, but only 5 samples in the last stream
        Assert.assertEquals(9, packetLossTracker.getLostSamplesSession());
        Assert.assertEquals(5, packetLossTracker.getLostSamplesStream());
    }
}