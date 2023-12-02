package com.openbci.gui;

import processing.core.PApplet;

public class Application extends PApplet {

    public static void main(String[] args) {
        String[] processingArgs = { "Application" };
        Application application = new Application();
        PApplet.runSketch(processingArgs, application);
    }
}
