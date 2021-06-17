import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.InetSocketAddress;
import java.net.UnknownHostException;
import java.nio.ByteBuffer;
import java.util.Collections;
import org.java_websocket.WebSocket;
//import org.java_websocket.WebSocketImpl;
import org.java_websocket.drafts.Draft;
import org.java_websocket.drafts.Draft_6455;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;


//create a separate thread for the server not to freeze/interfere with Processing's default animation thread
public class ServerThread extends Thread{
  DeviceServer s;
 
  Boolean newDataToSend = false;
  private LinkedList<double[]> dataAccumulationQueue;
  public float[][] dataBufferToSend;

  ServerThread(){
    dataAccumulationQueue = new LinkedList<double[]>();
    dataBufferToSend = new float[currentBoard.getNumEXGChannels()][nPointsPerUpdate];
      }

  @Override
  public void run(){
    try{
         // WebSocketImpl.DEBUG = true;
          int port = 8887; // 843 flash policy port
          try {
            port = Integer.parseInt( args[ 0 ] );
          } catch ( Exception ex ) {
          }
          s = new DeviceServer( port );
          s.start();
          System.out.println( "DeviceServer started on port: " + s.getPort() );

        }catch(IOException e){
          e.printStackTrace();
        }  

/*     while(sendData && newDataToSend){
    sendFocusData();
    } */
    if(!(newDataToSend)) {
        try {
            Thread.sleep(1);
        } catch (InterruptedException e) {
            println(e.getMessage());
        }
    }

        
  }
   public void update(){
     if (currentBoard.isStreaming()) {
            accumulateNewData();
            checkIfEnoughDataToSend();
        }
      if(newDataToSend){
             sendFocusData();
           }
   }
    
   private void accumulateNewData() {
        // accumulate data
        double[][] newData = currentBoard.getFrameData();
        int[] exgChannels = currentBoard.getEXGChannels();
        
        if (newData[exgChannels[0]].length == 0) {
            return;
        }

        for (int iSample = 0; iSample < newData[exgChannels[0]].length; iSample++) {
            double[] sample = new double[exgChannels.length];
            for (int iChan = 0; iChan < exgChannels.length; iChan++) {
                sample[iChan] = newData[exgChannels[iChan]][iSample];
                //println("CHAN== "+iChan+"  || SAMPLE== "+iSample+"   DATA=="+sample[iChan]);
            }
            dataAccumulationQueue.add(sample);
        }
    }

    private void checkIfEnoughDataToSend() {
        if (dataAccumulationQueue.size() >= nPointsPerUpdate) {
            for (int iSample=0; iSample<nPointsPerUpdate; iSample++) {
                double[] sample = dataAccumulationQueue.pop();

                for (int iChan = 0; iChan < sample.length; iChan++) {
                    dataBufferToSend[iChan][iSample] = (float)sample[iChan];
                }
            }

            newDataToSend = true;
        }
    }
      void sendFocusData() {
        final int IS_METRIC = w_focus.getMetricExceedsThreshold();
           // Send NORMALIZED EMG CHANNEL Data over Serial ... %%%%%
            StringBuilder sb = new StringBuilder();
            sb.append(IS_METRIC);
            sb.append("\n");
            try {
               s.broadcast(sb.toString());
            } catch (Exception e) {
                println("Networking WS: Focus Error");
                println(e.getMessage());
            }
        }

        
    

     void quit() {
       System.out.println("Shutting down websocket");
       try{
        s.stop(5);
       }catch(InterruptedException e){
          e.printStackTrace();
       }

    }
}

/**
 * A simple WebSocketServer implementation. Keeps track of a device connections and facilitates the requested data .
 */
public class DeviceServer extends WebSocketServer {
  public DeviceServer(int port) throws UnknownHostException {
    super(new InetSocketAddress(port));
  }

  public DeviceServer(InetSocketAddress address) {
    super(address);
  }

/*   public DeviceServer(int port, Draft_6455 draft) {
    super(new InetSocketAddress(port), Collections.<Draft>singletonList(draft));
  } */

  @Override
  public void onOpen(WebSocket conn, ClientHandshake handshake) {
   /*  conn.send("Welcome to the server!"); //This method sends a message to the new client
        broadcast("new connection: " + handshake
        .getResourceDescriptor()); //This method sends a message to all clients connected */
    System.out.println(
        conn.getRemoteSocketAddress().getAddress().getHostAddress() + " entered the room!");
  }

  @Override
  public void onClose(WebSocket conn, int code, String reason, boolean remote) {
    broadcast(conn + " has left the room!");
    System.out.println(conn + " has left the room!");
  }

  @Override
  public void onMessage(WebSocket conn, String message) {
    broadcast(message);
    System.out.println(conn + ": " + message);
  }

  @Override
  public void onMessage(WebSocket conn, ByteBuffer message) {
    broadcast(message.array());
    System.out.println(conn + ": " + message);
  }

  @Override
  public void onError(WebSocket conn, Exception ex) {
    ex.printStackTrace();
    if (conn != null) {
      // some errors like port binding failed may not be assignable to a specific websocket
    }
  }

  @Override
  public void onStart() {
    System.out.println("Server started!");
    setConnectionLostTimeout(0);
    setConnectionLostTimeout(100);
  }

}