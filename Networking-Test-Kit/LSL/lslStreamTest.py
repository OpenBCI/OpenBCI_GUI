"""Example program to show how to read a multi-channel time series from LSL."""
import time
from pylsl import StreamInlet, resolve_stream

# first resolve an EEG stream on the lab network
print("looking for an EEG stream...")
streams = resolve_stream('type', 'EEG')

# create a new inlet to read from the stream
inlet = StreamInlet(streams[0])


def testLSLSamplingRate():
    start = time.time()
    numSamples = 0
    while time.time() < start + 5:
    # get a new sample (you can also omit the timestamp part if you're not
    # interested in it)
        sample, timestamp = inlet.pull_chunk()
        # print(timestamp, sample)
        if timestamp:
            numSamples += 1
    print( numSamples / 5 )


testLSLSamplingRate()