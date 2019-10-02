"""Example program to demonstrate how to read a multi-channel time-series
from LSL in a chunk-by-chunk manner (which is more efficient).

Please restart this script if you change one of the data types.
Also, the # Chan should match the data type (Examples: 1 for Focus, 3 for Accel)

"""

from pylsl import StreamInlet, resolve_stream

numStreams = 3
# first resolve an EEG stream on the lab network
print("looking for an EEG stream...")
stream1 = resolve_stream('name', 'obci_eeg1')
stream2 = resolve_stream('name', 'obci_eeg2')
stream3 = resolve_stream('name', 'obci_eeg3')

# create a new inlet to read from the stream
inlet = StreamInlet(stream1[0])
inlet2 = StreamInlet(stream2[0])
inlet3 = StreamInlet(stream3[0])

while True:
    for i in range(numStreams):
        # get a new sample (you can also omit the timestamp part if you're not
        # interested in it)
        if i == 0:
            chunk, timestamps = inlet.pull_chunk()
            if timestamps:
                print("Stream", i + 1, " == ", chunk)
        elif i == 1:
            chunk, timestamps = inlet2.pull_chunk()
            if timestamps:
                print("Stream", i + 1, " == ", chunk)
        elif i == 2:
            chunk, timestamps = inlet3.pull_chunk()
            if timestamps:
                print("Stream", i + 1, " == ", chunk)