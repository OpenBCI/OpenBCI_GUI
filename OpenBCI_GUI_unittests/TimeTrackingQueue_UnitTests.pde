import java.util.List;
import java.util.Arrays;
import org.junit.Assert;
import org.junit.Test;
import org.junit.Before;

public static class TimeTrackingQueue_UnitTests{

    TimeTrackingQueue timeTrackingQueue;

    @Before
    public void setUp() {
        timeTrackingQueue = currentApplet.new TimeTrackingQueue<Boolean>(1000 /* 1 seconds */);
    }

    @Test
    public void testLimitsSizeByTime() {
        // add 2 seconds worth of data
        for (int i=0; i<20; i++) {
            currentApplet.delay(100);
            timeTrackingQueue.push(true);
        }

        // make sure it only has 1 second worth of data
        Assert.assertEquals(10, timeTrackingQueue.size());
    }

    @Test
    public void testLimitsSizeChunkyData() {
        // add 2 seconds worth of data
        for (int i=0; i<20; i++) {
            currentApplet.delay(100);
            timeTrackingQueue.push(true);
            timeTrackingQueue.push(true);
            timeTrackingQueue.push(true);
            timeTrackingQueue.push(true);
            timeTrackingQueue.push(true);
            timeTrackingQueue.push(true);
        }

        // make sure it only has 1 second worth of data
        Assert.assertEquals(60, timeTrackingQueue.size());
    }

    @Test
    public void testContinuesToExpire() {
        // add 2 seconds worth of data
        for (int i=0; i<20; i++) {
            currentApplet.delay(100);
            timeTrackingQueue.push(true);
        }

        // make sure it only has 1 second worth of data
        Assert.assertEquals(10, timeTrackingQueue.size());

        // wait half a second
        currentApplet.delay(500);

        // make sure it only has half a second worth of data
        Assert.assertEquals(5, timeTrackingQueue.size());

        // wait a second
        currentApplet.delay(1000);

        // make sure it's empty
        Assert.assertEquals(0, timeTrackingQueue.size());
    }

    @Test
    public void testEmptyListReturnsEmpty() {
        // make sure it's empty
        Assert.assertEquals(0, timeTrackingQueue.size());

        List<Boolean> data = timeTrackingQueue.getLastData(1000);
        Assert.assertEquals(0, data.size());
    }

    @Test
    public void testSublistChunkyData() {
        // add 2 seconds worth of data
        for (int i=0; i<20; i++) {
            currentApplet.delay(100);
            timeTrackingQueue.push(true);
            timeTrackingQueue.push(true);
            timeTrackingQueue.push(true);
            timeTrackingQueue.push(true);
            timeTrackingQueue.push(true);
            timeTrackingQueue.push(true);
        }

        // 500ms of data
        List<Boolean> halfSecData = timeTrackingQueue.getLastData(500);
        // asking for more data than avaliable
        List<Boolean> fourSecData = timeTrackingQueue.getLastData(4000);

        // make sure it only has 500ms worth of data
        Assert.assertEquals(30, halfSecData.size());
        // make sure it only has 1000ms worth of data
        Assert.assertEquals(60, fourSecData.size());
    }
}