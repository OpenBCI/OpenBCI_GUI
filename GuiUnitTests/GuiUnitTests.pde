
import org.junit.runners.Suite;
import org.junit.runner.JUnitCore;
import org.junit.runner.Result;
import org.junit.runner.notification.Failure;
import org.junit.runner.RunWith;
import org.hamcrest.SelfDescribing;

static GuiUnitTests currentApplet;
final String failFileName = "UNITTEST_FAILURE";

// define a test suite with all test classes
// add test classes here
@RunWith(Suite.class)
@Suite.SuiteClasses({
        PacketLossTracker_UnitTests.class,
        PacketLossTrackerCytonSerialDaisy_UnitTests.class, 
        PacketLossTrackerGanglionBLE_UnitTests.class,  
        TimeTrackingQueue_UnitTests.class, })
public class AllTests {};

void setup() {
    currentApplet = this;

    boolean success = runTests();
    notifySuccess(success);
    exit();
}

private boolean runTests() {

    println("Running Test Classes...");
    Result result = JUnitCore.runClasses(AllTests.class);

    int failureCount = result.getFailureCount();
    int runCount = result.getRunCount();

    println("Tests Failed: " + failureCount + "/" + runCount);

    for (Failure failure : result.getFailures()) {
        println("\t" + failure.toString());
    }

    return result.wasSuccessful();
}

private void notifySuccess(boolean success) {
    // If there was a failure, write an empty file to notify python script
    File file = sketchFile(failFileName);
    file.delete();
    if(!success) {
        PrintWriter output = createWriter(failFileName);
        output.close();
    }
}

private void outputWarn(String str) {
    println("warn stub for tests");
}

private void outputInfo(String str) {
    println("info stub for tests");
}
