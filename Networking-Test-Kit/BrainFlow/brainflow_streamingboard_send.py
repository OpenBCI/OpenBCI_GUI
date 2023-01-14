# If BrainFlow Python binding is not installed: pip install brainflow
# BrainFlow Documentation: https://brainflow.readthedocs.io/en/stable/SupportedBoards.html#streaming-board
# BrainFlow Multiple Streamers Example: https://github.com/brainflow-dev/brainflow/blob/master/python_package/examples/tests/multiple_streamers.py
# When used with the OpenBCI GUI, the same version (or very close) should be used on both sides.
# This test connects directly to an OpenBCI board, or Synthetic board, and streams it out to the OpenBCI GUI.

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
    board_id = BoardIds.SYNTHETIC_BOARD.value

    presets = BoardShim.get_board_presets(board_id)
    print(presets)

    board = BoardShim(board_id, params)
    board.prepare_session()
    board.add_streamer("file://streamer_default.csv:w")
    board.add_streamer("streaming_board://225.1.1.1:6677")
    board.start_stream()
    time.sleep(30)
    data_default = board.get_board_data(preset=BrainFlowPresets.DEFAULT_PRESET)
    board.stop_stream()
    board.release_session()
    DataFilter.write_file(data_default, "default.csv", "w")


if __name__ == "__main__":
    main()
