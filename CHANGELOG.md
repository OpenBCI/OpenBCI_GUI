# 3.0.0

### Breaking Changes

* Dependent on electron hub for all data streaming activity.

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
