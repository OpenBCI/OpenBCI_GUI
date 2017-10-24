import socket
import sys
import time
import argparse
import signal
import struct
import os
import json

# Print received message to console
def print_message(*args):
    try:
        obj = json.loads(args[0])
        print obj.get('data')
    except BaseException as e:
        print e
 #  print("(%s) RECEIVED MESSAGE: " % time.time() +
 # ''.join(str(struct.unpack('>%df' % int(length), args[0]))))

# Clean exit from print mode
def exit_print(signal, frame):
    print("Closing listener")
    sys.exit(0)

# Record received message in text file
def record_to_file(*args):
    textfile.write(str(time.time()) + ",")
    textfile.write(''.join(str(struct.unpack('>%df' % length,args[0]))))
    textfile.write("\n")

# Save recording, clean exit from record mode
def close_file(*args):
    print("\nFILE SAVED")
    textfile.close()
    sys.exit(0)

if __name__ == "__main__":
  # Collect command line arguments
  parser = argparse.ArgumentParser()
  parser.add_argument("--ip",
      default="127.0.0.1", help="The ip to listen on")
  parser.add_argument("--port",
      type=int, default=12345, help="The port to listen on")
  parser.add_argument("--address",default="/openbci", help="address to listen to")
  parser.add_argument("--option",default="print",help="Debugger option")
  parser.add_argument("--len",default=8,help="Debugger option")
  args = parser.parse_args()

  # Set up necessary parameters from command line
  length = args.len
  if args.option=="print":
      signal.signal(signal.SIGINT, exit_print)
  elif args.option=="record":
      i = 0
      while os.path.exists("udp_test%s.txt" % i):
        i += 1
      filename = "udp_test%i.txt" % i
      textfile = open(filename, "w")
      textfile.write("time,address,messages\n")
      textfile.write("-------------------------\n")
      print("Recording to %s" % filename)
      signal.signal(signal.SIGINT, close_file)

  # Connect to socket
  sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
  server_address = (args.ip, args.port)
  sock.bind(server_address)

  # Display socket attributes
  print('--------------------')
  print("-- UDP LISTENER -- ")
  print('--------------------')
  print("IP:", args.ip)
  print("PORT:", args.port)
  print('--------------------')
  print("%s option selected" % args.option)

  # Receive messages
  print("Listening...")
  while True:
    data, addr = sock.recvfrom(20000) # buffer size is 20000 bytes
    if args.option=="print":
      print_message(data)
    elif args.option=="record":
      record_to_file(data)
