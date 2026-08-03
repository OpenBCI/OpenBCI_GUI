/**
 * Tracks the sample range written to a filtered recording.
 *
 * The filtered writer receives data after the GUI processing pass, while the
 * raw writer receives the same board frame before processing.  This guard
 * makes gaps and duplicate frames explicit instead of silently producing a
 * filtered file that no longer lines up with the raw recording.
 */
class FilteredDataSequence {
    private long nextSampleIndex;

    FilteredDataSequence(long firstSampleIndex) {
        if (firstSampleIndex < 0) {
            throw new IllegalArgumentException("First sample index must be non-negative.");
        }
        nextSampleIndex = firstSampleIndex;
    }

    public void accept(long firstSampleIndex, int sampleCount) {
        if (sampleCount < 0) {
            throw new IllegalArgumentException("Sample count must be non-negative.");
        }
        if (firstSampleIndex != nextSampleIndex) {
            throw new IllegalStateException(
                "Expected filtered sample " + nextSampleIndex +
                " but received " + firstSampleIndex + "."
            );
        }
        nextSampleIndex += sampleCount;
    }

    public long getNextSampleIndex() {
        return nextSampleIndex;
    }
}
