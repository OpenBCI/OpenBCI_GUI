"""Example program to demonstrate how to read a multi-channel time-series
from LSL in a chunk-by-chunk manner (which is more efficient).

Please restart this script if you change one of the data types.
Also, the # Chan should match the data type (Examples: 1 for Focus, 3 for Accel)

"""

from pylsl import StreamInlet, resolve_stream
import time

numStreams = 3
duration_seconds = 10
# first resolve an EEG stream on the lab network
print("looking for an EEG stream...")
stream_1 = resolve_stream('type', 'EEG')
stream_2 = resolve_stream('type', 'AUX')
stream_3 = resolve_stream('type', 'FOCUS')

# create a new inlet to read from the stream
inlet = StreamInlet(stream_1[0])
inlet_2 = StreamInlet(stream_2[0])
inlet_3 = StreamInlet(stream_3[0])

def testLSLSamplingRates():
    print( "Testing Sampling Rates for {} seconds".format(duration_seconds) )
    start = time.time()
    num_samples_1 = 0
    num_samples_2 = 0
    num_samples_3 = 0
    while time.time() < start + duration_seconds:
    # get a new sample (you can also omit the timestamp part if you're not
    # interested in it)
        for i in range(numStreams):
            if i == 0:
                chunk, timestamps = inlet.pull_chunk()
                if timestamps:
                    print("Stream 1 Chunk: ", chunk)
                    for sample in chunk:
                        num_samples_1 += 1
            elif i == 1:
                chunk, timestamps_2 = inlet_2.pull_chunk()
                if timestamps_2:
                    print("Stream 2 Chunk: ", chunk)
                    for sample in chunk:
                        num_samples_2 += 1
            elif i == 2:
                chunk, timestamps_3 = inlet_3.pull_chunk()
                if timestamps_3:
                    print("Stream 3 Chunk: ", chunk)
                    for sample in chunk:
                        num_samples_3 += 1
            #print("Stream", i + 1, " == ", chunk)
    print( "Stream 1 Sampling Rate == ", num_samples_1 / duration_seconds, " | Type : EEG")
    print( "Stream 2 Sampling Rate == ", num_samples_2 / duration_seconds, " | Type : AUX")
    print( "Stream 3 Sampling Rate == ", num_samples_3 / duration_seconds, " | Type : FOCUS")


testLSLSamplingRates()