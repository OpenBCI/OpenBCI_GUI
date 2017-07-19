# gifAnimation processing library

GifAnimation is a [Processing][1] library to play and export GIF animations. 
Original code by [Patrick Meister][5] .
The GIFEncoder &amp; GIFDecoder classes were written by [Kevin Weiner][2].
Please see the separate copyright notice in the headers of the GifDecoder &amp; GifEncoder classes.
Processing 3.x port by [Jerome Saint-Clair][3]


## DOWNLOAD

[GifAnimation.zip][4] (compatible with Processing 3.x)

##  INSTALLATION:
### Processing 3.x
Download and unzip the gifAnimation.zip and copy the gifAnimation-folder into your processing libraries folder.


## USAGE:

Besides this reference, there are basic examples included in the download. To use gifAnimation library, you need to import it into your sketch by using the menu or typing


```java
import gifAnimation.*;
```

### DISPLAYING A GIF ANIMATION:

The class to access/display GIF animations is called `Gif`. It has two possibilities to access the frame pixel data:

Extract all frames of an animated Gif into a PImage[] array using the static method "getPImages()". you need to pass a reference to the PApplet and a filename to it. The file should be in the sketch data folder. This method is useful if you just want to mess with the frames yourself and don't need the playback possibilities. The method is static, so you have no separate thread going.

```java
PImage[] allFrames = Gif.getPImages(this, "lavalamp.gif");
```
The second way to access the animation is to play it like a video. This will play the animation with the frame delays specified in the GIF file. Gif extends PImage, so any instance of Gif fits wherever PImage can be used.

#### Create a new Gif object


```java
Gif myAnimation = new Gif(PApplet parent, String filename);
```

In a sketch this would look like this:

```java
Gif myAnimation;

void setup() {
    size(400,400);
    myAnimation = new Gif(this, "lavalamp.gif");
    myAnimation.play();
}

void draw() {
    image(myAnimation, 10, 10);
}
```

### EXPORTING A GIF ANIMATION

The class to export GIF animations is called `GifMaker`. To start recording
into a GIF file, create a GifMaker object in one of the following ways:

```java
GifMaker gifExport = new GifMaker(PApplet parent, String filename);
```
```java
GifMaker gifExport = new GifMaker(PApplet parent, String filename, int quality);
```
```java
GifMaker gifExport = new GifMaker(PApplet parent, String filename, int quality, int transparentColor);
```

In a sketch this would look like this:

```java
void setup() {
size(200,200);
    frameRate(12);

    gifExport = new GifMaker(this, "export.gif");
    gifExport.setRepeat(0);				// make it an "endless" animation
    gifExport.setTransparent(0,0,0);	// black is transparent

}

void draw() {
    background(0);
    fill(255);
    ellipse(mouseX, mouseY, 10, 10);

    gifExport.setDelay(1);
    gifExport.addFrame();
}

void mousePressed() {
    gifExport.finish();					// write file
}
```


##DOCUMENTATION
###The 'Gif' Class

####void play()
plays the animation without loop

####void pause()
pauses the animation

####void stop()
stops and rewinds the animation

####void loop()
starts the animation. it will play in a loop and ignore the
GIF repeat setting.

####void noLoop()
disables looping

####void ignoreRepeat()
GIF-files can have a repeat-count setting. It states the amount of loops this animation should perform. if you call `ignoreRepeat()` on a Gif object, it will ingore this setting when playing. If you start animations using `loop()`, repeat settings will always be ignored.

#### void jump(int where)
jumps to a specific frame in the animation if that frame exists

#### boolean isPlaying()
whether the Animation is currently playing

#### boolean isLooping()
whether the Animation has its loop-flag set

#### boolean isIgnoringRepeat()
whether this Gif has its ignoreRepeat-flag set or not.
See also `ignoreRepeat()`

#### int currentFrame()
returns the number of the frame that is currently displayed

#### PImage[] getPImages()
returns an array of PImages containing the animation frames. note that this method is called in an instance of Gif, while `Gif.getPImages(PApplet, String)` is a static method

#### int getRepeat()
returns the number of repeats that is specified in the GIF-file

### The GifMaker Class

#### void setTransparent(int color)
#### void setTransparent(int red, int green, int blue)
#### void setTransparent(float red, float green, float blue)
Sets the transparent color of the GIF file. Unlike other image formats
that support alpha (e.g. PNG), GIF does not support semi-transparent pixels.
The way to achieve transparency is to set a color that will be transparent
when rendering the GIF. So, if you set the transparent color to black, the
black pixels in your gif file will be transparent.

#### void setQuality(int qualtiy)
Sets the quality of the color quantization process. GIF only supports 256 indexed colors per frame. So, the colors that come in your images need to be reduced to a set of 256 colors. The quality of this process can be set using this method (or by instantiating the GifMaker object with the respective constructor). Default is 10 and seems to produce good results. Higher qualities will cause the quantization process to be more expensive in terms of cpu-usage.

#### void setSize(int width, int height)
Sets the size of the new GIF file. If this method is not invoked, the image dimensions of the first added frame will be the size of the GIF.

#### void setRepeat(int count)
Sets the repeat setting in the GIF file. GIF renderers like web browsers should respect this setting and loop the animation that many times before stopping. Default is 1. 0 means endless loop.

#### void addFrame()
Adds the current sketch window content as a new gif frame.
#### void addFrame(PImage image)
Pass a PImage to add it as a new gif frame
#### void addFrame(int[] pixelArray, int width, int height)
Pass a int pixel array and the width and height to add it as a new gif frame.

#### void setDelay(int ms)
Sets the delay (the "framerate") for the most recently added frame. This is measured in Milliseconds. This can be different for every frame. Note, this effects the playback speed of the resulting GIF-file only. So, the speed / framerate with which you wrote the frames has no effect on play-
back speed.

#### void setDispose(int mode)
Sets the disposal mode for the current frame. Disposal modes are a special concept used in the GIF file format. It basically determines whether a frame will be overriden by the next frame, or if the next frame should be added, layed over the last frame.
For convenience there are constants for the different disposal modes:

| Dispose mode |  |
|--------|--------|
| GifMaker.DISPOSE_NOTHING | Nothing special |
| GifMaker.DISPOSE_KEEP | retain the current image |
| GifMaker.DISPOSE\_RESTORE\_BACKGROUND|restore the background color|
| GifMaker.DISPOSE_REMOVE |restore the background color|

#### boolean finish()
Finishes GIF recording and saves the GIF file to the given file name in
the sketch folder. Returns true if saving the file was successful, false if not.

   [1]: http://www.processing.org
   [2]: http://www.fmsware.com/stuff/gif.html
   [3]: http://www.saint-clair.net
   [4]: https://github.com/01010101/GifAnimation/archive/master.zip
   [5]: https://github.com/extrapixel
  
