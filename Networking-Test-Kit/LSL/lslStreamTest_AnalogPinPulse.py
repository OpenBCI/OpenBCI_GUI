"""Example program to show how to read a multi-channel time series from LSL."""
import time
from pylsl import StreamInlet, resolve_byprop
from time import sleep
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import style
from collections import deque

# first resolve an EEG stream on the lab network
print("looking for an EEG stream...")
streams = resolve_byprop('type', 'EEG')

# create a new inlet to read from the stream
inlet = StreamInlet(streams[0])
duration = 10

sleep(0)

def testLSLSamplingRate():
    start = time.time()
    numSamples = 0
    numChunks = 0

    while time.time() <= start + duration:
        # get chunks of samples
        chunk, timestamp = inlet.pull_chunk()
        if timestamp:
            numChunks += 1
            for sample in chunk:
                numSamples += 1

    print( "Number of Chunks == {}".format(numChunks) )
    print( "Avg Sampling Rate == {}".format(numSamples / duration) )


testLSLSamplingRate()

print("gathering data to plot...")

def testLSLPulseData():
    start = time.time()
    raw_pulse_signal = []

    while time.time() <= start + duration:
        chunk, timestamp = inlet.pull_chunk()
        if timestamp:
            for sample in chunk:
                # print(sample)
                raw_pulse_signal.append(sample[1])

    print(raw_pulse_signal)
    print( "Avg Sampling Rate == {}".format(len(raw_pulse_signal) / duration) )
    plt.plot(raw_pulse_signal)
    plt.ylabel('raw analog signal')
    plt.show()

testLSLPulseData()