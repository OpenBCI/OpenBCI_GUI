import java.util.List;
import java.util.Arrays;
import org.junit.Assert;
import org.junit.Test;
import org.junit.Before;

public static class PacketLossTracker_UnitTests {

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
            {5, 5}
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        Assert.assertEquals(input.size(), packetLossTracker.getTotalReceivedSamples());
        Assert.assertEquals(0, packetLossTracker.getTotalLostSamples());
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
            {4, 4}
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        Assert.assertEquals(input.size(), packetLossTracker.getTotalReceivedSamples());
        Assert.assertEquals(0, packetLossTracker.getTotalLostSamples());
    }

    @Test
    public void testPacketLoss() {
        double[][] data =  {
            {0, 0},
            {1, 1},
            {2, 2},
            {7, 3},
            {8, 4},
            {9, 5}
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        Assert.assertEquals(input.size(), packetLossTracker.getTotalReceivedSamples());
        Assert.assertEquals(4, packetLossTracker.getTotalLostSamples());
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

        Assert.assertEquals(input.size(), packetLossTracker.getTotalReceivedSamples());
        Assert.assertEquals(9, packetLossTracker.getTotalLostSamples());
    }
}