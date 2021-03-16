#############################################################################       
##                           BrainFlow + LSL                               ##
##      Use BrainFlow to read data from board send it as an LSL stream     ##
#############################################################################

# Install dependencies with:
# pip install --upgrade numpy brainflow pylsl

# Here are example commands using Cyton and get_exg_channels()from BrainFlow. This has only been tested with Cyton + Dongle, for now.

# Mac:
# python3 Networking-Test-Kit/LSL/brainflow_lsl.py --board-id 2 --serial-port /dev/cu.usbserial-DM00D7TW --name test --data-type EXG --channel-names 1,2,3,4,5,6,7,8 --uid brainflow

# Windows:
# python3 Networking-Test-Kit/LSL/brainflow_lsl.py --board-id 2 --serial-port COM3 --name test --data-type EXG --channel-names 1,2,3,4,5,6,7,8 --uid brainflow

import argparse
import time
import numpy as np

from queue import Queue

import brainflow
from brainflow.board_shim import BoardShim, BrainFlowInputParams
from brainflow.data_filter import DataFilter, FilterTypes, AggOperations

from random import random as rand
from pylsl import StreamInfo, StreamOutlet, local_clock

def channel_select(board, board_id, data_type): 
    switcher = { 
        'EXG': board.get_exg_channels(board_id),
        # can add more
    } 
 
    return switcher.get(data_type, "error") 

def main():
    BoardShim.enable_dev_board_logger()

    parser = argparse.ArgumentParser()

    # brainflow params - use docs to check which parameters are required for specific board, e.g. for Cyton set serial port
    parser.add_argument('--timeout', type=int, help='timeout for device discovery or connection', required=False, default=0)
    # parser.add_argument('--ip-address', type=str, help='ip address', required=False)
    parser.add_argument('--board-id', type=int, help='board id, check docs to get a list of supported boards', required=True)
    parser.add_argument('--serial-port', type=str, help='serial port', required=False, default='')
    parser.add_argument('--streamer-params', type=str, help='streamer params', required=False, default='')

    # LSL params 
    parser.add_argument('--name', type=str, help='name', required=True)
    parser.add_argument('--data-type', type=str, help='data type', required=True)
    parser.add_argument('--channel-names', type=str, help='channel names', required=True)
    parser.add_argument('--uid', type=str, help='uid', required=True)

    args = parser.parse_args()

    # brainflow initialization
    params = BrainFlowInputParams()
    params.serial_port = args.serial_port
    # params.ip_address = args.ip_address
    board = BoardShim(args.board_id, params)

    # LSL initialization  
    channel_names = args.channel_names.split(',')
    n_channels = len(channel_names)
    srate = board.get_sampling_rate(args.board_id)
    info = StreamInfo(args.name, args.data_type, n_channels, srate, 'double64', args.uid)
    outlet = StreamOutlet(info)
    fw_delay = 0

    # prepare session
    board.prepare_session()

    # send commands to the board for every channel. Cyton has 8 Channels. Here, we turn off every channel except for 1 and 8.
    board.config_board("x1040000X")
    board.config_board("x2161000X")
    board.config_board("x3161000X")
    board.config_board("x4161000X")
    board.config_board("x5161000X")
    board.config_board("x6161000X")
    board.config_board("x7161000X")
    board.config_board("x8060110X")

    # start stream
    board.start_stream(45000, args.streamer_params)
    time.sleep(1)
    start_time = local_clock()
    sent_samples = 0
    queue = Queue(maxsize = 5*srate)
    chans = channel_select(board, args.board_id, args.data_type)

    # read data with brainflow and send it via LSL
    print("Now sending data...")
    while True:
        data = board.get_board_data()[chans]
        for i in range(len(data[0])):
            queue.put(data[:,i].tolist())
        elapsed_time = local_clock() - start_time
        required_samples = int(srate * elapsed_time) - sent_samples
        if required_samples > 0 and queue.qsize() >= required_samples:    
            mychunk = []

            for i in range(required_samples):
                mychunk.append(queue.get())
            stamp = local_clock() - fw_delay 
            outlet.push_chunk(mychunk, stamp)
            sent_samples += required_samples
        #time.sleep(1)


if __name__ == "__main__":
    main()
