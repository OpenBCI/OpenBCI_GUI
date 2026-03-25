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


@dataclass
class ChannelFeatures:
    channel_index: int
    sample_count: int
    mean: float
    stddev: float
    peak_to_peak: float
    mean_abs_delta: float


class NeuralFeedbackTextTransformer:
    def __init__(self, max_channels=4):
        self.max_channels = max_channels

    def transform(self, master_board_id, data):
        eeg_channels = BoardShim.get_eeg_channels(master_board_id)
        if not eeg_channels:
            return "No EEG channels were found for the selected BrainFlow board."

        channel_features = []
        for channel_index in eeg_channels[: self.max_channels]:
            channel_data = self._as_float_list(data[channel_index])
            if len(channel_data) < 2:
                continue

            channel_features.append(
                ChannelFeatures(
                    channel_index=channel_index,
                    sample_count=len(channel_data),
                    mean=self._mean(channel_data),
                    stddev=self._stddev(channel_data),
                    peak_to_peak=max(channel_data) - min(channel_data),
                    mean_abs_delta=self._mean_abs_delta(channel_data),
                )
            )

        if not channel_features:
            return "The EEG stream did not contain enough samples to generate a text summary."

        sampling_rate = BoardShim.get_sampling_rate(master_board_id)
        sample_count = channel_features[0].sample_count
        window_seconds = sample_count / sampling_rate if sampling_rate else 0.0

        average_stddev = self._mean([item.stddev for item in channel_features])
        average_peak_to_peak = self._mean([item.peak_to_peak for item in channel_features])
        average_abs_delta = self._mean([item.mean_abs_delta for item in channel_features])

        state_label, interpretation = self._infer_state(
            average_stddev, average_peak_to_peak, average_abs_delta
        )

        lines = [
            "Neural feedback text summary",
            f"Window length: {window_seconds:.2f} seconds",
            f"Samples per channel: {sample_count}",
            f"Detected state: {state_label}",
            f"Interpretation: {interpretation}",
            "Channel highlights:",
        ]

        for feature in channel_features:
            lines.append(
                "  - EEG channel "
                f"{feature.channel_index}: mean={feature.mean:.3f}, "
                f"stddev={feature.stddev:.3f}, "
                f"peak_to_peak={feature.peak_to_peak:.3f}, "
                f"mean_abs_delta={feature.mean_abs_delta:.3f}"
            )

        return "\n".join(lines)

    def _infer_state(self, average_stddev, average_peak_to_peak, average_abs_delta):
        activation_score = average_stddev + (0.5 * average_peak_to_peak) + average_abs_delta

        if activation_score < 20:
            return (
                "steady / low-activation",
                "Signal changes are relatively small, which usually corresponds to a calm or stable feedback window.",
            )
        if activation_score < 60:
            return (
                "balanced / moderate-activation",
                "Signal energy is present without large swings, suggesting a moderately engaged feedback window.",
            )

        return (
            "active / high-variation",
            "Signal energy and short-term variation are elevated, suggesting an active or strongly changing feedback window.",
        )

    def _as_float_list(self, values):
        return [float(value) for value in values]

    def _mean(self, values):
        return sum(values) / len(values)

    def _stddev(self, values):
        mean_value = self._mean(values)
        variance = sum((value - mean_value) ** 2 for value in values) / len(values)
        return math.sqrt(variance)

    def _mean_abs_delta(self, values):
        deltas = [abs(current - previous) for previous, current in zip(values, values[1:])]
        return self._mean(deltas)


def main():
    BoardShim.enable_dev_board_logger()

    # use synthetic board for demo
    params = BrainFlowInputParams()
    params.ip_port = 6677
    params.ip_address = "225.1.1.1"
    params.master_board = BoardIds.SYNTHETIC_BOARD
    master_board_id = BoardIds.SYNTHETIC_BOARD.value
    board_id = BoardIds.STREAMING_BOARD

    board = BoardShim(board_id, params)
    board.prepare_session()
    board.start_stream()
    time.sleep(10)
    data_default = board.get_board_data(preset=BrainFlowPresets.DEFAULT_PRESET)
    board.stop_stream()
    board.release_session()
    DataFilter.write_file(data_default, "default.csv", "w")

    transformer = NeuralFeedbackTextTransformer()
    text_summary = transformer.transform(master_board_id, data_default)
    with open("neuralfeedback_summary.txt", "w", encoding="ascii") as summary_file:
        summary_file.write(text_summary + "\n")

    print(text_summary)


if __name__ == "__main__":
    main()
