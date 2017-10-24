import socket
import random
import struct
import time
import argparse

if __name__ == "__main__":

    # Collect command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default="127.0.0.1",
      help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=12345,
      help="The port the OSC server is listening on")
    parser.add_argument("--address", default="/openbci",
      help="The address the OSC server is sending to")
    args = parser.parse_args()

    # Establish UDP socket
    UDP_IP = args.ip
    UDP_PORT = args.port
    sock = socket.socket(socket.AF_INET, # Internet
                          socket.SOCK_DGRAM) # UDP

    # Display socket attributes
    print('--------------------')
    print("-- UDP SIMULATION -- ")
    print('--------------------')
    print("IP:", args.ip)
    print("PORT:", args.port)
    print('--------------------')

    # Send test data
    while (1):
      # generate random list
      ar = [random.random() for x in range(8)]
      print("SENT MESSAGE: ",ar)
      # package as byte array
      msg = struct.pack('>8f', *ar)
      # send through socket
      sock.sendto(msg, (UDP_IP, UDP_PORT))
      time.sleep(.25)
