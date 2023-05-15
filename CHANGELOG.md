# v5.1.1

### Bug Fixes
- Fix NullPointerException when no Audio Device is available from the OS (Windows and Linux) #1109 #1086
- Fix LSL AvgBandPower data type only one value is sent #1098
- Fix error starting BrainFlow Streaming Board from external process #1102
- Fix Hardware Settings button not clickable after resizing app #1132

### Improvements
- Update to BrainFlow 5.6.1
- Add feature to connect to Ganglion using Native Bluetooth #1080
- Refactor the creation and playback of OpenBCI GUI CSV files #1119


# v5.1.0

### Bug Fixes

- Stop data stream when no data received after 5 seconds #1011
- Revisit Ganglion Impedance widget so it behaves like new Cyton Impedance Widget #1021
- Fix dropdown backgrounds in Networking Widget
- Update priveleges for Windows users and check if GUI has been run as Administrator
- Fix High DPI scaling on some Macs with Retina Display

### Improvements

- Add new FilterUI to allow custom filters per channel #988
- Add BrainFlow Streamer for File and Network to Control Panel #1007
- Update to BrainFlow v4.9.0+ and print version to console log #1028
- Update OpenBCI Logo #1010
- Clarify Cyton Smoothing feature #1027
- Set Cyton Smoothing on by default and increase communication with a popup and additional Help button #1026
- Update help text for various buttons across the GUI to help new and existing users
- Update Band Power widget and add Average Band Power data type to Networking Widget
- Update ControlP5 Library to 2.3.3 and change ScrollableList behavior to be more consistent with other front-end libraries
- Remove old multi-line filter buttons in TopNav that draw incorrectly on some PCs #1013
- Minor UI/UX improvements to Spectrogram widget to increase clarity for all users
- Add slower options for FFT data smoothing
- Fix certain Textfield and TextArea fonts not drawing correctly on some Macs
- Update and enforce style guide throughout the GUI in preparation for multiple themes
- Improve UI/UX for HelpWidget at the bottom of the GUI to make it more noticeable
- Print OS Name and Version to Console Log on app start

# v5.0.9

### Bug Fixes

- Change TimeSeries y-axis textfields to labels to increase performance and fix font on some Macs

### Improvements

- For Cyton, only allow checking impedance on one channel at a time #983
- Make new Cyton Signal Check Widget #983

# v5.0.8

### Bug Fixes

- Hot Fix NullPointer error related to missing folder and GUI-wide settings file #1003 #1004

# v5.0.7

### Improvements

- Show info in footer when a new version of the GUI is available #992
- Further improvements to GUI Update Button logic
- Add GUI-wide settings class to keep certain settings across sessions and app starts #997
- Remove 30 second window option from Focus widget

### Bug Fixes

- Fix GUI not running on some Macs due to high-dpi screen code #987 #990 #1001
- Fix streaming multiple data types over LSL #971

# v5.0.6

### Improvements

- Add Auditory Feedback to the Focus Widget Fixes #709

### Bug Fixes

- Fix drawing error in Control Panel WiFi Shield static IP Textfield
- Accomodate high-dpi screens Fixes #968
- Add Arduino Focus Fan example to networking test kit on GitHub repo
- Allow synthetic square wave expert mode keyboard shortcut for Cyton and Ganglion Fixes #976

# v5.0.5

### Improvements

- Implement Focus Widget using BrainFlow Metrics! #924
- Throw a popup if users are are running an old version of Windows operating system. GUI v5 supports 64-bit Windows 8, 8.1, and 10. #964
- Throw a popup if Windows users are using 32-bit Java and Processing. #964
- Set Networking Widget default baud rate for Serial output to 57600

### Bug Fixes

- Fix Y axis Autoscale in TimeSeries when all values are less than zero. Example: Cyton with filters off
- Gracefully handle cases when Cyton or Cyton+Daisy users want to use 8 or 16 channels #954
- Update Save Session Settings success message. Session settings are no longer auto-loaded on Session start. #969
- Session settings are no longer auto-saved when system is halted #969

# v5.0.4

### Improvements

- Add Copy/Paste for all textfields on all OS #940
- Update BrainFlow library to version that includes a marker channel
- Handle paths with spaces on Linux Standalone GUI #916
- Allow Expert Ganglion Users to send square wave commands via keyboard #950
- Show Send Custom Hardware Command UI for Cyton Expert Mode in Hardware Settings
- Improve Hardware Setting UX/UI for ADS1299 boards #954

### Bug Fixes

- Clean up GUI code to fix Processing/JVM memory issue causing crash #955
- Avoid playback history file not found exception #959
- Fix issue with Spectrogram Widget data image default height
- Fix issue with Accelerometer Widget graph default vertical scale
- Fix text drawing in wrong spot in Session Data box in Control Panel

# v5.0.3

### Improvements

- Increase sampling rate for Pulse data output in Networking Widget

### Bug Fixes

- Fix Pulse LSL output error #943
- Fix Accel/Aux UDP output #944
- Fix Expert Mode unplanned keyboard shortcuts crash GUI #941
- Fix bugs found when loading Session Settings #942

# v5.0.2

### Improvements

- Improved Cyton Auto-Connect button w/ Auto-Scan
- Update Hardware Settings UI for ADS1299 boards
- Highlight channels in Hardware Settings that are out of sync with board
- Require users to send or revert Hardware Settings before closing UI
- Add "Send" button to Hardware Settings
- Update SessionData UI in Control Panel
- Update ChannelSelect Feature in Widget Class to show what channels are on or off
- Improve Time Series y-axis autoscale performance
- Add channel select feature to FFT widget
- Remove configurable gain behaviour and default to dynamic gain scaler

### Bug Fixes

- Exit session init when current board fails to initialize
- Fix drawing error on lower resolution screens #900
- Save BDF start time in 24hr format instead of 12hr #904
- Fix TimeSeries Unfiltered Networking Output #891 #889
- Fix TimeSeries Networking Output when using Playback Mode w/ GUI or SD file #906
- Let users know when Cyton Auto-Scan is happening with an overlay
- Refactor GUI Buttons and ButtonHelpText

# v5.0.1

### Improvements

- Add ability to save and load hardware settings
- Add configurable gain behaviour
- Add custom vertical scale UI to Time Series

### Bug Fixes

- Fix #805
- Covert GUI v4 sample data to GUI v5 format #830
- Display GUI version in title bar, along with FPS

### Bug Fixes

- Check internet connection to Github using a timeout, so the app doesn't stall

# v5.0.0

### Improvements

- Use BrainFlow Java Binding to handle data acquisition (no need to run the Hub!)
- Speed up entire GUI by plotting data more efficiently
- Updated OpenBCI Data Format (CSV) Files, with more detailed information and data
- Popup with link to GUI v4 file coverter script
- Improved Playback Mode and Time Series
- Refactored GUI data flow
- Add Travis and Appveyor CI tests and builds for all OS
- Add data smoothing option for live Cyton data
- Cyton Port manual selection only displays serial ports with a dongle connected.
- Cyton SD file read works without conversion to playback file
- Add BrainFlow Streaming Board as Data Source option
- Use BrainFlow filters, add 1-100 BandPass filter
- Can Hide/Show channels in time series

### Bug Fixes

- Remove OpenBCI Hub #665 #669 #708
- General UI/UX improvements
- Missing Filter Button Label in Networking #696
- Ganglion+WiFi Accelerometer Data not in Sync #512
- Remove # Chan Textfield from LSL in Networking Widget #644
- LSL manual timestamping interferes with LSL clock_offset correction #775
- Fixed a graphics related error on linux #816

### Deprecated Features

- OpenBCI Hub - This is no longer required to run the GUI!
- Old OBCI (CSV) Files - A converter will be made available
- Presentation Mode
- SSVEP_Beta Widget
- Focus Widget
- Marker Mode Widget
- OpenBionics Widget

# v4.2.0

Please use OpenBCIHub v2.1.0 and Processing 4.

### Improvements

- Update to Processing 4 and Java 11! #671
- Add functional Spectrogram Widget! #416
- Clean up Marker Mode UDP listener #305
- Display "Starting Session" overlay when Start Session button is clicked #628

# v4.1.7

Use OpenBCIHub v2.1.0 please.

## Beta 3

### Bug Fixes

- Update graphica library so GUI sessions load faster on Mac #630
- Catch Invalid Playback File Exception #649

### Improvements

- Add LSL FFT example Python script

## Beta 2

### Improvements

- Add prominent time display for all data modes #635
- Add button for Networking Data Ouputs Guide #643
- Add button to open Sample Data file directory #645

### Bug Fixes

- BandPower: Activate all channels by default #634
- Fix streaming 16ch Filtered TimeSeries w/ high sample rate #638 Ty @Joe-Westra
- Cp5 error in networking stops session init #642 #637 #622
- Check internet connection on app start to avoid GUI crashing #555

## Beta 0

### Improvements

- Dropped Packet Interpolation!
- Make UDPx3 default Transfer protocol Cyton+Wifi

### Bug Fixes

- Playback mode update and bug fixes #633
- Update channelSelect in BandPower and SSVEP widgets when new playback file is loaded

# v4.1.6

Use OpenBCIHub v2.1.0 please.

### Improvements

- Fix LSL streaming more than one data type #592

## Beta 0

### Improvements

- Cyton+Dongle Auto-Connect Button!
- GUI error message when using old Cyton firmware #597
- Update Focus widget help button
- Console Log window UI/UX update
- Add GUI Troubleshooting Guide button to "Help" dropdown in TopNav.pde

### Bug Fixes

- Cyton+WiFi unable to start session #555 #590
- Networking: Start/Stop stream button behavior #593
- Networking: Only show Pulse datatype for Cyton(Live)
- Show error when loading empty playback file and delete file from history

# v4.1.5

Use OpenBCIHub v2.0.9 please.

## Beta 4

### Improvements

- Minor UI/UX edits for style and clarity
- Update Cyton SD card duration select from MenuList to ScrollableList
- Update UI/UX in SSVEP widget

## Beta 3

### Bug fixes

- Update links to OpenBCI Forum and new Docs at GitHub Pages

## Beta 2

### Bug fixes

- Only delete settings files if they are old/broken

## Beta 1

### Bug fixes

- Fix 'Open Log as Text' feature in ConsoleLog
- Delete old/broken user and default settings when attempting to load

### Improvements

#### SSVEP

- Place this widget in BETA mode w/ description in widget help text

#### Networking Widget

- Implement FFT over LSL
- Auto-switch to Band Power instead of FFT for Serial output
- Add link to networking output guide for all data types

## Beta 0

### Improvements

- Update Radio Config tools and UI to be more user-friendly
- Establish minimum GUI app size of 705x400

### Bug fixes

- Add reusable ChannelSelect class to Widget.pde #573
- Allow up to 20 seconds for GUI to connect to Hub #531

# v4.1.4

## Beta 0

### Improvements

- Added SSVEP widget! (Thanks @leanneapichay)
- Update/restructure settings for TimeSeries and Networking
- Update Cyton RadioConfig in Control Panel to be more user friendly
- Scale widget selector dropdown based on widget height to allow for more widgets

### Bug fixes

- Close network streams when session is ended or app is closed
- Networking settings not being saved/loaded properly
- Update Ganglion Impedance button text when successfully stopped
- Check Hub connect on app start using TimerTask #531
- Calculate playback mode time using last column for backwards compatibility #546

# v4.1.3

Use OpenBCIHub v2.0.9 please.

## Beta 3

### Bug fixes

- Fix app crash when streaming 16ch over LSL #557

## Beta 2

### Improvements

- Update Serial EMG output in Networking Widget
- Add Accelerometer and Aux Data output to Networking Widget #532
- Rename "Start/Stop System" button to "Start/Stop Session"
- Add absolute timestamp to LSL stream for all data types #530
- Update OpenBCI Data Format using Sessions #483
- Add dropdown to limit recording duration for OpenBCI Data Format #461
- Show intro animation on launch instead of grey screen

### Bug Fixes

- Clear Playback History dropdown when settings are cleared #521
- Accelerometer Widget values display correct data
- Fix NullPointerExceptions caused by Data Log updates #548

## Beta 1

### Bug Fixes

- Fix BLED112 Impedance check in HUB by allowing 2 seconds for command/success

## Beta 0

### Bug Fixes

- GUI now produces valid BDF files Fixes #441
- Relocate User data to Documents folder on all OS #535

# v4.1.2

Use OpenBCIHub v2.0.8 please.

## Beta 2

### Improvements

- Add additional button hover text
- Console log message cleanup

### Bug Fixes

- Fix #418, #493, #506, #422, and #509

## Beta 1

### Improvements

- Shorten file names in playback history when needed
- New coloring for Band Power widget
- Smooth and filter dropdowns added to Band Power
- Improved axis labels on Band Power widget
- Cleaned up some console output
- On windows, properly scale for High DPI displays

### Bug Fixes

- Fix crash when opening the console window
- Fix crash when selecting a playback file from the playback widget
- Fix crash when loading old settings file
- Fix buttons being clicked under dropdowns

## Beta 0

### New Features

- Expert mode button to toggle advanced keyboard shortcuts
- Clear GUI settings button w/ confirmation

### Improvements

- New icon for "back to start" button in Playback mode
- Playback History widget functionality and appearance
- Optimized playback history
- Adjust Networking Widget appearance and scaling
- Explicitly warn users when the HUB is not running

### Bug Fixes

- Fixed: Ganglion accelerometer starts "on" but data not streaming
- Fixed: LSL streaming in standalone GUI

# v4.1.1

Use OpenBCIHub v2.0.7 please.

## Beta 0

### New Features

- Added Console Log window in the GUI, so users can diagnose and report issues

### Bug Fixes

- Time in status line is not updated every seconds #443
- Playback Mode: Playback slider and start data stream clears graphs #438
- Load correct default settings for FFT X and Y axis

# v4.1.0

Use OpenBCIHub v2.0.6 please.

## Beta 1

### Bug Fixes

- Cyton impedance check did not work for Ch16 #427

## Beta 0

### New Features

- Sync Time Series and Accelerometer functionality and appearance #410
- Option to sync time window in Accelerometer and Analog Read #410
- Choose recent playback files from a dropdown in the Control Panel

### Bug Fixes

- Add GUI version info to Update button help text #407
- Fix Time Series graph display issue #247
- Align Ganglion accelerometer data to match Cyton #398
- Fixed the GUI freezing on launch with a grey screen #409 #406 #426

# v4.0.4

Use OpenBCIHub v2.0.5 please.

### Bug Fix

- Cyton impedance check did not work #427

# v4.0.3

Use OpenBCIHub v2.0.3 please.

### New Features

- On Windows, it is no longer necessary to launch the HUB separately.
- The HUB is packaged within the GUI on Windows, just like on Mac and Linux.

### Bug Fixes

- Ganglion did not work for Mojave #402
- Ganglion could not do playback file #399

## Beta 1

### Bug Fixes

- Fixed bug where cyton (and cyton daisy) did not work for auxData #414
- Fixed bug where GUI does not start hub on Windows #300

## Beta 0

- Initial Release

# v4.0.2

Use OpenBCIHub v2.0.2 please.

### New Features

- Timestamps in CSV now come from the OpenBCIHub
- Playback widget with recent file history
- Update GUI button and version check

### Breaking Changes

- Now sending and receiving from the hub in JSON!

# v4.0.0

Use OpenBCIHub v2.0.0 please.

### New Features

- Timestamps in CSV now come from the OpenBCIHub
- Playback widget with recent file history
- Update GUI button and version check

### Breaking Changes

- Now sending and receiving from the hub in JSON!

## Alpha 2

### New features

- Add number of channels to output of odf files.

### Bug fixes

- Ganglion did not work
- Ganglion accel did not work
- Ganglion over bled112 did not work
- Added playback widget to address #48 #55
- Added button to check version and update GUI

## Alpha 1

- Initial Release with an error

## Alpha 0

- Initial Release

# v3.4.0

Use OpenBCIHub v1.4.5 please.

### New Features

- Save/Load your favorite GUI settings via dropdown menu or keyboard shortcut (thanks @retiutut)
- Auto-Load settings when system starts
- Auto-Save settings when system stops
- Default settings option added to Settings dropdown
- Pulse streaming added to Networking
- Added fourth stream to OSC mode
- Added plist file to add settings for information when app is built (thanks @retiutut)
- Added playback scrollbar sub-widget
- Add BLED112 support for windows and linux

## Beta 1

### Improvements

- Added playback scrollbar sub-widget #38

### Bug Fixes

- Ganglion-accelerometer behavior when loading
- Catch error when using outdated playback files #348

## Beta 0

### Improvements

- Save/Load default and user settings for all data modes independently

### Bug Fixes

- Fixed Ganglion-GUI experience on startup when loading settings
- Error catch: allow ~ 4 seconds to apply channel settings to Cyton when loading

## Alpha 2

### Improvements

- Fixed issue where convert from SD card could cause crash #351
- Fixed issue with accel and playback file.
- Fix activate/deactivate channels for Ganglion when loading settings
- Further cleanup of error messages on system start
- Make Channel On/Off buttons more readable with white text #361
- Remove a bunch of outputs

### Bug Fixes

- Fixed bug where app crashed on Ganglion load

## Alpha 1

### Improvements

- Moved the JSON user settings to SavedData
- Added Info.plist
- Add BLED112 support for windows and linux

### Bug Fixes

- Fixed bug where app crashed on Ganglion load

### Known Issues

- Ganglion channels stay activated after load from settings.

## Alpha 0

Initial Release

# v3.3.2

Use OpenBCIHub v1.4.4 please.

### Bug Fixes

- Fixed bug where ganglion accel did not work

# v3.3.1

Use OpenBCIHub v1.4.2 please.

### Bug Fixes

- Fixed bug where SD files were called csv
- Fixed bug where SD files could not be played back in gui
- Fixed bug where SD files could freeze the GUI
- Fixed bug where GUI crashed on windows and linux (thanks @chrisjz) #331
- Added a bunch of checking to avoid exception errors when not running as mac to prevent BLED112
- Fixed a bug where the GUI did not work with processing 3.3.7 #316

## Beta 1

Initial release with bug fixes!

# v3.3.0

Use OpenBCIHub v1.4.2 please.

### New Features

- Add support for BLED112
- Add support for static IP for wifi

## Beta 5

- Fixes a bunch of spacing and layout issues found when switching between the different interfaces

## Beta 4

- There was a problem with the release

## Beta 3

- Add support for static IP for wifi
- Bump Hub to v1.4.2

## Beta 2

- Fix bug with Hub, bump hub to v1.4.1

## Beta 1

- Initial release

# v3.2.0

Use OpenBCIHub v1.3.9 please.

### New Features

- Add the Digital Read widget
- Add the Analog Read widget
- Add the Marker Mode widget
- Add info, warn, success, and error types to output function to alert user in help widget.

### Bug Fixes

- Did not write aux values for Cyton with Daisy #272
- Did not write to the SD card #277
- Add button to accelerometer widget to turn accel mode on if the user was just using digital, analog, or marker mode.
- Fixes #192 with drop down of different color themes.
- Fixes #285 by moving the wifi options to the right of the drop down pane.
- Fixes #270 where macOS 10.13 could not connect to Ganglion
- Fixes #247 where the timer series graph looked strange with 7 seconds.

## rc2

### Bug Fixes

- Added stability for ganglion bluetooth #270

## rc1

- Update the hub to 1.3.7 to catch more wifi errors
- Finished the udp/tcp
- Add colors to help widget.

## Beta 3

Finished Analog and Digital read widgets.

## Beta 2

Initial release

# v3.1.0

Use hub v1.3.4 please.

### New Features

- Added new files for Contributing, code of conduct and roadmap
- Refactored readme with banner image, and all in all made it sweet.
- Added 500Hz sample rate option for WiFi Shield Cyton

### Breaking Changes

- SD Converted file goes into `data/SavedData` instead of `data/EED_Data`. #267
- Sending data over UDP produced unreadable raw format. Switched to JSON output.
- All UDP output sends a serialized json packet ending with `\r\n`
- Data files are now saved with `.csv` instead of `.txt`

### Bug Fixes

- "Data stream stopped" would be shown to users even if no data stream was stopped #263
- Accel did not work for wifi Daisy #265
- Users would have to close the GUI before restarting after cyton or ganglion session #262
- Design your own widget link #261

## Beta 2

Implement overhaul of GUI docs.

### Bug Fixes

- #261 #267

## Beta 1

Initial release.

# v3.0.1

### Bug Fixes

- FIX: #254 LSL, UDP, OSC ArrayIndexOutOfBoundsException Stream with 4 or 16 channels

# v3.0.0

v3.0.0 set out to move **all** of the data collection to the electron hub. This means moving serial port parsing as well.

### New Features

- Able to use wifi shield with GUI. Streams in at 1000Hz for Cyton and 1600Hz for Ganglion.

### Breaking Changes

- Dependent on electron hub for all data streaming activity.

## Release Candidate 5

Uses OpenBCIHub v1.3.0

### Bug Fixes

- Closes: #191

## Release Candidate 4

Uses OpenBCIHub v1.2.0

### Bug Fixes

- Closes: #208 - ganglion not using correct scale factor when on wifi high resolution mode
- Fixes bug where gui started in 45 fps frame rate

## Release Candidate 2/3

### Bug Fixes

- Critical windows hub patches

## Release Candidate 1

Initial RC

## Beta 6

- Closes #202 #205 #207

## Beta 4

- Closes #203

## Beta 2-3

Required a lot of work on the hub. But none the less, this seems to be working decently.

### Bug Fixes

- Closes #196 #195 #194 #193 #190 #188 #187 #186 #189

## Beta 1

The first beta to be released. There are some [minor issues](https://github.com/OpenBCI/OpenBCI_GUI/issues), but if any are encountered, please [open an issue](https://github.com/OpenBCI/OpenBCI_GUI/issues/new) on the [github page](https://github.com/OpenBCI/OpenBCI_GUI/issues).

# 2.2.1

### Bug Fixes

- Addresses #121 - `.edf` incompatible changed ending to `.bdf`
- Closes #148 - LSL does not stream correctly

# 2.2.0

### Bug Fixes

- Fix #151 - Incorrect number of channels on playback caused index out of bounds errors.
- Addresses #149 - Allows for proper scaling of channels with four thanks to #151 #157

### New Features

- Band power widget #153 (thanks @sunwangshu)
- Closes #138 - Able to drag and drop the electrodes on the head map (thanks @liqwid)
- Closes #142 - GUI needs to pass key strokes to Ganglion

# 2.1.2

### Bug Fixes

- Fix #120 - Locale dependent formatting cause issue with output ODF file.

# 2.1.1

### Bug Fixes

- Fix #111 - No compatible USB now shows error in output, not an annoying popup.

# 2.1.0

### Breaking Changes

- Removed space in GanglionHub to be able to kill the hub on windows.

### Bug Fixes

- Issue #111 where Windows users saw error message from Ganglion Hub on start up if no hub selected.

# 2.0.0

- Initial Release
