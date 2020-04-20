import com.fazecast.jSerialComm.*;

println("GETTING A LIST OF SERIAL PORTS: ");

printArray(SerialPort.getCommPorts());

SerialPort comPort = SerialPort.getCommPorts()[1];

println(comPort.getSystemPortName());

println("Done :)");