import time
from pylsl import StreamInlet, resolve_byprop
from time import sleep
import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime

duration_seconds = 11
channel_to_plot = 0
buffer = []

def test_lsl_sampling_rate():
    start = time.time()
    total_samples_count = 0
    valid_samples_count = 0
    chunk_count = 0
    global previous_timestamp
    previous_timestamp = 0
    global timestamps_out_of_order_counter
    timestamps_out_of_order_counter = 0
    print( "Testing Sampling Rates..." )

    while time.time() <= start + duration_seconds:
        # get chunks of samples
        chunk, timestamp = inlet.pull_chunk()
        if chunk:
            offset = inlet.time_correction()
            print("Offset: " + str(offset))
            new_chunk_received_time = datetime.now()
            print("\nNew chunk! -- Time: " + str(new_chunk_received_time))
            chunk_count += 1
            # print( len(chunk) )
            total_samples_count += len(chunk)
            # print(chunk)
            i = 0
            for sample in chunk:
                # print(sample, timestamp[i])
                add_sample_to_buffer(buffer, timestamp[i] * 1000, sample[channel_to_plot])
                valid_samples_count += 1
                i += 1

    print( "Number of Chunks and Samples == {} , {}".format(chunk_count, total_samples_count) )
    print( "Valid Samples and duration_seconds == {} / {}".format(valid_samples_count, duration_seconds) )
    print( "Avg Sampling Rate == {}".format(valid_samples_count / duration_seconds) )
    print( "Number of timestamps out of order == {}".format(timestamps_out_of_order_counter) )

# Function to add a new sample to the buffer
def add_sample_to_buffer(buffer, timestamp, value):
    global new_timestamp
    global previous_timestamp
    global timestamps_out_of_order_counter
    new_timestamp = timestamp
    if new_timestamp < previous_timestamp:
        print("Timestamps are not in order!")
        timestamps_out_of_order_counter += 1
    previous_timestamp = new_timestamp
    buffer.append({'Timestamp': timestamp, 'Value': value})
    print(f"Sample added to buffer: {timestamp}, {value}")

# Function to convert buffer to DataFrame
def buffer_to_dataframe(buffer):
    data = pd.DataFrame(buffer)
    data['Timestamp'] = pd.to_datetime(data['Timestamp'])
    return data

# Function to plot the time series graph
def plot_time_series(data):
    plt.figure(figsize=(10, 6))
    plt.plot(data['Timestamp'], data['Value'], marker='o', linestyle='-')
    plt.title('Time Series Data')
    plt.xlabel('Timestamp')
    plt.ylabel('Value')
    plt.grid(True)
    plt.show()

# first resolve an EEG stream on the lab network
print("looking for an EEG stream...")
streams = resolve_byprop('name', 'obci_stream_0')

# create a new inlet to read from the stream
inlet = StreamInlet(streams[0])

sleep(1)

test_lsl_sampling_rate()

# Convert buffer to DataFrame and plot the time series
data = buffer_to_dataframe(buffer)
if not data.empty:
    plot_time_series(data)
