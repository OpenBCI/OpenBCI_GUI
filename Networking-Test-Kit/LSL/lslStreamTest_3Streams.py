"""Example program to demonstrate how to read a multi-channel time-series
from LSL in a chunk-by-chunk manner (which is more efficient).

Please restart this script if you change one of the data types.
Also, the # Chan should match the data type (Examples: 1 for Focus, 3 for Accel)

"""

from pylsl import StreamInlet, resolve_stream
import time

numStreams = 3
# first resolve an EEG stream on the lab network
print("looking for an EEG stream...")
stream1 = resolve_stream('type', 'EEG')
stream2 = resolve_stream('type', 'AUX')
stream3 = resolve_stream('type', 'FFT')

# create a new inlet to read from the stream
inlet = StreamInlet(stream1[0])
inlet2 = StreamInlet(stream2[0])
inlet3 = StreamInlet(stream3[0])

def testLSLSamplingRates():
    print( "Testing Sampling Rates..." )
    start = time.time()
    numSamples1 = 0
    numSamples2 = 0
    numSamples3 = 0
    while time.time() < start + 5:
    # get a new sample (you can also omit the timestamp part if you're not
    # interested in it)
        for i in range(numStreams):
            if i == 0:
                chunk, timestamps = inlet.pull_chunk()
                if timestamps:
                    numSamples1 += 1
            elif i == 1:
                chunk, timestamps2 = inlet2.pull_chunk()
                if timestamps2:
                    numSamples2 += 1
            elif i == 2:
                chunk, timestamps3 = inlet3.pull_chunk()
                if timestamps3:
                    numSamples3 += 1
            #print("Stream", i + 1, " == ", chunk)
    print( "Stream 1 Sampling Rate == ", numSamples1, " | Type : EEG")
    print( "Stream 2 Sampling Rate == ", numSamples2, " | Type : AUX")
    print( "Stream 3 Sampling Rate == ", numSamples3, " | Type : FFT")


testLSLSamplingRates()