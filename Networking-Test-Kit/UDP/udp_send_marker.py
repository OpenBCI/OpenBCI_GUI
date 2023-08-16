import socket
import random
import struct
import time
import argparse

if __name__ == "__main__":

    test_duration = 10

    # Collect command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default="127.0.0.1",
      help="The IP of the UDP server")
    parser.add_argument("--port", type=int, default=12350,
      help="The port the UDP server is sending to")
    args = parser.parse_args()

    # Establish UDP socket
    UDP_IP = args.ip
    UDP_PORT = args.port
    sock = socket.socket(socket.AF_INET, # Internet
                          socket.SOCK_DGRAM) # UDP

    # Display socket attributes
    print('---------------------')
    print("-- UDP MARKER SEND -- ")
    print('---------------------')
    print("IP:", args.ip)
    print("PORT:", args.port)
    print('--------------------=')

    # Send test data
    start = time.time()
    while time.time() <= start + test_duration:
      # generate random float
      marker = random.uniform(0, 4)
      # package as byte array
      msg = struct.pack('!d', marker)
      # send through socket
      sock.sendto(msg, (UDP_IP, UDP_PORT))
      time.sleep(.25)
