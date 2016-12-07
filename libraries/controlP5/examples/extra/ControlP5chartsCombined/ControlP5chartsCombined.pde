/**
* ControlP5 ControlP5chartsCombined
*
* find a list of public methods available for the Chart Controller
* at the bottom of this sketch.
*
* by Andreas Schlegel, 2012
* www.sojamo.de/libraries/controlp5
*
*/


import controlP5.*;

ControlP5 cp5;

Chart myChart;

void setup() {
  size(400, 700);
  smooth();
  cp5 = new ControlP5(this);
  cp5.printPublicMethodsFor(Chart.class);
  myChart = cp5.addChart("hello")
               .setPosition(50, 50)
               .setSize(200, 200)
               .setRange(-20, 20)
               .setView(Chart.BAR) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
               ;

  myChart.getColor().setBackground(color(255, 100));


  myChart.addDataSet("world");
  myChart.setColors("world", color(255,0,255),color(255,0,0));
  myChart.setData("world", new float[4]);

  myChart.setStrokeWeight(1.5);

  myChart.addDataSet("earth");
  myChart.setColors("earth", color(255), color(0, 255, 0));
  myChart.updateData("earth", 1, 2, 10, 3);

}


void draw() {
  background(0);
  // unshift: add data from left to right (first in)
  myChart.unshift("world", (sin(frameCount*0.01)*10));
  
  // push: add data from right to left (last in)
  myChart.push("earth", (sin(frameCount*0.1)*10));
}







/*
a list of all methods available for the Chart Controller
use ControlP5.printPublicMethodsFor(Chart.class);
to print the following list into the console.

You can find further details about class Chart in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.Chart : Chart addData(ChartData) 
controlP5.Chart : Chart addData(ChartDataSet, float) 
controlP5.Chart : Chart addData(String, ChartData) 
controlP5.Chart : Chart addData(String, float) 
controlP5.Chart : Chart addData(float) 
controlP5.Chart : Chart addDataSet(String) 
controlP5.Chart : Chart addFirst(String, float) 
controlP5.Chart : Chart addFirst(float) 
controlP5.Chart : Chart addLast(String, float) 
controlP5.Chart : Chart addLast(float) 
controlP5.Chart : Chart push(String, float) 
controlP5.Chart : Chart push(float) 
controlP5.Chart : Chart removeData(ChartData) 
controlP5.Chart : Chart removeData(String, ChartData) 
controlP5.Chart : Chart removeData(String, int) 
controlP5.Chart : Chart removeData(int) 
controlP5.Chart : Chart removeDataSet(String) 
controlP5.Chart : Chart removeFirst() 
controlP5.Chart : Chart removeFirst(String) 
controlP5.Chart : Chart removeLast() 
controlP5.Chart : Chart removeLast(String) 
controlP5.Chart : Chart setData(String, int, ChartData) 
controlP5.Chart : Chart setData(int, ChartData) 
controlP5.Chart : Chart setDataSet(ChartDataSet) 
controlP5.Chart : Chart setDataSet(String, ChartDataSet) 
controlP5.Chart : Chart setRange(float, float) 
controlP5.Chart : Chart setResolution(int) 
controlP5.Chart : Chart setStrokeWeight(float) 
controlP5.Chart : Chart setValue(float) 
controlP5.Chart : Chart setView(int) 
controlP5.Chart : Chart unshift(String, float) 
controlP5.Chart : Chart unshift(float) 
controlP5.Chart : ChartData getData(String, int) 
controlP5.Chart : ChartDataSet getDataSet(String) 
controlP5.Chart : LinkedHashMap getDataSet() 
controlP5.Chart : String getInfo() 
controlP5.Chart : String toString() 
controlP5.Chart : float getStrokeWeight() 
controlP5.Chart : float[] getValuesFrom(String) 
controlP5.Chart : int getResolution() 
controlP5.Chart : int size() 
controlP5.Chart : void onEnter() 
controlP5.Chart : void onLeave() 
controlP5.Controller : CColor getColor() 
controlP5.Controller : Chart addCallback(CallbackListener) 
controlP5.Controller : Chart addListener(ControlListener) 
controlP5.Controller : Chart addListenerFor(int, CallbackListener) 
controlP5.Controller : Chart align(int, int, int, int) 
controlP5.Controller : Chart bringToFront() 
controlP5.Controller : Chart bringToFront(ControllerInterface) 
controlP5.Controller : Chart hide() 
controlP5.Controller : Chart linebreak() 
controlP5.Controller : Chart listen(boolean) 
controlP5.Controller : Chart lock() 
controlP5.Controller : Chart onChange(CallbackListener) 
controlP5.Controller : Chart onClick(CallbackListener) 
controlP5.Controller : Chart onDoublePress(CallbackListener) 
controlP5.Controller : Chart onDrag(CallbackListener) 
controlP5.Controller : Chart onDraw(ControllerView) 
controlP5.Controller : Chart onEndDrag(CallbackListener) 
controlP5.Controller : Chart onEnter(CallbackListener) 
controlP5.Controller : Chart onLeave(CallbackListener) 
controlP5.Controller : Chart onMove(CallbackListener) 
controlP5.Controller : Chart onPress(CallbackListener) 
controlP5.Controller : Chart onRelease(CallbackListener) 
controlP5.Controller : Chart onReleaseOutside(CallbackListener) 
controlP5.Controller : Chart onStartDrag(CallbackListener) 
controlP5.Controller : Chart onWheel(CallbackListener) 
controlP5.Controller : Chart plugTo(Object) 
controlP5.Controller : Chart plugTo(Object, String) 
controlP5.Controller : Chart plugTo(Object[]) 
controlP5.Controller : Chart plugTo(Object[], String) 
controlP5.Controller : Chart registerProperty(String) 
controlP5.Controller : Chart registerProperty(String, String) 
controlP5.Controller : Chart registerTooltip(String) 
controlP5.Controller : Chart removeBehavior() 
controlP5.Controller : Chart removeCallback() 
controlP5.Controller : Chart removeCallback(CallbackListener) 
controlP5.Controller : Chart removeListener(ControlListener) 
controlP5.Controller : Chart removeListenerFor(int, CallbackListener) 
controlP5.Controller : Chart removeListenersFor(int) 
controlP5.Controller : Chart removeProperty(String) 
controlP5.Controller : Chart removeProperty(String, String) 
controlP5.Controller : Chart setArrayValue(float[]) 
controlP5.Controller : Chart setArrayValue(int, float) 
controlP5.Controller : Chart setBehavior(ControlBehavior) 
controlP5.Controller : Chart setBroadcast(boolean) 
controlP5.Controller : Chart setCaptionLabel(String) 
controlP5.Controller : Chart setColor(CColor) 
controlP5.Controller : Chart setColorActive(int) 
controlP5.Controller : Chart setColorBackground(int) 
controlP5.Controller : Chart setColorCaptionLabel(int) 
controlP5.Controller : Chart setColorForeground(int) 
controlP5.Controller : Chart setColorLabel(int) 
controlP5.Controller : Chart setColorValue(int) 
controlP5.Controller : Chart setColorValueLabel(int) 
controlP5.Controller : Chart setDecimalPrecision(int) 
controlP5.Controller : Chart setDefaultValue(float) 
controlP5.Controller : Chart setHeight(int) 
controlP5.Controller : Chart setId(int) 
controlP5.Controller : Chart setImage(PImage) 
controlP5.Controller : Chart setImage(PImage, int) 
controlP5.Controller : Chart setImages(PImage, PImage, PImage) 
controlP5.Controller : Chart setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : Chart setLabel(String) 
controlP5.Controller : Chart setLabelVisible(boolean) 
controlP5.Controller : Chart setLock(boolean) 
controlP5.Controller : Chart setMax(float) 
controlP5.Controller : Chart setMin(float) 
controlP5.Controller : Chart setMouseOver(boolean) 
controlP5.Controller : Chart setMoveable(boolean) 
controlP5.Controller : Chart setPosition(float, float) 
controlP5.Controller : Chart setPosition(float[]) 
controlP5.Controller : Chart setSize(PImage) 
controlP5.Controller : Chart setSize(int, int) 
controlP5.Controller : Chart setStringValue(String) 
controlP5.Controller : Chart setUpdate(boolean) 
controlP5.Controller : Chart setValue(float) 
controlP5.Controller : Chart setValueLabel(String) 
controlP5.Controller : Chart setValueSelf(float) 
controlP5.Controller : Chart setView(ControllerView) 
controlP5.Controller : Chart setVisible(boolean) 
controlP5.Controller : Chart setWidth(int) 
controlP5.Controller : Chart show() 
controlP5.Controller : Chart unlock() 
controlP5.Controller : Chart unplugFrom(Object) 
controlP5.Controller : Chart unplugFrom(Object[]) 
controlP5.Controller : Chart unregisterTooltip() 
controlP5.Controller : Chart update() 
controlP5.Controller : Chart updateSize() 
controlP5.Controller : ControlBehavior getBehavior() 
controlP5.Controller : ControlWindow getControlWindow() 
controlP5.Controller : ControlWindow getWindow() 
controlP5.Controller : ControllerProperty getProperty(String) 
controlP5.Controller : ControllerProperty getProperty(String, String) 
controlP5.Controller : ControllerView getView() 
controlP5.Controller : Label getCaptionLabel() 
controlP5.Controller : Label getValueLabel() 
controlP5.Controller : List getControllerPlugList() 
controlP5.Controller : Pointer getPointer() 
controlP5.Controller : String getAddress() 
controlP5.Controller : String getInfo() 
controlP5.Controller : String getName() 
controlP5.Controller : String getStringValue() 
controlP5.Controller : String toString() 
controlP5.Controller : Tab getTab() 
controlP5.Controller : boolean isActive() 
controlP5.Controller : boolean isBroadcast() 
controlP5.Controller : boolean isInside() 
controlP5.Controller : boolean isLabelVisible() 
controlP5.Controller : boolean isListening() 
controlP5.Controller : boolean isLock() 
controlP5.Controller : boolean isMouseOver() 
controlP5.Controller : boolean isMousePressed() 
controlP5.Controller : boolean isMoveable() 
controlP5.Controller : boolean isUpdate() 
controlP5.Controller : boolean isVisible() 
controlP5.Controller : float getArrayValue(int) 
controlP5.Controller : float getDefaultValue() 
controlP5.Controller : float getMax() 
controlP5.Controller : float getMin() 
controlP5.Controller : float getValue() 
controlP5.Controller : float[] getAbsolutePosition() 
controlP5.Controller : float[] getArrayValue() 
controlP5.Controller : float[] getPosition() 
controlP5.Controller : int getDecimalPrecision() 
controlP5.Controller : int getHeight() 
controlP5.Controller : int getId() 
controlP5.Controller : int getWidth() 
controlP5.Controller : int listenerSize() 
controlP5.Controller : void remove() 
controlP5.Controller : void setView(ControllerView, int) 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2014/08/16 19:11:34

*/


