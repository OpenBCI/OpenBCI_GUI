import java.util.List;
import java.util.Arrays;
import org.junit.Assert;
import org.junit.Test;
import org.junit.Before;

public static class PacketLossTrackerCytonSerialDaisy_UnitTests {

    PacketLossTrackerCytonSerialDaisy packetLossTracker;

    @Before
    public void setUp() {
        int sampleIndexChannel = 0;
        int timestampChannel = 1;
        packetLossTracker = currentApplet.new PacketLossTrackerCytonSerialDaisy(
                sampleIndexChannel, timestampChannel);
    }

    @Test
    public void testNoPacketLoss() {
        double[][] data =  {
            {1, 1},
            {3, 3},
            {5, 5},
            {7, 7},
            {9, 9},
            {11, 11},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        Assert.assertEquals(input.size(), packetLossTracker.getTotalReceivedSamples());
        Assert.assertEquals(0, packetLossTracker.getTotalLostSamples());
    }

    @Test
    public void testNoPacketLossLooping() {
        double[][] data =  {
            {247, 247},
            {249, 249},
            {251, 251},
            {253, 253},
            {255, 255},
            {1, 1},
            {3, 3},
            {5, 5},
            {7, 7},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        Assert.assertEquals(input.size(), packetLossTracker.getTotalReceivedSamples());
        Assert.assertEquals(0, packetLossTracker.getTotalLostSamples());
    }

    @Test
    public void testPacketLoss() {
        double[][] data =  {
            {1, 1},
            {3, 3},
            {5, 5},
            {15, 15},
            {17, 17},
            {19, 19},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        Assert.assertEquals(input.size(), packetLossTracker.getTotalReceivedSamples());
        Assert.assertEquals(4, packetLossTracker.getTotalLostSamples());
    }

    @Test
    public void testPacketLossLooping() {
        double[][] data =  {
            {241, 241},
            {243, 243},
            {245, 245},
            {247, 247},
            {11, 11},
            {13, 13},
            {15, 15},
            {17, 17},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        Assert.assertEquals(input.size(), packetLossTracker.getTotalReceivedSamples());
        Assert.assertEquals(9, packetLossTracker.getTotalLostSamples());
    }

    @Test
    public void testPacketLossMultiple() {
        double[][] data1 =  {
            {245, 245},
            {247, 247},
            {249, 249},
            {251, 251},
        };

        double[][] data2 = {
            {9, 9},
            {11, 11},
            {13, 13},
            {15, 15},
        };

        double[][] data3 =  {
            {25, 25},
            {27, 27},
            {29, 29},
            {31, 31},
            {33, 33},
        };

        List<double[]> input1 = new ArrayList<double[]>(Arrays.asList(data1));
        packetLossTracker.addSamples(input1);
        
        List<double[]> input2 = new ArrayList<double[]>(Arrays.asList(data2));
        packetLossTracker.addSamples(input2);
        
        List<double[]> input3 = new ArrayList<double[]>(Arrays.asList(data3));
        packetLossTracker.addSamples(input3);

        int totalSize = input1.size() + input2.size() + input3.size();
        Assert.assertEquals(totalSize, packetLossTracker.getTotalReceivedSamples());
        Assert.assertEquals(10, packetLossTracker.getTotalLostSamples());
    }
}