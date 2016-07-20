package ddf.minim.tests;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.nio.file.Paths;

import ddf.minim.AudioPlayer;
import ddf.minim.Minim;

public class MultipleAudioPlayers
{
	boolean   	running;
	String 		fileFolder;
	Minim		minim;
	
	public static void main(String[] args)
	{
		MultipleAudioPlayers test = new MultipleAudioPlayers();
		
		test.Start(args);
	}
	
	void Start(String[] args)
	{
		fileFolder = args[0];
		
		minim = new Minim(this);
		
		for (int i = 0; i < 17; ++i)
		{
			AudioPlayer player = minim.loadFile( args[1] );
			if ( player == null )
			{
				System.out.println("File loading failed on attempt " + i);
				break;
			}
		}

		minim.stop();
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
