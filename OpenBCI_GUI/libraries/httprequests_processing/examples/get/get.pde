import http.requests.*;

public void setup()
{
	size(400,400);
	smooth();

	GetRequest get = new GetRequest("http://httprocessing.heroku.com");
	get.send();
	println("Reponse Content: " + get.getContent());
	println("Reponse Content-Length Header: " + get.getHeader("Content-Length"));
}
