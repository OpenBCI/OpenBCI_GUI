import time
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

# Simple English → Afrikaans mapping for demo purposes
EN_TO_AF = {
    "LEFT": "LINKER",
    "RIGHT": "REGTER",
    "UP": "OP",
    "DOWN": "AF",
    "HELLO": "HALLO",
    "BYE": "TOTSIE",
}


def main():
    print("Resolving EEG stream...")
    streams = resolve_stream("type", "EEG")
    if not streams:
        raise RuntimeError("No LSL EEG stream found.")
    inlet = StreamInlet(streams[0])
    print("Connected to EEG stream.")

    print("Loading transformer model...")
    device = torch.device("cpu")
    model = torch.load(MODEL_PATH, map_location=device)
    model.eval()
    print("Model loaded.")

    buffer = deque(maxlen=WINDOW_SIZE)
    print("Starting real-time EEG → Afrikaans decoding...")

    try:
        while True:
            sample, _ = inlet.pull_sample(timeout=1.0)
            if sample is None:
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

                for _ in range(STEP_SIZE):
                    if buffer:
                        buffer.popleft()

            time.sleep(0.01)

    except KeyboardInterrupt:
        print("Real-time decoding stopped by user.")


if __name__ == "__main__":
    main()
