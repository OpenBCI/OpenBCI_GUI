import argparse
import random
import time
import sys

if sys.version_info.major == 3:
    from pythonosc import osc_message_builder
    from pythonosc import udp_client
elif sys.version_info.major == 2:
    import OSC


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

  # Display socket attributes
  print('--------------------')
  print("-- OSC SIMULATION -- ")
  print('--------------------')
  print("IP:", args.ip)
  print("PORT:", args.port)
  print("ADDRESS:", args.address)
  print('--------------------')

  # Establish UDP client (for OSC)
  if sys.version_info.major == 3:
      client = udp_client.SimpleUDPClient("127.0.0.1", 12345 )



      # Send test data
      while (1):
        msg = [random.random() for x in range(8)]
        print("SENT MESSAGE: ", msg )
        client.send_message(args.address, msg)
        time.sleep(.25)
  elif sys.version_info.major == 2:
      client = OSC.OSCClient()
      client.connect((args.ip,args.port))
      while (1):
        msg = [random.random() for x in range(8)]
        oscmsg = OSC.OSCMessage()
        oscmsg.setAddress(args.address)
        oscmsg.append(msg)
        print("SENT MESSAGE: ", msg )
        try:
            client.send(oscmsg)
        except:
            pass
        time.sleep(.25)
