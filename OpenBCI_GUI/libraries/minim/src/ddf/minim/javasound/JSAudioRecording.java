/*
 *  Copyright (c) 2007 - 2008 by Damien Di Fede <ddf@compartmental.net>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as published
 *   by the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details.
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the Free Software
 *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

package ddf.minim.javasound;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.Control;
import javax.sound.sampled.SourceDataLine;

import org.tritonus.share.sampled.AudioUtils;

import ddf.minim.AudioMetaData;
import ddf.minim.Minim;
import ddf.minim.MultiChannelBuffer;
import ddf.minim.spi.AudioRecording;

// TODO: there is so much here that is the same as JSBaseAudioRecordingStream
//       should find a way to share that code.
// TODO (ddf): really need to talk about why this is deprecated and how to deal with it moving forward.
/** @deprecated */
class JSAudioRecording implements AudioRecording, Runnable
{
    private AudioMetaData  meta;
    private byte[]         samples;
    private Thread         iothread;

    // reading stuff
    private boolean        play;
    private boolean        loop;
    private int            numLoops;
    // loop begin is in milliseconds
    private int            loopBegin;
    // loop end is in bytes
    private int            loopEnd;
    private byte[]         rawBytes;
    private int            totalBytesRead;
    // see JSBaseAudioRecordingStream for a discussion of these.
    private boolean        shouldRead;
    private int            bytesWritten;

    // writing stuff
    protected AudioFormat  format;
    private SourceDataLine line;
    private boolean        finished;

    private JSMinim        system;

    JSAudioRecording(JSMinim sys, byte[] samps, SourceDataLine sdl,
            AudioMetaData mdata)
    {
        system = sys;
        samples = samps;
        meta = mdata;
        format = sdl.getFormat();
        finished = false;
        line = sdl;
        loop = false;
        play = false;
        numLoops = 0;
        loopBegin = 0;
        loopEnd = (int)AudioUtils.millis2BytesFrameAligned( meta.length(),
                format );
        rawBytes = new byte[sdl.getBufferSize() / 8];
        iothread = null;
        totalBytesRead = 0;
        bytesWritten = 0;
        shouldRead = true;
    }

    public void run()
    {
        while ( !finished )
        {
            if ( play )
            {
                if ( shouldRead )
                {
                    // read in a full buffer of bytes from the file
                    if ( loop )
                    {
                        readBytesLoop();
                    }
                    else
                    {
                        readBytes();
                    }
                }
                // write to the line until all bytes are written
                writeBytes();
                // take a nap
                Thread.yield();
            }
            else
            {
                // we'll be interrupted if we should start playing again.
                sleep( 30000 );
            }
        } // while ( !finished )

        // flush the line before we close it. because that is polite.
        line.flush();
        line.close();
        line = null;
    }

    private void sleep(int millis)
    {
        try
        {
            Thread.sleep( millis );
        }
        catch ( InterruptedException e )
        {
        }
    }

    private synchronized void readBytes()
    {
        int samplesLeft = samples.length - totalBytesRead;
        if ( samplesLeft < rawBytes.length )
        {
            readBytes( samplesLeft, 0 );
            system.debug( "readBytes: filling rawBytes from " + samplesLeft
                    + " to " + rawBytes.length + " with silence." );
            byte silent = 0;
            // unsigned source means we need to make the silence the neutral
            // value,
            // which is exactly half as large as a byte can be.
            if ( format.getEncoding() == AudioFormat.Encoding.PCM_UNSIGNED )
            {
                silent = (byte)0x80;
            }
            for ( int i = samplesLeft; i < rawBytes.length; i++ )
            {
                rawBytes[i] = silent;
            }
            play = false;
        }
        else
        {
            readBytes( rawBytes.length, 0 );
        }
    }

    private synchronized void readBytesLoop()
    {
        int toLoopEnd = loopEnd - totalBytesRead;
        if ( toLoopEnd <= 0 )
        {
            // whoops, our loop end point got switched up
            setMillisecondPosition( loopBegin );
            readBytesLoop();
            return;
        }
        if ( toLoopEnd < rawBytes.length )
        {
            readBytes( toLoopEnd, 0 );
            if ( loop && numLoops == 0 )
            {
                loop = false;
                play = false;
            }
            else if ( loop )
            {
                setMillisecondPosition( loopBegin );
                readBytes( rawBytes.length - toLoopEnd, toLoopEnd );
                if ( numLoops != Minim.LOOP_CONTINUOUSLY )
                {
                    numLoops--;
                }
            }
        }
        else
        {
            readBytes( rawBytes.length, 0 );
        }
    }

    // copy toRead bytes from samples to rawBytes,
    // starting at offet into rawBytes
    private void readBytes(int toRead, int offset)
    {
        System.arraycopy( samples, totalBytesRead, rawBytes, offset, toRead );
        totalBytesRead += toRead;
    }

    private void writeBytes()
    {
        // the write call will block until the requested amount of bytes
        // is written, however the user might stop the line in the
        // middle of writing and then we get told how much was actually written.
        // because of that, we might not need to write the entire array when we
        // get here.
        int needToWrite = rawBytes.length - bytesWritten;
        int actualWrit = line.write( rawBytes, bytesWritten, needToWrite );
        // if the total written is not equal to how much we needed to write
        // then we need to remember where we were so that we don't read more
        // until we finished writing our entire rawBytes array.
        if ( actualWrit != needToWrite )
        {
            shouldRead = false;
            bytesWritten += actualWrit;
        }
        else
        {
            // if it all got written, we should continue reading
            // and we reset our bytesWritten value.
            shouldRead = true;
            bytesWritten = 0;
        }
    }

    public void play()
    {
        line.start();
        loop = false;
        numLoops = 0;
        play = true;
        iothread.interrupt();
    }

    public boolean isPlaying()
    {
        return play;
    }

    public void pause()
    {
        line.stop();
        play = false;
    }

    public void loop(int n)
    {
        loop = true;
        numLoops = n;
        play = true;
        setMillisecondPosition( loopBegin );
        line.start();
        iothread.interrupt();
    }

    public void open()
    {
        iothread = new Thread( this );
        finished = false;
        iothread.start();
    }

    public void close()
    {
        line.stop();
        finished = true;
        try
        {
            iothread.join( 10 );
        }
        catch ( InterruptedException e )
        {
            e.printStackTrace();
        }
        iothread = null;
    }

    public AudioFormat getFormat()
    {
        return format;
    }

    public int getLoopCount()
    {
        return numLoops;
    }

    public synchronized void setLoopPoints(int start, int stop)
    {
        if ( start <= 0 || start > stop )
        {
            loopBegin = 0;
        }
        else
        {
            loopBegin = start;
        }
        if ( stop <= getMillisecondLength() && stop > start )
        {
            loopEnd = (int)AudioUtils.millis2BytesFrameAligned( stop, format );
        }
        else
        {
            loopEnd = (int)AudioUtils.millis2BytesFrameAligned( getMillisecondLength(), format );
        }
    }

    public int getMillisecondPosition()
    {
        return (int)AudioUtils.bytes2Millis( totalBytesRead, format );
    }

    public synchronized void setMillisecondPosition(int millis)
    {
        if ( millis <= 0 )
        {
            totalBytesRead = 0;
        }
        else if ( millis > getMillisecondLength() )
        {
            totalBytesRead = samples.length;
        }
        else
        {
            totalBytesRead = (int)AudioUtils.millis2BytesFrameAligned( millis, format );
        }
    }

    public Control[] getControls()
    {
        return line.getControls();
    }

    public AudioMetaData getMetaData()
    {
        return meta;
    }

    public int getMillisecondLength()
    {
        return meta.length();
    }

    public int bufferSize()
    {
        return 0;
    }

    public float[] read()
    {
        return null;
    }

    public int read(MultiChannelBuffer buffer)
    {
    	return 0;
    }
}
