"""Example program to show how to read a multi-channel time series from LSL."""
import time
from pylsl import StreamInlet, resolve_stream
from time import sleep

# first resolve an EEG stream on the lab network
print("looking for an EEG stream...")
streams = resolve_stream('type', 'EEG')

# create a new inlet to read from the stream
inlet = StreamInlet(streams[0])
duration = 10

sleep(1)

def testLSLSamplingRate():
    start = time.time()
    totalNumSamples = 0
    validSamples = 0
    numChunks = 0
    print( "Testing Sampling Rates..." )

    while time.time() <= start + duration:
        # get chunks of samples
        chunk, timestamp = inlet.pull_chunk()
        if chunk:
            print("\nNew chunk!")
            numChunks += 1
            # print( len(chunk) )
            totalNumSamples += len(chunk)
            # print(chunk)
            for sample in chunk:
                print(sample)
                validSamples += 1

    print( "Number of Chunks and Samples == {} , {}".format(numChunks, totalNumSamples) )
    print( "Valid Samples and Duration == {} / {}".format(validSamples, duration) )
    print( "Avg Sampling Rate == {}".format(validSamples / duration) )


testLSLSamplingRate()