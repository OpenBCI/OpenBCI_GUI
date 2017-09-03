# 3.0.0

v3.0.0 set out to move **all** of the data collection to the electron hub. This means moving serial port parsing as well.

### New Features

* Able to use wifi shield with GUI. Streams in at 1000Hz for Cyton and 1600Hz for Ganglion.

### Breaking Changes

* Dependent on electron hub for all data streaming activity.

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
