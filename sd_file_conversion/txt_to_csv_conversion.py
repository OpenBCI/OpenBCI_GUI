#OPENBCI HEX TO CSV CONVERSION REFERENCE: https://github.com/roflecopter/openbci-psg

import numpy as np
import pandas as pd 
import os
import mne
from datetime import datetime

def accel_scale(signal):
    """
    Scale accelerometer data by a factor of 0.002/(2^4).

    Parameters:
    - signal (numpy.ndarray): Accelerometer signal values.

    Returns:
    - numpy.ndarray: Scaled accelerometer signal values.
    """
    # Define the scaling factor for the accelerometer data
    accel_scale = 0.002 / (2 ** 4)

    # Multiply each element of the input signal by the scaling factor
    scaled_signal = signal * accel_scale

    # Return the scaled accelerometer signal
    return scaled_signal


def parseInt24Hex(hex_value):
    """
    Parse a 24-bit hexadecimal value into a signed integer.

    Parameters:
    - hex_value (str): Hexadecimal value to be parsed.

    Returns:
    - int: Parsed signed integer value.
    """
    # Check if the hexadecimal value is less than 16 characters long
    if len(hex_value) < 16:
        # Convert the hex value to a decimal integer
        # If the first character is not 'F', it's a positive value; otherwise, subtract 2^32 for a negative value
        value_dec = int(hex_value, 16) if hex_value[0] != 'F' else int(hex_value, 16) - 2**32
        return value_dec
    # Return 0 if the hex value is not 24 bits long
    return 0



def processLine(split_line):
    """
    Process a line of hex data and convert it to a list of parsed values.

    Parameters:
    - split_line (list): List of hex values in a line.

    Returns:
    - list: Parsed values from the hex data.
    """  
    # Initialize an empty list to store parsed values
    values_array = []

    # Iterate through each hex value in the split line
    for i in range(1, len(split_line)):
        value = split_line[i]

        # Check if the hex value corresponds to an EEG channel (i <= 16)
        if i <= 16:
            # Adjust the hex value to ensure it represents a 24-bit value and then parse it
            channel_value = 'FF' + value if value[0] > '7' else '00' + value
            value = parseInt24Hex(channel_value)
        else:
            # Adjust the hex value for non-EEG channels and then parse it
            aux_value = 'FFFF' + value if value[0] > '7' else '0000' + value
            value = parseInt24Hex(aux_value)

        # Append the parsed value to the list
        values_array.append(value)

    # Return the list of parsed values
    return values_array


def process_file(file_path: str,
                 n_acc: int = 3,
                 save_path: str = None,
                 board_type: str = "CytonDaisy",
                 board_mode: str = "Analog"):
    """
    Process the OpenBCI hex file and convert it to a CSV file.

    Parameters:
    - file_path (str): Path to the input hex file.
    - n_acc (int): Number of accelerometer channels.
    - save_path (str): Path to save the converted CSV file.
    - board_type (str): Type of OpenBCI board used (CytonDaisy, Cyton, Ganglion).
    - board_mode (str): Mode of the board data (Analog, Digital, Mixed).

    Returns:
    - None
    """
    # Get the current time for creating a timestamp in the output CSV file
    current_time = datetime.now()
    formatted_time = current_time.strftime("%Y-%m-%d_%H-%M-%S")

    # Determine the number of channels based on the board type
    if board_type == "CytonDaisy":
        n_ch = 16
        board_name = "OpenBCI_GUI$BoardCytonDaisySerial"
    elif board_type == "Cyton":
        n_ch = 8
        board_name = "OpenBCI_GUI$BoardCytonSerial"
    elif board_type == "Ganglion":
        n_ch = 4
        board_name = "OpenBCI_GUI$BoardGanglionSerial"

    # Open the hex file for reading
    with open(file_path, 'r') as file:
        result = []  # List to store parsed values
        i = 0  # Counter for line index
        stops_n = 0  # Counter for lines starting with '%'
        stops = []  # List to store indices of lines starting with '%'

        while True:
            line = file.readline()
            if not line:
                break  # End of file

            split_line = line.strip().split(',')

            # Check if the line starts with '%' indicating additional information
            if len(split_line) == 1 and split_line[0].startswith('%'):
                stops_n += 1
                stops.append(i)
            # Check if the line contains valid data (number of elements between 3 and n_ch + n_acc + 1)
            elif (len(split_line) > 3) and (len(split_line) <= n_ch + n_acc + 1):
                # Process the line and obtain parsed values
                values = processLine(split_line)

                # Determine the number of values to add based on the line structure
                if len(values) == (n_ch + n_acc):
                    to_add = values
                elif len(values) == (n_ch):
                    to_add = values + [0, 0, 0]
                else:
                    to_add = [0] * (n_ch + n_acc)

                # Append the processed values to the result list
                result.append(to_add)

            i += 1
            if i % 1000000 == 0:
                print(f"Processing... {i}")

        # Convert the result list to a NumPy array
        bci_signals = np.array(result)

        # Apply OpenBCI scaling to EEG signals and accelerometer scaling to accelerometer signals
        accel_data = np.vectorize(accel_scale)(bci_signals[:, n_ch:])

        exg_channel_cols = [f'EXG Channel {i}' for i in range(n_ch)]

        additional_cols = ['Accel Channel 0', 'Accel Channel 1', 'Accel Channel 2',
                            'Not Used', 'Digital Channel 0 (D11)', 'Digital Channel 1 (D12)',
                            'Digital Channel 2 (D13)', 'Digital Channel 3 (D17)', 'Not Used',
                            'Digital Channel 4 (D18)', 'Analog Channel 0', 'Analog Channel 1',
                            'Analog Channel 2', 'Timestamp', 'Marker Channel', 'Timestamp (Formatted)']

        all_columns = ['Sample Index'] + exg_channel_cols + additional_cols
        
        # create columns 
        df = pd.DataFrame(columns=all_columns)

        # sample index values 
        num_repeats = len(bci_signals) // 256
        df['Sample Index'] = list(range(256)) * num_repeats + list(range(len(bci_signals) % 256))

        # EXG channels values
        for i in range(n_ch):
            df[exg_channel_cols[i]] = np.vectorize(adc_v_bci)(bci_signals[:, i])

        # Sensor values 
        analog_sensor_columns = [-6, -5, -4]
        digital_sensor_columns = [-11, -10, -7]
        accel_sensor_columns = [-16, -15, -14]

        # Map data to correct columns based on board_mode
        if board_mode == "Analog":
            df.iloc[:, analog_sensor_columns] = accel_data
        elif board_mode == "Digital":
            df.iloc[:, digital_sensor_columns] = accel_data
        else:
            df.iloc[:, accel_sensor_columns] = accel_data

        df = df.fillna(0)

        # Additional information to be added at the beginning of the CSV file
        additional_info = [
            "%OpenBCI Raw EXG Data",
            f"%Number of channels = {n_ch}",
            "%Sample Rate = 250 Hz",
            f"%Board = {board_name}"
        ]

        file_name_with_extension = os.path.basename(file_path)
        file_name, _ = os.path.splitext(file_name_with_extension)

        if save_path:
            file_path = os.path.join(save_path, file_name)
            df.to_csv(f"{file_path}_converted.csv", index=False)

            # Write additional information to the CSV file
            with open(f"{file_path}_converted.csv", 'w') as file:
                for line in additional_info:
                    file.write(line + '\n')

            # Append the index to the CSV file
            df.to_csv(f"{file_path}_converted.csv", mode='a', index=False)
        else:
            df.to_csv(f"./{file_name}_converted.csv", index=False)

            # Write additional information to the CSV file
            with open(f"{file_name}_converted.csv", 'w') as file:
                for line in additional_info:
                    file.write(line + '\n')

            # Append the index to the CSV file
            df.to_csv(f"{file_path}_converted.csv", mode='a', index=False)

        return None

    

def adc_v_bci(signal, 
              ADS1299_VREF:float = 4.5,
              gain:int = 24,
              ADS1299_BITS:float = (2**23-1),
              V_Factor:int = 1000000):
    """
    Convert ADC values to microvolts using OpenBCI scaling factors.

    Parameters:
    - signal (numpy.ndarray): ADC signal values.
    - ADS1299_VREF (float): Reference voltage for the ADS1299.
    - gain (int): Gain setting for the ADS1299.
    - ADS1299_BITS (float): Number of bits for ADC resolution.
    - V_Factor (int): Voltage conversion factor.

    Returns:
    - numpy.ndarray: Signal values in microvolts.
    """
    # Gain setting for the ADS1299
    ADS1299_GAIN = gain

    # Calculate the conversion factor 'k' using OpenBCI scaling factors
    k = ADS1299_VREF / ADS1299_BITS / ADS1299_GAIN * V_Factor

    # Multiply each element of the input signal by the conversion factor
    microvolts_signal = signal * k

    # Return the signal values in microvolts
    return microvolts_signal



def start_converting(sd_dir:str = "./",
                     gain:int = 24,
                     board_type:str = "CytonDaisy",
                     board_mode: str = "Analog",
                     save_path:str = ""):
    """
    Batch process OpenBCI hex files in a directory and convert them to CSV.

    Parameters:
    - sd_dir (str): Directory containing OpenBCI hex files.
    - gain (int): Gain setting for the ADS1299.
    - n_ch (int): Number of EEG channels.
    - n_acc (int): Number of accelerometer channels.
    - save_path (str): Directory to save the converted CSV files.

    Returns:
    - None
    """
    # Assign parameters to local variables
    gain = gain
    save_path = save_path

    # Get a list of files in the specified directory with a '.txt' extension
    files = [file for file in os.listdir(sd_dir) if file.endswith('.txt')]
    
    # Sort the files in reverse order (latest files first)
    if files:
        files.sort(reverse=True)
        
        # Iterate through each file in the sorted list
        for file_name in files:
            # Construct the full path to the file
            file_path = os.path.join(sd_dir, file_name)
            
            # Print a message indicating the file being processed
            print(f'converting: {file_name}')
            
            # Call the process_file function to convert the hex file to CSV
            process_file(file_path=file_path, 
                         save_path=save_path,
                         board_type=board_type,
                         board_mode=board_mode)
            
    return None



def file_type_conversion(csv_path:str = "./",
                save_path:str = "./",
                board_type:str = "CytonDaisy",
                ch_names:[str] = None,
                sfreq:int = 250,
                file_type:str = "brainvision"):
    """
    Convert CSV files to a specified file type using MNE library.

    Parameters:
    - csv_path (str): Directory containing CSV files.
    - save_path (str): Directory to save the converted files.
    - num_channels (int): Number of EEG channels.
    - ch_names (list): List of EEG channel names.
    - sfreq (int): Sampling frequency.
    - file_type (str): Output file type (e.g., "brainvision").

    Returns:
    - None
    """
    
    if board_type == "CytonDaisy":
        n_ch = 16

    elif board_type == "Cyton":
        n_ch = 8

    elif board_type == "Ganglion":
        n_ch = 4


    # Get a list of files in the specified directory with a '.csv' extension
    files = [file for file in os.listdir(csv_path) if file.endswith('.csv')]
    
    # Sort the files in reverse order (latest files first)
    if files:
        files.sort(reverse=True)
        
        # Iterate through each file in the sorted list
        for file_name in files:
            # Construct the full path to the CSV file
            file_path = os.path.join(csv_path, file_name)
            name, _ = os.path.splitext(file_name)
            
            # Read the CSV file, skipping the header rows
            csv_file = pd.read_csv(file_path ,header=None,skiprows=[0,1,2,3,4],index_col=0,sep=',',engine='python')
            
            # Remove the last 3 columns from the CSV file
            csv_file = csv_file.iloc[:,:-16]
            
            # Transpose the DataFrame
            csv_file = pd.DataFrame.transpose(csv_file)
            
            # Convert values to volts as MNE supports volts
            csv_file = csv_file / 1e6

            # Define EEG channel types
            ch_types = (['eeg'] * n_ch)

            # If channel names are not provided, generate default names
            if ch_names is None:
                ch_names = [str(i) for i in range(1, n_ch + 1)]

            # Create MNE Info object
            info = mne.create_info(ch_names=ch_names, sfreq=sfreq, ch_types=ch_types)
            
            # Create MNE RawArray
            raw = mne.io.RawArray(csv_file, info)

            #getting file extension 
            if file_type == "brainvision":
                extension = ".eeg"
            elif file_type == "edf":
                extension = ".edf"
            elif file_type == "EEGLAB":
                extension = ".set"

            # Export the MNE RawArray to the specified file type
            mne.export.export_raw(f"{save_path}/{name}{extension}", raw, fmt=file_type, overwrite=True)

    return None

if __name__ == "__main__":
    start_converting(sd_dir="./hex_data/",
                    save_path="raw_data",
                    board_type = "CytonDaisy",
                    board_mode = "Analog")

    file_type_conversion(csv_path = "./raw_data/",
                    save_path = "./raw_data/",
                    board_type = "CytonDaisy",
                    sfreq = 250,
                    file_type = "brainvision")
