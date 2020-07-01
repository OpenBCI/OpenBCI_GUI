import org.junit.runner.JUnitCore;
import org.junit.runner.Result;
import org.junit.runner.notification.Failure;
import org.hamcrest.SelfDescribing;

static OpenBCI_GUI_unittests currentApplet;

void setup() {
    currentApplet = this;

    runTests();
    exit();
}

private void runTests() {

    Result result = JUnitCore.runClasses(PacketLossTracker_UnitTests.class);

    int failureCount = result.getFailureCount();
    int runCount = result.getRunCount();

    println("Test Failed: " + failureCount + "/" + runCount);

    for (Failure failure : result.getFailures()) {
        println("\t" + failure.toString());
    }
}