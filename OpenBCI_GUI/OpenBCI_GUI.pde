import java.util.*;
import org.apache.commons.lang3.SystemUtils;

Map<String, String> bleMACAddrMap = new HashMap<String, String>();
boolean triedOneTime = false;

void settings() {
}

void draw() {
  
  if (triedOneTime) {
    return;
  }

  try {
    bleMACAddrMap = GUIHelper.scan_for_ganglions (3);
    for (Map.Entry<String, String> entry : bleMACAddrMap.entrySet ())
    {
      println(entry.getKey() + " " + entry.getValue());
    }
    
  } catch (GanglionError e) {
      e.printStackTrace();
  }
  
  triedOneTime = true;
  
}
