///////////////////////////////////////////////
//
// Created: Chip Audette, Oct 2013
// Modified: through May 2014
//
// No warranty.  Use at your own risk.  Use for whatever you'd like.
// 
///////////////////////////////////////////////


//import ddf.minim.analysis.*; //for FFT

class Spectrogram {
  public int Nfft;
  //public float dataSlices[][];   //holds the data in [Nslices][Nfft] manner
  //public float dT_perSlice_sec;  //time interval between slices
  public float fs_Hz;            //sample rate
  public PImage img;
  public double clim[] = {0.0d, 1.0d};
  private FFT localFftData;
  private float[] localDataBuff;
  private int localDataBuffCounter;
  public int fft_stepsize;
  public int Nslices;
  
  
  Spectrogram(int N, float fs, int fft_step, float tmax_sec) {
    println("Spectrogram: N, fs, fft_step, tmax_sec = " + N + " " + fs + " " + fft_step + " " + tmax_sec);
    Nfft=N;
    fs_Hz = fs;
    //dT_perSlice_sec = ((float)Nfft) / fs;
    fft_stepsize = constrain(fft_step,1,Nfft);
//    clim[0] = java.lang.Math.log(0.01f);
//    clim[1] = java.lang.Math.log(200.0f);
         
    //create zero data for the local time-domain buffer
    localDataBuff = new float[Nfft];
    for (int I=0; I < Nfft; I++) {
      localDataBuff[I] = 0.0f; //initialize
    }
    localDataBuffCounter = Nfft-fft_stepsize;
    
    //initialize FFT 
    localFftData = new FFT(Nfft, fs_Hz);
    localFftData.window(FFT.HAMMING);
    
    //create the image
    int tmax_samps = (int)(tmax_sec * fs_Hz + 0.5f);  //the 0.5 is to round, not truncate
    Nslices = (int)(((float)(tmax_samps-Nfft))/((float)fft_stepsize+0.5)) + 1;
    img = createImage(Nslices,localFftData.specSize(),RGB);
    println("Spectrogram: image is " + Nslices + " x " + localFftData.specSize());
    img.loadPixels(); //this is apparently necessary to allocate the space for the pixels
    int count=0;
    for (int J=0; J < localFftData.specSize(); J++) {
      for (int I=0; I<Nslices;I++) {
        img.pixels[count]=getColor(java.lang.Math.log(0.0001f));
        count++;
      }
    }
    img.updatePixels();   
  }
  
  public void addDataPoint(float dataPoint) {
    
    //add point
    localDataBuff[localDataBuffCounter] = dataPoint;
    //println("Spectrogram.addDataPoint(): counter = " + localDataBuffCounter + ", data = " + localDataBuff[localDataBuffCounter]);
     
    //increment counter for next time
    localDataBuffCounter++;
    
    //are we full?
    if (localDataBuffCounter >= Nfft) {
      //println("Spectrogra.addDataPoint(): processing the FFT block");
      
      //compute the new FFT and update the overall image
      addDataBlock(localDataBuff);
        
      //shift the data buffer to make space for the next points
      //println("addDataPoint: Nfft, fft_stepsize + " + Nfft + " " + fft_stepsize);
      for (int I=0; I < (Nfft-fft_stepsize); I++) {
        localDataBuff[I]=localDataBuff[(int)(I+fft_stepsize)];
        //println("addDataPoint: Shifting " + I + " from " + (I+fft_stepsize) + ", val = " + (localDataBuff[I]));
      }
      
      //point the counter to the new location to start accumulating data
      localDataBuffCounter = Nfft-fft_stepsize;
    }
  } 

  public void addDataBlock(float[] dataHere) {
    float foo;
        
    //do the FFT on the data block
    float[] localCopy = new float[dataHere.length];
    localCopy = Arrays.copyOfRange(dataHere,0, dataHere.length);
    float meanVal = mean(localCopy);
    for (int I=0; I<localCopy.length;I++) localCopy[I] -= meanVal;  //remove mean before doing FFT
    localFftData.forward(localCopy);
    
    //convert fft data to uV_per_sqrtHz
    //final float mean_winpow_sqr = 0.3966;  //account for power lost when windowing...mean(hamming(N).^2) = 0.3966
    final float mean_winpow = 1.0f/sqrt(2.0f);  //account for power lost when windowing...mean(hamming(N).^2) = 0.3966
    final float scale_rawPSDtoPSDPerHz = ((float)localFftData.specSize())*fs_Hz*mean_winpow; //normalize the amplitude by the number of bins to get the correct scaling to uV/sqrt(Hz)???
    for (int I=0; I < localFftData.specSize(); I++) {  //loop over each FFT bin
      foo = sqrt(pow(localFftData.getBand(I),2)/scale_rawPSDtoPSDPerHz);
      //if ((I > 5) & (I < 15)) println("Spectrogram: uV/rtHz = " + I + " " + foo);
      localFftData.setBand(I,foo);
    }

    //update image...shift all previous pixels to the left
    int pixel_ind=0;
    int nPixelsWide = Nslices;
    for (int J=0; J < localFftData.specSize(); J++) {
      for (int I=0; I < (nPixelsWide-1); I++) {
        pixel_ind = J*nPixelsWide + I;
        img.pixels[pixel_ind] =   img.pixels[pixel_ind+1];
      }
    }

    //update image...set the color based on the latest data
    for (int J=0; J < localFftData.specSize(); J++) {
      pixel_ind = (localFftData.specSize()-J-1)*nPixelsWide + (nPixelsWide-1); //build from bottom-left
      foo = localFftData.getBand(J); foo=max(foo,0.001f);
      img.pixels[pixel_ind] = getColor(java.lang.Math.log(foo));
    }
    
    //we're finished with the pixels, so update the image
    //println("addNewData: updating the pixels");
    img.updatePixels();
  }
  
  //model after matlab's "jet" color scheme
  private color getColor(double given_val) {
    float r,b,g;
    float val = (float)((given_val - clim[0])/(clim[1]-clim[0]));
    val = min(1.0f,max(0.0f,val)); //span [0.0 1.0]
    
    //compute color
    float[] bounds = {1.0f/8.0f, 3.0f/8.0f, 5.0f/8.0f, 7.0f/8.0f};
    if (val < bounds[0]) {
      r = 0.0f;
      g = 0.0f;
      b = map(val,0.0f,bounds[0],0.5f,1.0f);
    } else if (val <  bounds[1]) {
      r = 0.0f;
      g = map(val,bounds[0],bounds[1],0.0f,1.0f);
      b = 1.0f;
    } else if (val < bounds[2]) {
      r = map(val,bounds[1],bounds[2],0.0f,1.0f);
      g = 1.0f;
      b = map(val,bounds[1],bounds[2],1.0f,0.0f);
    } else if (val < bounds[3]) {
      r = 1.0f;
      g = map(val,bounds[2],bounds[3],1.0f,0.0f);
      b = 0.0f;
    } else {
      r = map(val,bounds[3],1.0f,1.0f,0.5f);
      g = 0.0f;
      b = 0.0f;
    } 
    return color((int)(r*255.f),(int)(g*255.f),(int)(b*255.f));
  }
  
  public void draw(int x, int y, int w, int h,float max_freq_Hz) {
    //float max_freq_Hz = freq_lim_Hz[1];
    int max_ind = 0;
    while ((localFftData.indexToFreq(max_ind) <= max_freq_Hz) & (max_ind < localFftData.specSize()-1)) max_ind++;
    //println("Spectrogram.draw(): max_ind = " + max_ind);
    //PImage foo = (PImage)(img.get(0,localFftData.specSize()-1-max_ind,Nslices,localFftData.specSize()-1)).clone();
    //println("spectrogram.draw() max freq = " + localFftData.indexToFreq(max_ind));
    int img_x = 0; 
    int img_y = localFftData.specSize()-1-max_ind; 
    int img_w = Nslices - img_x + 1;
    int img_h = localFftData.specSize()-1 - img_y + 1;
    image(img.get(img_x,img_y,img_w,img_h),x,y,w,h); //plot a subset
  }
}