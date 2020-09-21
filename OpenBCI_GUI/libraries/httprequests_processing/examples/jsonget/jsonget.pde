import http.requests.*;

public void setup() 
{
	size(400,400);
	smooth();
	
  GetRequest get = new GetRequest("https://api.github.com/repos/OpenBCI/OpenBCI_GUI/releases/latest");
  get.send(); // program will wait untill the request is completed
  println("response: " + get.getContent());

  JSONObject response = parseJSONObject(get.getContent());
  //println("status: " + response.getString("status"));
  JSONObject version = response.getJSONArray("tag_name");
  println("version: " + version);
  /*
  for(int i=0;i<boxes.size();i++) {
    JSONObject box = boxes.getJSONObject(i);
    println("  wifiboxid: " + box.getString("wifiboxid"));
  }
  */
}
