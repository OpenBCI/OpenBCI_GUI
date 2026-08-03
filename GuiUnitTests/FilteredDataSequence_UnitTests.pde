import org.junit.Assert;
import org.junit.Test;

public static class FilteredDataSequence_UnitTests {

    @Test
    public void acceptsContiguousFramesOfDifferentSizes() {
        FilteredDataSequence sequence = currentApplet.new FilteredDataSequence(0);

        sequence.accept(0, 1);
        sequence.accept(1, 7);
        sequence.accept(8, 25);

        Assert.assertEquals(33, sequence.getNextSampleIndex());
    }

    @Test(expected = IllegalStateException.class)
    public void rejectsDuplicateFrame() {
        FilteredDataSequence sequence = currentApplet.new FilteredDataSequence(0);
        sequence.accept(0, 10);
        sequence.accept(0, 10);
    }

    @Test(expected = IllegalStateException.class)
    public void rejectsMissingFrame() {
        FilteredDataSequence sequence = currentApplet.new FilteredDataSequence(0);
        sequence.accept(0, 10);
        sequence.accept(12, 5);
    }

    @Test(expected = IllegalArgumentException.class)
    public void rejectsNegativeFirstSampleIndex() {
        currentApplet.new FilteredDataSequence(-1);
    }

    @Test(expected = IllegalArgumentException.class)
    public void rejectsNegativeSampleCount() {
        FilteredDataSequence sequence = currentApplet.new FilteredDataSequence(0);
        sequence.accept(0, -1);
    }
}
