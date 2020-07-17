import java.util.List;
import java.util.Arrays;
import org.junit.Assert;
import org.junit.Test;
import org.junit.Before;

public static class TimeTrackingQueue_UnitTests{

    TimeTrackingQueue timeTrackingQueue;

    @Before
    public void setUp() {
        timeTrackingQueue = currentApplet.new TimeTrackingQueue<Boolean>(1*1000 /* 1 seconds */);
    }

    @Test
    public void testLimitsTime() {
        // add 2 seconds worth of data
        for (int i=0; i<20; i++) {
            timeTrackingQueue.push(true);
            currentApplet.delay(100);
        }

        // make sure it only has 1 second worth of data
        Assert.assertEquals(timeTrackingQueue.size(), 10);
    }
}