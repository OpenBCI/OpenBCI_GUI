package ddf.minim.tests;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.nio.file.Paths;

import ddf.minim.Minim;
import ddf.minim.spi.AudioRecordingStream;

public class AudioRecordingStreamLoop
{
	String 		fileFolder;
	Minim		minim;
	
	public static void main(String[] args)
	{
		AudioRecordingStreamLoop test = new AudioRecordingStreamLoop();
		
		test.Start(args);
	}
	
	void Start(String[] args)
	{
		fileFolder = args[0];
		
		minim = new Minim(this);
		
		AudioRecordingStream recording = minim.loadFileStream( args[1] );
		
		int loopCount = 1;
		// return -1 for the current test mp3, which means i probably need to test with a wav
		long expectedReads = recording.getSampleFrameLength()*(loopCount+1);
		long reads = 0;
		recording.loop( loopCount );
		while( recording.isPlaying() && reads < expectedReads )
		{
			if ( reads == 743041 )
			{
				System.out.println("..");
			}
			recording.read();
			++reads;
			if ( recording.getLoopCount() == -1 )
			{
				System.err.println( "Loop count became -1 after " + reads + " reads!" );
				break;
			}
		}
		
		if ( expectedReads != reads )
		{
			System.err.println( "Expected " + expectedReads + " reads, and made " + reads );
		}
		else if ( recording.isPlaying() )
		{
			System.err.println( "Recording is still playing after expected number of read." );
		}
	}

	public String sketchPath( String fileName )
	{
		return Paths.get( fileFolder, fileName ).toString();
	}
	
	public InputStream createInput( String fileName )
	{
		FileInputStream stream = null;
		try
		{
			stream = new FileInputStream(sketchPath(fileName));
		}
		catch( FileNotFoundException ex )
		{
			System.err.println( "Unable to find file " + fileName );
		}
		
		return stream;
	}
}
