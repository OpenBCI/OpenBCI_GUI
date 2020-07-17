import java.util.List;
import java.util.Arrays;
import org.junit.Assert;
import org.junit.Test;
import org.junit.Before;

public static class PacketLossTrackerCytonWifiDaisy_UnitTests {

    PacketLossTrackerCytonWifiDaisy packetLossTracker;
    FakeTimeProvider fakeTimeProvider;

    @Before
    public void setUp() {
        int sampleIndexChannel = 0;
        int timestampChannel = 1;
        fakeTimeProvider = currentApplet.new FakeTimeProvider();
        packetLossTracker = currentApplet.new PacketLossTrackerCytonWifiDaisy(
                sampleIndexChannel, timestampChannel, fakeTimeProvider);
    }

    @Test
    public void testNoPacketLoss() {
        double[][] data =  {
            {0, 0},
            {2, 2},
            {4, 4},
            {6, 6},
            {8, 8},
            {10, 10},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(0, record.numLost);
    }

    @Test
    public void testNoPacketLossLooping() {
        double[][] data =  {
            {246, 246},
            {248, 248},
            {250, 250},
            {252, 252},
            {254, 254},
            {0, 0},
            {2, 2},
            {4, 4},
            {6, 6},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(0, record.numLost);
    }

    @Test
    public void testPacketLoss() {
        double[][] data =  {
            {0, 0},
            {2, 2},
            {4, 4},
            {14, 14},
            {16, 16},
            {18, 18},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(4, record.numLost);
    }

    @Test
    public void testPacketLossLooping() {
        double[][] data =  {
            {240, 240},
            {242, 242},
            {244, 244},
            {246, 246},
            {10, 10},
            {12, 12},
            {14, 14},
            {16, 16},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(9, record.numLost);
    }
    

    @Test
    public void testPacketLossEndOnly() {
        double[][] data =  {
            {240, 240},
            {242, 242},
            {244, 244},
            {246, 246},
            {0, 0},
            {2, 2},
            {4, 4},
            {6, 6},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(4, record.numLost);
    }

    @Test
    public void testPacketLossBeginningOnly() {
        double[][] data =  {
            {248, 248},
            {250, 250},
            {252, 252},
            {254, 254},
            {10, 10},
            {12, 12},
            {14, 14},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(5, record.numLost);
    }

    @Test
    public void testPacketLossMultiple() {
        double[][] data1 =  {
            {244, 244},
            {246, 246},
            {248, 248},
            {250, 250},
        };

        double[][] data2 = {
            {8, 8},
            {10, 10},
            {12, 12},
            {14, 14},
        };

        double[][] data3 =  {
            {24, 24},
            {26, 26},
            {28, 28},
            {30, 30},
            {32, 32},
        };

        List<double[]> input1 = new ArrayList<double[]>(Arrays.asList(data1));
        packetLossTracker.addSamples(input1);
        
        List<double[]> input2 = new ArrayList<double[]>(Arrays.asList(data2));
        packetLossTracker.addSamples(input2);
        
        List<double[]> input3 = new ArrayList<double[]>(Arrays.asList(data3));
        packetLossTracker.addSamples(input3);

        int totalSize = input1.size() + input2.size() + input3.size();
        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(totalSize, record.numReceived);
        Assert.assertEquals(10, record.numLost);
    }
}