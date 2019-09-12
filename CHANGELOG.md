# v4.1.6
Use OpenBCIHub v2.0.9 please.

## Beta 0

### Bug Fixes
* Cyton+WiFi unable to start session #555

# v4.1.5
Use OpenBCIHub v2.0.9 please.

## Beta 4
### Improvements
* Minor UI/UX edits for style and clarity
* Update Cyton SD card duration select from MenuList to ScrollableList
* Update UI/UX in SSVEP widget

## Beta 3

### Bug fixes
* Update links to OpenBCI Forum and new Docs at GitHub Pages

## Beta 2

### Bug fixes
* Only delete settings files if they are old/broken

## Beta 1

### Bug fixes
* Fix 'Open Log as Text' feature in ConsoleLog
* Delete old/broken user and default settings when attempting to load

### Improvements

#### SSVEP
* Place this widget in BETA mode w/ description in widget help text

#### Networking Widget
* Implement FFT over LSL
* Auto-switch to Band Power instead of FFT for Serial output
* Add link to networking output guide for all data types

## Beta 0

### Improvements
* Update Radio Config tools and UI to be more user-friendly
* Establish minimum GUI app size of 705x400

### Bug fixes
* Add reusable ChannelSelect class to Widget.pde #573
* Allow up to 20 seconds for GUI to connect to Hub #531

# v4.1.4

## Beta 0

### Improvements
* Added SSVEP widget! (Thanks @leanneapichay)
* Update/restructure settings for TimeSeries and Networking
* Update Cyton RadioConfig in Control Panel to be more user friendly
* Scale widget selector dropdown based on widget height to allow for more widgets

###  Bug fixes
* Close network streams when session is ended or app is closed
* Networking settings not being saved/loaded properly
* Update Ganglion Impedance button text when successfully stopped
* Check Hub connect on app start using TimerTask #531
* Calculate playback mode time using last column for backwards compatibility #546

# v4.1.3
Use OpenBCIHub v2.0.9 please.

## Beta 3

###  Bug fixes
* Fix app crash when streaming 16ch over LSL #557

## Beta 2

### Improvements
* Update Serial EMG output in Networking Widget
* Add Accelerometer and Aux Data output to Networking Widget #532
* Rename "Start/Stop System" button to "Start/Stop Session"
* Add absolute timestamp to LSL stream for all data types #530
* Update OpenBCI Data Format using Sessions #483
* Add dropdown to limit recording duration for OpenBCI Data Format #461
* Show intro animation on launch instead of grey screen

### Bug Fixes
* Clear Playback History dropdown when settings are cleared #521
* Accelerometer Widget values display correct data
* Fix NullPointerExceptions caused by Data Log updates #548


## Beta 1

### Bug Fixes
* Fix BLED112 Impedance check in HUB by allowing 2 seconds for command/success

## Beta 0

### Bug Fixes
* GUI now produces valid BDF files Fixes #441
* Relocate User data to Documents folder on all OS #535

# v4.1.2
Use OpenBCIHub v2.0.8 please.

## Beta 2

### Improvements
* Add additional button hover text
* Console log message cleanup

### Bug Fixes
* Fix #418, #493, #506, #422, and #509

## Beta 1

### Improvements
* Shorten file names in playback history when needed
* New coloring for Band Power widget
* Smooth and filter dropdowns added to Band Power
* Improved axis labels on Band Power widget
* Cleaned up some console output
* On windows, properly scale for High DPI displays

### Bug Fixes
* Fix crash when opening the console window
* Fix crash when selecting a playback file from the playback widget
* Fix crash when loading old settings file
* Fix buttons being clicked under dropdowns

## Beta 0

### New Features
* Expert mode button to toggle advanced keyboard shortcuts
* Clear GUI settings button w/ confirmation

### Improvements
* New icon for "back to start" button in Playback mode
* Playback History widget functionality and appearance
* Optimized playback history
* Adjust Networking Widget appearance and scaling
* Explicitly warn users when the HUB is not running

### Bug Fixes
* Fixed: Ganglion accelerometer starts "on" but data not streaming
* Fixed: LSL streaming in standalone GUI

# v4.1.1
Use OpenBCIHub v2.0.7 please.

## Beta 0

### New Features
* Added Console Log window in the GUI, so users can diagnose and report issues

### Bug Fixes
* Time in status line is not updated every seconds #443
* Playback Mode: Playback slider and start data stream clears graphs #438
* Load correct default settings for FFT X and Y axis

# v4.1.0

Use OpenBCIHub v2.0.6 please.

## Beta 1

### Bug Fixes
* Cyton impedance check did not work for Ch16 #427

## Beta 0

### New Features
* Sync Time Series and Accelerometer functionality and appearance #410
* Option to sync time window in Accelerometer and Analog Read #410
* Choose recent playback files from a dropdown in the Control Panel

### Bug Fixes
* Add GUI version info to Update button help text #407
* Fix Time Series graph display issue #247
* Align Ganglion accelerometer data to match Cyton #398
* Fixed the GUI freezing on launch with a grey screen #409 #406 #426

# v4.0.4

Use OpenBCIHub v2.0.5 please.

### Bug Fix

* Cyton impedance check did not work #427

# v4.0.3

Use OpenBCIHub v2.0.3 please.

### New Features

* On Windows, it is no longer necessary to launch the HUB separately.
* The HUB is packaged within the GUI on Windows, just like on Mac and Linux.

### Bug Fixes

* Ganglion did not work for Mojave #402
* Ganglion could not do playback file #399

## Beta 1

### Bug Fixes

* Fixed bug where cyton (and cyton daisy) did not work for auxData #414
* Fixed bug where GUI does not start hub on Windows #300

## Beta 0

* Initial Release

# v4.0.2

Use OpenBCIHub v2.0.2 please.

### New Features

* Timestamps in CSV now come from the OpenBCIHub
* Playback widget with recent file history
* Update GUI button and version check

### Breaking Changes

* Now sending and receiving from the hub in JSON!

# v4.0.0

Use OpenBCIHub v2.0.0 please.

### New Features

* Timestamps in CSV now come from the OpenBCIHub
* Playback widget with recent file history
* Update GUI button and version check

### Breaking Changes

* Now sending and receiving from the hub in JSON!

## Alpha 2

### New features

* Add number of channels to output of odf files.

### Bug fixes

* Ganglion did not work
* Ganglion accel did not work
* Ganglion over bled112 did not work
* Added playback widget to address #48 #55
* Added button to check version and update GUI

## Alpha 1

* Initial Release with an error

## Alpha 0

* Initial Release

# v3.4.0

Use OpenBCIHub v1.4.5 please.

### New Features

* Save/Load your favorite GUI settings via dropdown menu or keyboard shortcut (thanks @retiutut)
* Auto-Load settings when system starts
* Auto-Save settings when system stops
* Default settings option added to Settings dropdown
* Pulse streaming added to Networking
* Added fourth stream to OSC mode
* Added plist file to add settings for information when app is built (thanks @retiutut)
* Added playback scrollbar sub-widget
* Add BLED112 support for windows and linux

## Beta 1

### Improvements

* Added playback scrollbar sub-widget #38

### Bug Fixes

* Ganglion-accelerometer behavior when loading
* Catch error when using outdated playback files #348

## Beta 0

### Improvements

* Save/Load default and user settings for all data modes independently

### Bug Fixes
* Fixed Ganglion-GUI experience on startup when loading settings
* Error catch: allow ~ 4 seconds to apply channel settings to Cyton when loading

## Alpha 2

### Improvements

* Fixed issue where convert from SD card could cause crash #351
* Fixed issue with accel and playback file.
* Fix activate/deactivate channels for Ganglion when loading settings
* Further cleanup of error messages on system start
* Make Channel On/Off buttons more readable with white text #361
* Remove a bunch of outputs

### Bug Fixes

* Fixed bug where app crashed on Ganglion load

## Alpha 1

### Improvements

* Moved the JSON user settings to SavedData
* Added Info.plist
* Add BLED112 support for windows and linux

### Bug Fixes

* Fixed bug where app crashed on Ganglion load

### Known Issues

* Ganglion channels stay activated after load from settings.

## Alpha 0

Initial Release

# v3.3.2

Use OpenBCIHub v1.4.4 please.

### Bug Fixes

* Fixed bug where ganglion accel did not work

# v3.3.1

Use OpenBCIHub v1.4.2 please.

### Bug Fixes

* Fixed bug where SD files were called csv
* Fixed bug where SD files could not be played back in gui
* Fixed bug where SD files could freeze the GUI
* Fixed bug where GUI crashed on windows and linux (thanks @chrisjz) #331
* Added a bunch of checking to avoid exception errors when not running as mac to prevent BLED112
* Fixed a bug where the GUI did not work with processing 3.3.7 #316

## Beta 1

Initial release with bug fixes!

# v3.3.0

Use OpenBCIHub v1.4.2 please.

### New Features

* Add support for BLED112
* Add support for static IP for wifi

## Beta 5

* Fixes a bunch of spacing and layout issues found when switching between the different interfaces

## Beta 4

* There was a problem with the release

## Beta 3

* Add support for static IP for wifi
* Bump Hub to v1.4.2

## Beta 2

* Fix bug with Hub, bump hub to v1.4.1

## Beta 1

* Initial release

# v3.2.0

Use OpenBCIHub v1.3.9 please.

### New Features

* Add the Digital Read widget
* Add the Analog Read widget
* Add the Marker Mode widget
* Add info, warn, success, and error types to output function to alert user in help widget.

### Bug Fixes

* Did not write aux values for Cyton with Daisy #272
* Did not write to the SD card #277
* Add button to accelerometer widget to turn accel mode on if the user was just using digital, analog, or marker mode.
* Fixes #192 with drop down of different color themes.
* Fixes #285 by moving the wifi options to the right of the drop down pane.
* Fixes #270 where macOS 10.13 could not connect to Ganglion
* Fixes #247 where the timer series graph looked strange with 7 seconds.

## rc2

### Bug Fixes

* Added stability for ganglion bluetooth #270

## rc1

* Update the hub to 1.3.7 to catch more wifi errors
* Finished the udp/tcp
* Add colors to help widget.

## Beta 3

Finished Analog and Digital read widgets.

## Beta 2

Initial release

# v3.1.0

Use hub v1.3.4 please.

### New Features

* Added new files for Contributing, code of conduct and roadmap
* Refactored readme with banner image, and all in all made it sweet.
* Added 500Hz sample rate option for WiFi Shield Cyton

### Breaking Changes

* SD Converted file goes into `data/SavedData` instead of `data/EED_Data`. #267
* Sending data over UDP produced unreadable raw format. Switched to JSON output.
* All UDP output sends a serialized json packet ending with `\r\n`
* Data files are now saved with `.csv` instead of `.txt`

### Bug Fixes

* "Data stream stopped" would be shown to users even if no data stream was stopped #263
* Accel did not work for wifi Daisy #265
* Users would have to close the GUI before restarting after cyton or ganglion session #262
* Design your own widget link #261

## Beta 2

Implement overhaul of GUI docs.

### Bug Fixes

* #261 #267

## Beta 1

Initial release.

# v3.0.1

### Bug Fixes

* FIX: #254 LSL, UDP, OSC ArrayIndexOutOfBoundsException Stream with 4 or 16 channels

# v3.0.0

v3.0.0 set out to move **all** of the data collection to the electron hub. This means moving serial port parsing as well.

### New Features

* Able to use wifi shield with GUI. Streams in at 1000Hz for Cyton and 1600Hz for Ganglion.

### Breaking Changes

* Dependent on electron hub for all data streaming activity.

## Release Candidate 5

Uses OpenBCIHub v1.3.0

### Bug Fixes

* Closes: #191

## Release Candidate 4

Uses OpenBCIHub v1.2.0

### Bug Fixes

* Closes: #208 - ganglion not using correct scale factor when on wifi high resolution mode
* Fixes bug where gui started in 45 fps frame rate

## Release Candidate 2/3

### Bug Fixes

* Critical windows hub patches

## Release Candidate 1

Initial RC

## Beta 6

* Closes #202 #205 #207

## Beta 4

* Closes #203

## Beta 2-3

Required a lot of work on the hub. But none the less, this seems to be working decently.

### Bug Fixes

* Closes #196 #195 #194 #193 #190 #188 #187 #186 #189

## Beta 1

The first beta to be released. There are some [minor issues](https://github.com/OpenBCI/OpenBCI_GUI/issues), but if any are encountered, please [open an issue](https://github.com/OpenBCI/OpenBCI_GUI/issues/new) on the [github page](https://github.com/OpenBCI/OpenBCI_GUI/issues).

# 2.2.1

### Bug Fixes
* Addresses #121 - `.edf` incompatible changed ending to `.bdf`
* Closes #148 - LSL does not stream correctly

# 2.2.0

### Bug Fixes
* Fix #151 - Incorrect number of channels on playback caused index out of bounds errors.
* Addresses #149 - Allows for proper scaling of channels with four thanks to #151 #157

### New Features
* Band power widget #153 (thanks @sunwangshu)
* Closes #138 - Able to drag and drop the electrodes on the head map  (thanks @liqwid)
* Closes #142 - GUI needs to pass key strokes to Ganglion

# 2.1.2

### Bug Fixes
* Fix #120 - Locale dependent formatting cause issue with output ODF file.

# 2.1.1

### Bug Fixes
* Fix #111 - No compatible USB now shows error in output, not an annoying popup.

# 2.1.0

### Breaking Changes
* Removed space in GanglionHub to be able to kill the hub on windows.

### Bug Fixes
* Issue #111 where Windows users saw error message from Ganglion Hub on start up if no hub selected.

# 2.0.0

* Initial Release
