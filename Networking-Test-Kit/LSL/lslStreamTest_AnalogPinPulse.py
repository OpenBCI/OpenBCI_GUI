"""Example program to show how to read a multi-channel time series from LSL."""
import time
from pylsl import StreamInlet, resolve_stream
from time import sleep
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import style
from collections import deque

# first resolve an EEG stream on the lab network
print("looking for an EEG stream...")
streams = resolve_stream('type', 'EEG')

# create a new inlet to read from the stream
inlet = StreamInlet(streams[0])
duration = 3

sleep(0)

def testLSLSamplingRate():
    start = time.time()
    numSamples = 0
    numChunks = 0

    while time.time() <= start + duration:
        # get chunks of samples
        samples, timestamp = inlet.pull_sample()
        if timestamp:
            numChunks += 1
            # print( len(samples) )
            numSamples += len(samples)
            # print(samples)

    print( "Number of Chunks == {}".format(numChunks) )
    print( "Avg Sampling Rate == {}".format(numSamples / duration) )


testLSLSamplingRate()

print("gathering data to plot...")

def testLSLPulseData():
    start = time.time()
    raw_pulse_signal = []

    while time.time() <= start + duration:
        sample, timestamp = inlet.pull_sample()
        if sample:
            print(sample[1])
            raw_pulse_signal.append(sample[1])

    print(raw_pulse_signal)
    plt.plot(raw_pulse_signal)
    plt.ylabel('raw analog signal')
    plt.show()

testLSLPulseData()