# The OpenBCI GUI

<p align="center">
  <img alt="banner" src="/images/GUI-V2-SCREENSHOT.JPG/" width="600">
</p>
<p align="center" href="">
  Provide a stable and powerful interface for any OpenBCI device
</p>

[![Stories in Ready](https://badge.waffle.io/OpenBCI/OpenBCI_GUI_v2.0.svg?label=ready&title=Ready)](http://waffle.io/OpenBCI/OpenBCI_GUI_v2.0)

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

Mainly, we are OpenBCI. The original code writer was Chip Audette, along with Conor Russomanno and Joel Murphy. Currently AJ Keller is a main contributor to moving the GUI in a more stable direction. Wang Shu, Gabe, Colin and many other contractors/interns have contributed valuable code and widgets!  

## What do we need?

**You**! In whatever way you can help.

We need expertise in programming, user experience, software sustainability, documentation and technical writing and project management.

We'd love your feedback along the way.

Our primary goal is to provide a stable and powerful interface for any OpenBCI device, and we're excited to support the professional development of any and all of our contributors. If you're looking to learn to code, try out working collaboratively, or translate you skills to the digital domain, we're here to help.

## Get involved

If you think you can help in any of the areas listed above (and we bet you can) or in any of the many areas that we haven't yet thought of (and here we're *sure* you can) then please check out our [contributors' guidelines](CONTRIBUTING.md) and our [roadmap](ROADMAP.md).

Please note that it's very important to us that we maintain a positive and supportive environment for everyone who wants to participate. When you join us we ask that you follow our [code of conduct](CODE_OF_CONDUCT.md) in all interactions both on and offline.


## Contact us

If you want to report a problem or suggest an enhancement we'd love for you to [open an issue](../../issues) at this github repository because then we can get right on it. But you can also contact [AJ][link_aj_keller] by email (pushtheworldllc AT gmail DOT com) or on [twitter](https://twitter.com/aj-ptw).

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

## Troubleshooting
If you find your self saying:
_When I run the OpenBCI UI from Processing on my Mac I don’t see the Ganglion_
_But from the OpenBCI App (real one, not from the code), it works._
_I feel like I need to authorize Processing to use Bluetooth… it that makes any sense at all_

Please follow these instructions for getting the **critical** piece of software called the OpenBCI HUB [Mac/Linux](http://docs.openbci.com/OpenBCI%20Software/01-OpenBCI_GUI#the-openbci-gui-running-the-openbci-gui-from-the-processing-ide-install-openbci-hub-on-maclinux) [Windows](http://docs.openbci.com/OpenBCI%20Software/01-OpenBCI_GUI#the-openbci-gui-install-openbci-hub-on-windows). Thanks and happy hacking!

## <a name="license"></a> License:

MIT

[link_aj_keller]: https://github.com/aj-ptw
[link_shop_wifi_shield]: https://shop.openbci.com/collections/frontpage/products/wifi-shield?variant=44534009550
[link_shop_ganglion]: https://shop.openbci.com/collections/frontpage/products/pre-order-ganglion-board
[link_shop_cyton]: https://shop.openbci.com/collections/frontpage/products/cyton-biosensing-board-8-channel
[link_shop_cyton_daisy]: https://shop.openbci.com/collections/frontpage/products/cyton-daisy-biosensing-boards-16-channel
[link_ptw]: https://www.pushtheworldllc.com
[link_openbci]: http://www.openbci.com
[link_gui_widget_tutorial]: http://docs.openbci.com/Tutorials/15-Custom_Widgets
[link_gui_run_from_processing]: http://docs.openbci.com/OpenBCI%20Software/01-OpenBCI_GUI#the-openbci-gui-running-the-openbci-gui-from-the-processing-ide
