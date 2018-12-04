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
