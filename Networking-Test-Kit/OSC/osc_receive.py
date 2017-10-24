import argparse
import time
import atexit
import os
import signal
import sys
if sys.version_info.major == 3:
    from pythonosc import dispatcher
    from pythonosc import osc_server
elif sys.version_info.major == 2:
    import OSC


# Print received message to console
def print_message(*args):
  try:
      current = time.time()
      if sys.version_info.major == 2:
          print("(%f) RECEIVED MESSAGE: %s %s" % (current, args[0], ",".join(str(x) for x in args[2:])))
      elif sys.version_info.major == 3:
          print("(%f) RECEIVED MESSAGE: %s %s" % (current, args[0], ",".join(str(x) for x in args[1:])))

  except ValueError: pass

# Clean exit from print mode
def exit_print(signal, frame):
    print("Closing listener")
    sys.exit(0)

# Record received message in text file
def record_to_file(*args):
    textfile.write(str(time.time()) + ",")
    textfile.write(",".join(str(x) for x in args))
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
      default="localhost", help="The ip to listen on")
  parser.add_argument("--port",
      type=int, default=12345, help="The port to listen on")
  parser.add_argument("--address",default="/openbci", help="address to listen to")
  parser.add_argument("--option",default="print",help="Debugger option")
  args = parser.parse_args()


  if sys.version_info.major == 3:
  # Set up necessary parameters from command line
      dispatcher = dispatcher.Dispatcher()
      if args.option=="print":
          dispatcher.map("/openbci", print_message)
          signal.signal(signal.SIGINT, exit_print)

      elif args.option=="record":
          i = 0
          while os.path.exists("osc_test%s.txt" % i):
            i += 1
          filename = "osc_test%i.txt" % i
          textfile = open(filename, "w")
          textfile.write("time,address,messages\n")
          textfile.write("-------------------------\n")
          print("Recording to %s" % filename)
          dispatcher.map("/openbci", record_to_file)
          signal.signal(signal.SIGINT, close_file)

      # Display server attributes
      print('--------------------')
      print("-- OSC LISTENER -- ")
      print('--------------------')
      print("IP:", args.ip)
      print("PORT:", args.port)
      print("ADDRESS:", args.address)
      print('--------------------')
      print("%s option selected" % args.option)


      # connect server
      server = osc_server.ThreadingOSCUDPServer(
          (args.ip, args.port), dispatcher)
      server.serve_forever()

  elif sys.version_info.major == 2:
    s = OSC.OSCServer((args.ip, args.port))  # listen on localhost, port 57120
    if args.option=="print":
        s.addMsgHandler(args.address, print_message)
    elif args.option=="record":
      i = 0
      while os.path.exists("osc_test%s.txt" % i):
        i += 1
      filename = "osc_test%i.txt" % i
      textfile = open(filename, "w")
      textfile.write("time,address,messages\n")
      textfile.write("-------------------------\n")
      print("Recording to %s" % filename)
      signal.signal(signal.SIGINT, close_file)
    # Display server attributes
    print('--------------------')
    print("-- OSC LISTENER -- ")
    print('--------------------')
    print("IP:", args.ip)
    print("PORT:", args.port)
    print("ADDRESS:", args.address)
    print('--------------------')
    print("%s option selected" % args.option)
    print("Listening...")

    s.serve_forever()
