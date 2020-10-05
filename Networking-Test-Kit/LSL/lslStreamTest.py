"""Example program to show how to read a multi-channel time series from LSL."""
import time
from pylsl import StreamInlet, resolve_stream
from time import sleep

# first resolve an EEG stream on the lab network
print("looking for an EEG stream...")
streams = resolve_stream('type', 'EEG')

# create a new inlet to read from the stream
inlet = StreamInlet(streams[0])
duration = 2

sleep(1)

def testLSLSamplingRate():
    start = time.time()
    numSamples = 0
    numChunks = 0

    while time.time() <= start + duration:
        # get chunks of samples
        samples, timestamp = inlet.pull_chunk()
        if timestamp:
            numChunks += 1
            print( len(samples) )
            numSamples += len(samples)

    print( "Number of Chunks == {}".format(numChunks) )
    print( "Avg Sampling Rate == {}".format(numSamples / duration) )


testLSLSamplingRate()