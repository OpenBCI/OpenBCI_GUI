import argparse
import re

import brainflow
from brainflow.board_shim import BoardShim, BoardIds


def find_int_in_string (line):
    numbers = re.findall ('\d+', line)
    if not numbers:
        raise ValueError ('no ints in %s' % line)
    if len (numbers) > 1:
        raise ValueError ('multiple ints in %s' % line)
    return int (numbers[0])


def get_board_class (num_channels, sampling_rate):
    if num_channels == 8 and sampling_rate == 250:
        return 'BoardCytonSerial', brainflow.BoardIds.CYTON_BOARD
    elif num_channels == 8:
        return 'BoardCytonWifi', brainflow.BoardIds.CYTON_WIFI_BOARD
    elif num_channels == 16 and sampling_rate == 125:
        return 'BoardCytonSerialDaisy', brainflow.BoardIds.CYTON_DAISY_BOARD
    elif num_channels == 16:
        return 'BoardCytonWifiDaisy', brainflow.BoardIds.CYTON_DAISY_WIFI_BOARD
    elif num_channels == 4 and sampling_rate == 200:
        return 'BoardGanglionBLE', brainflow.BoardIds.GANGLION_BOARD
    elif num_channels == 4:
        return 'BoardGanglionWifi', brainflow.BoardIds.GANGLION_WIFI_BOARD
    else:
        raise ValueError ('unknown number of channels %s' % str (num_channels))


def write_array (f, values):
    string = ','.join (values)
    f.write ('%s\n' % string)


def convert (old_file, new_file):
    with open (old_file) as f:
        old_lines = f.readlines ()

    with open (new_file, 'w') as f:

        for i, line in enumerate (old_lines):
            if i == 0:
                f.write (line)
            elif i == 1:
                num_channels = find_int_in_string (line)
                f.write (line)
            elif i == 2:
                # sampling rate from double to int
                patched_string = line.replace ('.0 Hz', 'Hz')
                sampling_rate = find_int_in_string (patched_string)
                f.write (patched_string)
                board_class, board_id = get_board_class (num_channels, sampling_rate)
                board_line = '%%Board = OpenBCI_GUI$%s\n' % board_class
                f.write (board_line)
                # need to determine number of rows in new file
                num_rows = BoardShim.get_num_rows (board_id.value)
                accel_channels = BoardShim.get_accel_channels (board_id.value)
                stub_string = ['0.0' for i in range (num_rows + 1)]
                write_array (f, stub_string)
            # skip other lines in old header
            elif line.startswith ('%'):
                continue
            # start parsing data
            else:
                line = line.strip ('\n')
                data_points = line.split (',')
                new_data_points = list ()
                # first package and eeg are the same place always
                for i in range (1 + num_channels):
                    new_data_points.append (data_points[i])
                i = 1 + num_channels
                while i != accel_channels[0]:
                    i = i + 1
                    new_data_points.append ('0.0')
                # always 3 accel channels
                new_data_points.append (data_points[i])
                new_data_points.append (data_points[i + 1])
                new_data_points.append (data_points[i + 2])
                i = i + 3
                while i < num_rows - 1:
                    i = i + 1
                    new_data_points.append ('0.0')
                # last two columns timestamps but reversed
                new_data_points.append (data_points[-1])
                new_data_points.append (data_points[-2])
                write_array (f, new_data_points)


def main ():
    parser = argparse.ArgumentParser ()
    parser.add_argument ('--old', type = str, help  = 'old file', required = True)
    parser.add_argument ('--new', type = str, help  = 'new file', required = True)
    args = parser.parse_args ()

    convert (args.old, args.new)


if __name__ == '__main__':
    main ()
