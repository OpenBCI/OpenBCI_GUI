import java.util.List;
import java.util.Arrays;
import org.junit.Assert;
import org.junit.Test;
import org.junit.Before;

public static class PacketLossTrackerGanglion_UnitTests{

    PacketLossTrackerGanglion packetLossTracker;
    FakeTimeProvider fakeTimeProvider;

    @Before
    public void setUp() {
        int sampleIndexChannel = 0;
        int timestampChannel = 1;
        fakeTimeProvider = currentApplet.new FakeTimeProvider();
        packetLossTracker = currentApplet.new PacketLossTrackerGanglion(
                sampleIndexChannel, timestampChannel, fakeTimeProvider);
        packetLossTracker.silent = true;
    }

    @Test
    public void testNoPacketLoss() {
        double[][] data =  {
            {0, 0},
            {1, 1},
            {1, 1},
            {2, 2},
            {2, 2},
            {3, 3},
            {3, 3},
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
            {97, 97},
            {97, 97},
            {98, 98},
            {98, 98},
            {99, 99},
            {99, 99},
            {100, 100},
            {100, 100},
            {0, 0},
            {1, 1},
            {1, 1},
            {2, 2},
            {2, 2},
            {3, 3},
            {3, 3},
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
            {1, 1},
            {1, 1},
            {2, 2},
            {2, 2},
            {3, 3},
            {3, 3},
            {7, 7},
            {7, 7},
            {8, 8},
            {8, 8},
            {9, 9},
            {9, 9},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(6, record.numLost);
    }

    @Test
    public void testPacketLossLooping() {
        double[][] data =  {
            {95, 95},
            {95, 95},
            {96, 96},
            {96, 96},
            {97, 97},
            {97, 97},
            {3, 3},
            {3, 3},
            {4, 4},
            {4, 4},
            {5, 5},
            {5, 5},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(11, record.numLost);
    }

    @Test
    public void testPacketLossLoopingNotZero() {
        double[][] data =  {
            {95, 95},
            {95, 95},
            {96, 96},
            {96, 96},
            {97, 97},
            {97, 97},
            {0, 0},
            {4, 4},
            {4, 4},
            {5, 5},
            {5, 5},
            {6, 6},
            {6, 6},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(12, record.numLost);
    }

    @Test
    public void testPacketLossOnlyZero() {
        double[][] data =  {
            {97, 97},
            {97, 97},
            {98, 98},
            {98, 98},
            {99, 99},
            {99, 99},
            {100, 100},
            {100, 100},
            {1, 1},
            {1, 1},
            {2, 2},
            {2, 2},
            {3, 3},
            {3, 3},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(1, record.numLost);
    }

    @Test
    public void testPacketLossEndOnly() {
        double[][] data =  {
            {95, 95},
            {95, 95},
            {96, 96},
            {96, 96},
            {97, 97},
            {97, 97},
            {0, 0},
            {1, 1},
            {1, 1},
            {2, 2},
            {2, 2},
            {3, 3},
            {3, 3},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(6, record.numLost);
    }

    @Test
    public void testPacketLossBeginningOnly() {
        double[][] data =  {
            {98, 98},
            {98, 98},
            {99, 99},
            {99, 99},
            {100, 100},
            {100, 100},
            {4, 4},
            {4, 4},
            {5, 5},
            {5, 5},
            {6, 6},
            {6, 6},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(7, record.numLost);
    }

    @Test
    public void testPacketLossBeginningOnlyNotZero() {
        double[][] data =  {
            {98, 98},
            {98, 98},
            {99, 99},
            {99, 99},
            {100, 100},
            {100, 100},
            {0, 0},
            {4, 4},
            {4, 4},
            {5, 5},
            {5, 5},
            {6, 6},
            {6, 6},
        };

        List<double[]> input = new ArrayList<double[]>(Arrays.asList(data));

        packetLossTracker.addSamples(input);

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(6, record.numLost);
    }

    @Test
    public void testPacketLossMultiple() {
        double[][] data1 =  {
            {95, 95},
            {95, 95},
            {96, 96},
            {96, 96},
            {97, 97},
            {97, 97},
        };

        double[][] data2 = {
            {3, 3},
            {3, 3},
            {4, 4},
            {4, 4},
            {5, 5},
            {5, 5},
        };

        double[][] data3 =  {
            {9, 9},
            {9, 9},
            {10, 10},
            {10, 10},
            {11, 11},
            {11, 11},
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
        Assert.assertEquals(17, record.numLost);
    }
}