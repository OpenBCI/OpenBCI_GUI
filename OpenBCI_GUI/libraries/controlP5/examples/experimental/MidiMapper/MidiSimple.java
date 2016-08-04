import java.util.HashMap;
import java.util.Map;

import javax.sound.midi.MidiDevice;
import javax.sound.midi.MidiMessage;
import javax.sound.midi.MidiSystem;
import javax.sound.midi.MidiUnavailableException;
import javax.sound.midi.Receiver;
import javax.sound.midi.Transmitter;

public class MidiSimple {

  public MidiSimple( String theDeviceName , Receiver theReceiver ) {

    MidiDevice.Info[] aInfos = MidiSystem.getMidiDeviceInfo();
    for ( int i = 0; i < aInfos.length; i++ ) {
      try {
        MidiDevice device = MidiSystem.getMidiDevice( aInfos[ i ] );
        boolean bAllowsInput = ( device.getMaxTransmitters() != 0 );
        boolean bAllowsOutput = ( device.getMaxReceivers() != 0 );
        System.out.println( "" + i + "  " + ( bAllowsInput ? "IN " : "   " ) + ( bAllowsOutput ? "OUT " : "    " ) + aInfos[ i ].getName() + ", " + aInfos[ i ].getVendor() + ", "
          + aInfos[ i ].getVersion() + ", " + aInfos[ i ].getDescription() );
      } 
      catch ( MidiUnavailableException e ) {
        // device is obviously not available...
        // out(e);
      }
    }
    
    try {
      MidiDevice device;
      device = MidiSystem.getMidiDevice( getMidiDeviceInfo( theDeviceName, false ) );
      device.open();
      Transmitter conTrans = device.getTransmitter();
      conTrans.setReceiver( theReceiver );
    } 
    catch ( MidiUnavailableException e ) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    } catch (NullPointerException e) {
      System.out.println("No Midi device ( "+theDeviceName+" ) is available.");
    }
    
  }
  
  public MidiSimple( String theDeviceName ) {
    new MidiSimple(theDeviceName , new MidiInputReceiver( theDeviceName ) );
  }
  

  public MidiDevice.Info getMidiDeviceInfo( String strDeviceName, boolean bForOutput ) {
    MidiDevice.Info[] aInfos = MidiSystem.getMidiDeviceInfo();
    for ( int i = 0; i < aInfos.length; i++ ) {
      if ( aInfos[ i ].getName().equals( strDeviceName ) ) {
        try {
          MidiDevice device = MidiSystem.getMidiDevice( aInfos[ i ] );
          boolean bAllowsInput = ( device.getMaxTransmitters() != 0 );
          boolean bAllowsOutput = ( device.getMaxReceivers() != 0 );
          if ( ( bAllowsOutput && bForOutput ) || ( bAllowsInput && !bForOutput ) ) {
            return aInfos[ i ];
          }
        } 
        catch ( MidiUnavailableException e ) {
          // TODO:
        }
      }
    }
    return null;
  }

  class MidiInputReceiver implements Receiver {
    public String name;
    Map< Byte, String > commandMap = new HashMap< Byte, String >();

    public MidiInputReceiver( String name ) {
      this.name = name;
      commandMap.put( ( byte ) -112, "Note On" );
      commandMap.put( ( byte ) -128, "Note Off" );
      commandMap.put( ( byte ) -48, "Channel Pressure" );
      commandMap.put( ( byte ) -80, "Continuous Controller" );
    }

    public void send( MidiMessage msg, long timeStamp ) {
      System.out.println( "midi received (" + name + ")" );
      System.out.println( "Timestamp: " + timeStamp );
      byte[] b = msg.getMessage();

      if ( b[ 0 ] != -48 ) {
        // System.out.println("Message length: " + msg.getLength());
        System.out.println( "Note command: " + commandMap.get( b[ 0 ] ) );
        System.out.println( "Which note: " + b[ 1 ] );
        System.out.println( "Note pressure: " + b[ 2 ] );
        System.out.println( "---------------------" );
      } 
      else {
        // System.out.println("Message length: " + msg.getLength());
        System.out.println( "Note command: " + commandMap.get( b[ 0 ] ) );
        System.out.println( "Note Pressure: " + b[ 1 ] );
        System.out.println( "---------------------" );
      }
    }

    public void close( ) {
    }
  }
}

