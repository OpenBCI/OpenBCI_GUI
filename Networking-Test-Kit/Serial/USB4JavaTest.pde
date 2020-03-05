/*
 * Copyright (C) 2014 Klaus Reimer <k@ailis.de>
 * See LICENSE.txt for licensing information.
 */
import java.nio.ByteBuffer;
import org.usb4java.Context;
import org.usb4java.Device;
import org.usb4java.DeviceDescriptor;
import org.usb4java.DeviceList;
import org.usb4java.LibUsb;
import org.usb4java.LibUsbException;
import org.usb4java.BufferUtils;

// This example will fetch Vendor ID and Product ID for all USB ports
// However, this doesn't help identify COM port names across OS

/**
 * Simply lists all available USB devices.
 * 
 * @author Klaus Reimer <k@ailis.de>
 */

// Create the libusb context
Context context = new Context();

// Initialize the libusb context
int result = LibUsb.init(context);
if (result < 0)
{
    throw new LibUsbException("Unable to initialize libusb", result);
}

// Read the USB device list
DeviceList list = new DeviceList();
result = LibUsb.getDeviceList(context, list);
if (result < 0)
{
    throw new LibUsbException("Unable to get device list", result);
}

try
{
    // Iterate over all devices and list them
    for (Device device: list)
    {
        int address = LibUsb.getDeviceAddress(device);
        int busNumber = LibUsb.getBusNumber(device);
        DeviceDescriptor descriptor = new DeviceDescriptor();
        result = LibUsb.getDeviceDescriptor(device, descriptor);
        if (result < 0)
        {
            throw new LibUsbException(
                "Unable to read device descriptor", result);
        }
        System.out.format(
            "Bus %03d, Device %03d: Vendor %04x, Product %04x%n",
            busNumber, address, descriptor.idVendor(),
            descriptor.idProduct());
        
        println(descriptor.dump());
        
      ByteBuffer path = BufferUtils.allocateByteBuffer(8);
      result = LibUsb.getPortNumbers(device, path);
      if (result > 0)
      {
          for (int i = 0; i < result; i++)
          {                                
              System.out.print(path.get(i));
              if (i + 1 < result) System.out.print("-");
          }
          System.out.println("");
      }                      
        
    }
    
       
}
finally
{
    // Ensure the allocated device list is freed
    LibUsb.freeDeviceList(list, true);
}

// Deinitialize the libusb context
LibUsb.exit(context);