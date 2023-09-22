"""Example program to show how to read a GUI BandPower data over LSL."""
import time
from pylsl import StreamInlet, resolve_stream
from time import sleep

# Example Sample
# F
#[0.0, 0.8485075831413269, 9.373364448547363, 0.0013413801789283752, 0.001849484397098422]

# First resolve an EEG stream on the lab network
print("looking for an EEG stream...")
streams = resolve_stream('type', 'EEG')

# Create a new inlet to read from the stream
inlet = StreamInlet(streams[0])
duration = 5
num_channels = 8

sleep(1)

def testLSLSamplingRate():
    start = time.time()
    total_samples = 0
    num_samples_channel_0 = 0
    print( "Testing Sampling Rates..." )

    while time.time() <= start + duration:
        # Get chunks of samples
        sample, timestamp = inlet.pull_sample()
        if sample:
            print("\nNew chunk! Sample size == {}".format(len(sample)) )
            total_samples += 1
            print(sample, timestamp)
            if sample[0] == 0.0:
                num_samples_channel_0 += 1


    print( "Valid Samples and Duration == {} / {}".format(total_samples, duration) )
    print( "Average Sampling Rate == {}".format(total_samples / duration) )
    print( "Valid Samples Channel 0 and Duration == {} / {}".format(num_samples_channel_0, duration) )
    print( "Average Sampling Rate Channel 0 == {}".format(num_samples_channel_0 / duration) )


testLSLSamplingRate()