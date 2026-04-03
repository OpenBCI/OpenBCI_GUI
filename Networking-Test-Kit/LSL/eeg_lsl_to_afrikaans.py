import os
from collections import deque

import numpy as np
import torch
from pylsl import StreamInlet, resolve_stream

# -----------------------------
# CONFIGURATION
# -----------------------------
CHANNELS = 8
WINDOW_SIZE = 250
STEP_SIZE = 50
MODEL_PATH = "eeg_transformer.pt"
POLL_TIMEOUT_SECONDS = 1.0

# Simple English → Afrikaans mapping for demo purposes
EN_TO_AF = {
    "LEFT": "LINKER",
    "RIGHT": "REGTER",
    "UP": "OP",
    "DOWN": "AF",
    "HELLO": "HALLO",
    "BYE": "TOTSIE",
}


def load_model(model_path, device):
    try:
        model = torch.jit.load(model_path, map_location=device)
        model.eval()
        return model
    except Exception:
        allow_unsafe = os.environ.get("ALLOW_UNSAFE_TORCH_LOAD", "0") == "1"
        if not allow_unsafe:
            raise RuntimeError(
                "Failed to load TorchScript model safely. "
                "Set ALLOW_UNSAFE_TORCH_LOAD=1 only for trusted model files."
            )
        model = torch.load(model_path, map_location=device, weights_only=False)
        model.eval()
        return model


def main():
    print("Resolving EEG stream...")
    streams = resolve_stream("type", "EEG")
    if not streams:
        raise RuntimeError("No LSL EEG stream found.")
    inlet = StreamInlet(streams[0])
    print("Connected to EEG stream.")

    print("Loading transformer model...")
    device = torch.device("cpu")
    model = load_model(MODEL_PATH, device)
    print("Model loaded.")

    buffer = deque(maxlen=WINDOW_SIZE)
    print("Starting real-time EEG → Afrikaans decoding...")

    try:
        while True:
            sample, _ = inlet.pull_sample(timeout=POLL_TIMEOUT_SECONDS)
            if sample is None:
                continue

            if len(sample) < CHANNELS:
                continue
            buffer.append(sample[:CHANNELS])

            if len(buffer) == WINDOW_SIZE:
                segment = np.array(buffer, dtype=np.float32)
                segment = (segment - np.mean(segment, axis=0)) / (
                    np.std(segment, axis=0) + 1e-6
                )
                segment_tensor = torch.tensor(segment).unsqueeze(0)

                with torch.no_grad():
                    logits = model(segment_tensor)
                    predicted_class = torch.argmax(logits, dim=-1).item()

                predicted_label_eng = (
                    model.labels[predicted_class]
                    if hasattr(model, "labels")
                    else str(predicted_class)
                )
                af_label = EN_TO_AF.get(predicted_label_eng, predicted_label_eng)
                print(f"Afrikaans Prediction: {af_label}")

                buffer = deque(list(buffer)[STEP_SIZE:], maxlen=WINDOW_SIZE)

    except KeyboardInterrupt:
        print("Real-time decoding stopped by user.")


if __name__ == "__main__":
    main()
