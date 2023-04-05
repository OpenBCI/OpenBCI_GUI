# If BrainFlow Python binding is not installed: pip install brainflow
# BrainFlow Documentation: https://brainflow.readthedocs.io/en/stable/SupportedBoards.html#streaming-board
# When used with the OpenBCI GUI, the same version (or very close) should be used on both sides.
# This test accepts a stream from the Synthetic mode in the OpenBCI GUI.

import time
from brainflow.board_shim import (
    BoardShim,
    BrainFlowInputParams,
    BoardIds,
    BrainFlowPresets,
)
from brainflow.data_filter import DataFilter


def main():
    BoardShim.enable_dev_board_logger()

    # use synthetic board for demo
    params = BrainFlowInputParams()
    params.ip_port = 6677
    params.ip_address = "225.1.1.1"
    params.master_board = BoardIds.SYNTHETIC_BOARD
    board_id = BoardIds.STREAMING_BOARD

    board = BoardShim(board_id, params)
    board.prepare_session()
    board.start_stream()
    time.sleep(10)
    data_default = board.get_board_data(preset=BrainFlowPresets.DEFAULT_PRESET)
    board.stop_stream()
    board.release_session()
    DataFilter.write_file(data_default, "default.csv", "w")
    print(data_default)


if __name__ == "__main__":
    main()
