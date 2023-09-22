import java.util.List;
import java.util.Arrays;
import org.junit.Assert;
import org.junit.Test;
import org.junit.Before;

public static class PacketLossTracker_UnitTests{

    PacketLossTracker packetLossTracker;
    FakeTimeProvider fakeTimeProvider;

    @Before
    public void setUp() {
        int sampleIndexChannel = 0;
        int timestampChannel = 1;
        int minSampleIndex = 0;
        int maxSampleIndex = 255;
        fakeTimeProvider = currentApplet.new FakeTimeProvider();
        packetLossTracker = currentApplet.new PacketLossTracker(
                sampleIndexChannel, timestampChannel, minSampleIndex, maxSampleIndex, fakeTimeProvider);
        packetLossTracker.silent = true;
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

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(0, record.numLost);
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

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(0, record.numLost);
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

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(4, record.numLost);
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

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(9, record.numLost);
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

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(5, record.numLost);
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

        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(input.size(), record.numReceived);
        Assert.assertEquals(6, record.numLost);
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
        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        Assert.assertEquals(totalSize, record.numReceived);
        Assert.assertEquals(14, record.numLost);
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
        PacketRecord record = packetLossTracker.getSessionPacketRecord();
        PacketRecord streamRecord = packetLossTracker.getStreamPacketRecord();
        Assert.assertEquals(9, record.numLost);
        Assert.assertEquals(5, streamRecord.numLost);
    }

    
    @Test
    public void testLastMillisPacketRecord() {
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
        };

        List<double[]> input1 = new ArrayList<double[]>(Arrays.asList(data1));
        List<double[]> input2 = new ArrayList<double[]>(Arrays.asList(data2));
        List<double[]> input3 = new ArrayList<double[]>(Arrays.asList(data3));

        packetLossTracker.addSamples(input1);
        fakeTimeProvider.addMS(100);
        packetLossTracker.addSamples(input2);
        fakeTimeProvider.addMS(100);
        packetLossTracker.addSamples(input3);
        fakeTimeProvider.addMS(50);

        // let the expiration tread do work
        currentApplet.delay(100);

        List<PacketRecord> allRecords = packetLossTracker.getAllPacketRecordsForLast(500);
        PacketRecord completecumulativeRecord = packetLossTracker.getCumulativePacketRecordForLast(500);

        List<PacketRecord> partialRecords = packetLossTracker.getAllPacketRecordsForLast(200);
        PacketRecord partialCumulativeRecord = packetLossTracker.getCumulativePacketRecordForLast(200);
        
        Assert.assertEquals(3, allRecords.size());
        Assert.assertEquals(4, allRecords.get(2).numReceived);
        Assert.assertEquals(4, allRecords.get(1).numReceived);
        Assert.assertEquals(9, allRecords.get(1).numLost);
        Assert.assertEquals(4, allRecords.get(0).numReceived);
        Assert.assertEquals(5, allRecords.get(0).numLost);

        Assert.assertEquals(12, completecumulativeRecord.numReceived);
        Assert.assertEquals(14, completecumulativeRecord.numLost);

        Assert.assertArrayEquals(allRecords.subList(0, 2).toArray(), partialRecords.toArray());

        Assert.assertEquals(8, partialCumulativeRecord.numReceived);
        Assert.assertEquals(14, partialCumulativeRecord.numLost);
    }
}