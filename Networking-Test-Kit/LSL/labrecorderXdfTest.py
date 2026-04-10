import pyxdf
import matplotlib.pyplot as plt

# Load the XDF file
file_path = "PROVIDE THE PATH TO THE XDF FILE HERE"
data, header = pyxdf.load_xdf(file_path)

# Find the EEG stream
eeg_stream = None
for stream in data:
    if stream['info']['type'][0] == 'EXG': # Stream with LSL type 'EXG'
        eeg_stream = stream
        break

if eeg_stream is None:
    raise ValueError("No EEG stream found in the XDF file")

# Extract time series and time stamps
time_series = eeg_stream['time_series']
time_stamps = eeg_stream['time_stamps']

# Check the nominal sampling rate
nominal_sampling_rate = float(eeg_stream['info']['nominal_srate'][0])
print(f"Nominal sampling rate: {nominal_sampling_rate} Hz")

# Calculate the actual sampling rate
actual_sampling_rate = len(time_stamps) / (time_stamps[-1] - time_stamps[0])
print(f"Actual sampling rate: {actual_sampling_rate:.2f} Hz")

# Plot only channel 1 of the EEG data
plt.figure(figsize=(12, 6))
plt.plot(time_stamps, time_series[:, 0], label='Channel 1')

plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.title('EEG Time Series Data - Channel 1')
plt.legend()
plt.show()