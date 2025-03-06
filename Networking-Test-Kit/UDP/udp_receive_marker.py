import socket
import sys
import time
import argparse
import signal
import struct
import os

numSamples = 0

# Print received message to console (interprets bytes)
def print_message(*args):
    try:
        data = args[0]  # Raw bytes from UDP
        marker = struct.unpack('!d', data)[0]  # Unpack as double-precision float
        print(f"Received Marker: {marker}")

        global numSamples
        numSamples += 1  # Count the number of received markers
        return True
    except struct.error as e:
        print("Error unpacking data:", e)
        return False

# Clean exit from print mode
def exit_print(signal, frame):
    print("Closing listener")
    sys.exit(0)

# Record received message in a text file
def record_to_file(*args):
    textfile.write(f"{time.time()},")
    try:
        data = args[0]
        marker = struct.unpack('!d', data)[0]  # Unpack bytes into float
        textfile.write(f"{marker}\n")
    except struct.error as e:
        print("Error unpacking data:", e)

# Save recording, clean exit from record mode
def close_file(*args):
    print("\nFILE SAVED")
    textfile.close()
    sys.exit(0)

if __name__ == "__main__":
    # Collect command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default="127.0.0.1", help="The IP to listen on")
    parser.add_argument("--port", type=int, default=12345, help="The port to listen on")
    parser.add_argument("--option", default="print", help="Debugger option: 'print' or 'record'")
    args = parser.parse_args()

    # Set up signal handling for clean exit
    if args.option == "print":
        signal.signal(signal.SIGINT, exit_print)
    elif args.option == "record":
        i = 0
        while os.path.exists(f"udp_test{i}.txt"):
            i += 1
        filename = f"udp_test{i}.txt"
        textfile = open(filename, "w")
        textfile.write("time,marker\n")
        print(f"Recording to {filename}")
        signal.signal(signal.SIGINT, close_file)

    # Create and bind the UDP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind((args.ip, args.port))

    # Display socket attributes
    print('--------------------')
    print("-- UDP LISTENER -- ")
    print('--------------------')
    print(f"IP: {args.ip}")
    print(f"PORT: {args.port}")
    print('--------------------')
    print(f"{args.option} option selected")

    # Start listening
    print("Listening for UDP packets...")
    start = time.time()
    duration = 10  # Listen for 10 seconds

    while time.time() <= start + duration:
        data, addr = sock.recvfrom(8)  # Expecting an 8-byte double-precision float
        if args.option == "print":
            print_message(data)
        elif args.option == "record":
            record_to_file(data)
            numSamples += 1

    print(f"Samples == {numSamples}")
    print(f"Duration == {duration}")
    print(f"Avg Sampling Rate == {numSamples / duration}")
