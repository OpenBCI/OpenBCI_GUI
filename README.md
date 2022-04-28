# The OpenBCI GUI

<p align="center">
  <img alt="banner" src="/images/GUI-V4-Screenshot.jpg/" width="600">
</p>
<p align="center" href="">
  Provide a stable and powerful interface for any OpenBCI device
</p>

## Welcome!

First and foremost, Welcome! :tada: Willkommen! :confetti_ball: Bienvenue! :balloon::balloon::balloon:

Thank you for visiting the OpenBCI GUI repository.

This document (the README file) is a hub to give you some information about the project. Jump straight to one of the sections below, or just scroll down to find out more.

* [What are we doing? (And why?)](#what-are-we-doing)
* [Who are we?](#who-are-we)
* [What do we need?](#what-do-we-need)
* [How can you get involved?](#get-involved)
* [Get in touch](#contact-us)
* [Find out more](#find-out-more)
* [Installing](#installing)

## What are we doing?

### The problem

* OpenBCI device owners want to visualize their brainwaves!
* Many of the researchers, hackers and students alike who purchase OpenBCI devices want to use them to acquire data as soon as their device arrives.
* Users use macOS, Windows and Linux to acquire data
* Users want to filter incoming data in real time
* Users want to make their own experiments to test their awesome theories or duplicate state of the art research at home!
* Users struggle to get prerequisites properly installed to get data on their own from OpenBCI Cyton and Ganglion.
* Users want to stream data into their own custom applications such as MATLAB.

So, if even the very best researchers and hackers buy OpenBCI, there is still a lot of work needed to be done to visualize the data.

### The solution

The OpenBCI GUI will:

* Visualize data from every OpenBCI device: [Ganglion][link_shop_ganglion], [Cyton][link_shop_cyton], [Cyton with Daisy][link_shop_cyton_daisy], and the [WiFi Shield][link_shop_wifi_shield]
* Run as a native application on macOS, Windows, and Linux.
* Provide filters and other data processing tools to quickly clean raw data in real time
* Provide a networking system to move data out of GUI into other apps over UDP, OSC, LSL, and Serial.
* Provide a widget framework that allows users to create their own experiments.
* Provide the ability to output data into a saved file for later offline processing.

Using the OpenBCI GUI allows you, the user, to quickly visualize and use your OpenBCI device. Further it should allow you to build on our powerful framework to implement your own great ideas!

## Who are we?

Mainly, we are OpenBCI. The original code writer was Chip Audette, along with Conor Russomanno and Joel Murphy. AJ Keller, Gabriel Diaz, Richard Waltman, and Daniel Lasry have all made major contributions as well. 

## What do we need?

**You**! In whatever way you can help.

We need expertise in programming, user experience, software sustainability, documentation and technical writing and project management.

We'd love your feedback along the way.

Our primary goal is to provide a stable and powerful interface for any OpenBCI device, and we're excited to support the professional development of any and all of our contributors. If you're looking to learn to code, try out working collaboratively, or translate you skills to the digital domain, we're here to help.

## Get involved

If you think you can help in any of the areas listed above (and we bet you can) or in any of the many areas that we haven't yet thought of (and here we're *sure* you can) then please check out our [contributors' guidelines](CONTRIBUTING.md) and our [roadmap](ROADMAP.md).

Please note that it's very important to us that we maintain a positive and supportive environment for everyone who wants to participate. When you join us we ask that you follow our [code of conduct](CODE_OF_CONDUCT.md) in all interactions both on and offline.


## Contact us

If you want to report a problem or suggest an enhancement, we'd love for you to [open an issue](../../issues) at this github repository so we can get right on it!

## Find out more

You might be interested in:

* A tutorial to [make your own GUI Widget][link_gui_widget_tutorial]
* Purchase a [Cyton][link_shop_cyton] | [Ganglion][link_shop_ganglion] | [WiFi Shield][link_shop_wifi_shield] from [OpenBCI][link_openbci]

And of course, you'll want to know our:

* [Contributors' guidelines](CONTRIBUTING.md)
* [Roadmap](ROADMAP.md)

## Thank you

Thank you so much (Danke schön! Merci beaucoup!) for visiting the project and we do hope that you'll join us on this amazing journey to provide a stable and powerful interface for any OpenBCI device.

## Installing

Follow the guide to [Run the OpenBCI GUI From Processing IDE][link_gui_run_from_processing]. If you find issues in the guide, please [suggest changes](https://github.com/OpenBCI/Docs/edit/master/OpenBCI%20Software/01-OpenBCI_GUI.md)!

**Please use Processing 3.5.3 for all operating systems.**

### System Requirements
#### Hardware
- 1.6 GHz or faster processor
- 2 GB of RAM
- 400 MB of hard drive space (minimum)

#### Platforms
OpenBCI GUI has been tested on the following platforms:
- OS X 10.8.5 or later
- Windows 8.1 and 10 (64-bit)
- Linux Ubuntu Desktop 18

OpenGL acceleration is required.


## Troubleshooting
- **When making an issue here on GitHub, please use an Issue or New Feature Template.** Otherwise, the issue will be closed and you will be asked to make a new issue using a template. This maintains a standard of communication and helps resolve issues in a timely manner.

- If you are on a Mac and you seem to get a "spinning wheel of death" when trying to open a dialog box to view files (example "SELECT PLAYBACK FILE" button), [please update your Java Runtime Environment](https://www.java.com/en/download/). This happens because Java was not packaged with a version of the GUI producing this error.

- For more on GUI troubleshooting, head over to the [GUI Troublshooting Doc](https://docs.openbci.com/Troubleshooting/GUI_Troubleshooting/).

## Diagram

Here is a Work-in-progress diagram outlining the most important parts of the GUI. Created using https://app.diagrams.net/.

<p align="center">
  <img alt="banner" src="OpenBCI%20GUI%20Diagram.drawio.png" width="600">
</p>

## <a name="license"></a> License:

MIT

## Links

- [OpenBCI Main Site](https://www.openbci.com)
- [Ganglion Board](https://shop.openbci.com/collections/frontpage/products/pre-order-ganglion-board)
- [Cyton Board](https://shop.openbci.com/collections/frontpage/products/cyton-biosensing-board-8-channel)
- [Cyton+Daisy Boards](https://shop.openbci.com/collections/frontpage/products/cyton-daisy-biosensing-boards-16-channel)
- [GUI Widget Tutorial](https://docs.openbci.com/Software/OpenBCISoftware/GUIWidgets/#custom-widget)
- [Run GUI from Processing IDE](https://docs.openbci.com/Software/OpenBCISoftware/GUIDocs/#running-the-openbci-gui-from-the-processing-ide)
