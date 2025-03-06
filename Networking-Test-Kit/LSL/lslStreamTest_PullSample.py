"""Here we show that we can use push_sample to send and pull_chunk to receive a sample."""
import time
from pylsl import StreamInlet, resolve_byprop
from time import sleep

# first resolve an EEG stream on the lab network
print("looking for an EEG stream...")
streams = resolve_byprop('type', 'FOCUS')

# create a new inlet to read from the stream
inlet = StreamInlet(streams[0])
duration = 5

sleep(1)

def testLSLSamplingRate():
    start = time.time()
    totalNumSamples = 0
    validSamples = 0
    numChunks = 0
    print( "Testing Sampling Rates..." )

    while time.time() <= start + duration:
        # print(time.time())
        # get chunks of samples
        sample, timestamp = inlet.pull_chunk()
        if sample:
            print(sample)
            validSamples += 1

    #print( "Number of Chunks and Samples == {} , {}".format(numChunks, totalNumSamples) )
    #print( "Valid Samples and Duration == {} / {}".format(validSamples, duration) )
    print( "Avg Sampling Rate == {}".format(validSamples / duration) )


testLSLSamplingRate()