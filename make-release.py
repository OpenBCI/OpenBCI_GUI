#########################################################################################
#
#   Python script for building and packaging a release of the GUI software
#
#   Created: Daniel Lasry, Feb 2019
#
#   This is meant for members of the OpenBCI organization to quickly build new releases:
#   https://github.com/OpenBCI/OpenBCI_GUI/releases

#   Usage: > python make-release.py
#   Written for python 2.7, but could easily be adapted to python 3.
#   No warranty. Use at your own risk. 
#
#########################################################################################

import sys, os, shutil, platform, subprocess

WINDOWS = 'Windows'
MAC = 'Darwin'
LINUX = 'Linux'
LOCAL_OS = platform.system()

build_dir_names = {
    WINDOWS : "application.windows64",
    LINUX : "application.linux64",
    MAC : "application.macosx"
}

data_dir_names = {
    WINDOWS : "data",
    LINUX : "data",
    MAC : os.path.join("OpenBCI_GUI.app", "Contents", "Java", "data")
}

hub_dir_names = {
    WINDOWS : "OpenBCIHub",
    LINUX : "OpenBCIHub",
    MAC : "OpenBCIHub.app"
}

build_dirs = [
    "application.windows32",
    "application.windows64",
    "application.macosx",
    "application.linux32",
    "application.linux64",
    "application.linux-arm64",
    "application.linux-armv6hf"
]

# processing-java requires the cwd to build a release
cwd = os.getcwd()
sketch_dir = os.path.join(cwd, "OpenBCI_GUI")

def cleanup_build_dirs(zips = False):
    print "Cleanup ..."
    for dir in build_dirs:
        full_dir = os.path.join(sketch_dir, dir)
        full_zip_dir = full_dir + ".zip"
        if os.path.isdir(full_dir):
            shutil.rmtree(full_dir)
            print "Successfully deleted " + full_dir
        if zips and os.path.isfile(full_zip_dir):
            os.remove(full_zip_dir)
            print "Successfully deleted " + full_zip_dir

# check that we are in the right directory to build
main_file_dir = os.path.join(sketch_dir, "OpenBCI_GUI.pde")
if not os.path.isfile(main_file_dir):
    sys.exit("ERROR: Could not find sketch file: " + main_file_dir)

# ask user for the hub directory
hub_dir = raw_input("Enter path to the HUB: ")

if LOCAL_OS == WINDOWS:
    # sanity check: does this directory contain the hub executable?
    hub_exe = os.path.join(hub_dir, "OpenBCIHub.exe")
    while not os.path.isfile(hub_exe):
        hub_dir = raw_input("OpenBCIHub.exe not found in this directory, please re-enter: ")
        hub_exe = os.path.join(hub_dir, "OpenBCIHub.exe")
if LOCAL_OS == LINUX:
    # sanity check: does this directory contain the hub executable?
    hub_exe = os.path.join(hub_dir, "OpenBCIHub")
    while not os.path.isfile(hub_exe):
        hub_dir = raw_input("OpenBCIHub executable not found in this directory, please re-enter: ")
        hub_exe = os.path.join(hub_dir, "OpenBCIHub")
elif LOCAL_OS == MAC:
    while not hub_dir.endswith("OpenBCIHub.app"):
        hub_dir = raw_input("Expected a path to OpenBCIHub.app, please re-enter:")

#cleanup before we begin, including zips
cleanup_build_dirs(True)

# unfortunately, processing-java always returns exit code 1,
# so we can't reliably check for success or failure
print "Using sketch: " + sketch_dir
subprocess.call(["processing-java", "--sketch="+sketch_dir, "--export"])

# sanity check: is the build output there?
build_dir = os.path.join(sketch_dir, build_dir_names[LOCAL_OS])
if not os.path.isdir(build_dir):
    sys.exit("ERROR: Could not find build ouput: " + build_dir)

# delete source directory
source_dir = os.path.join(build_dir, "source")
try:
    shutil.rmtree(source_dir)
except OSError as err:
    print err
    print "WARNING: Could not delete source dir: " + source_dir
else:
    print "Successfully deleted source dir."

# sanity check: data directory?
data_dir = os.path.join(build_dir, data_dir_names[LOCAL_OS])
if not os.path.isdir(data_dir):
    sys.exit("ERROR: Could not find data directory: " + data_dir)

# copy Hub to data directory
hub_dest_dir = os.path.join(data_dir, hub_dir_names[LOCAL_OS])
try:
    shutil.copytree(hub_dir, hub_dest_dir, symlinks=True)
except shutil.Error as err:
    print err
    sys.exit("ERROR: Failed to copy the Hub to the data dir.")
else:
    print "Successfully copied Hub to the data dir."

# create SavedData dir
saved_data_dir = os.path.join(build_dir, "SavedData")
try:
    os.mkdir(saved_data_dir)
except OSError:
    print "WARNING: failed to create directory: " +  saved_data_dir
else:
    print "Successfully created 'SavedData' directory"

# on mac, copy the icon file and sign the app
if LOCAL_OS == MAC:
    app_dir = os.path.join(build_dir, "OpenBCI_GUI.app")
    icon_dir = os.path.join(sketch_dir, "sketch.icns")
    icon_dest = os.path.join(app_dir, "Contents", "Resources", "sketch.icns")
    try:
        shutil.copy2(icon_dir, icon_dest)
    except IOError:
        print "WARNING: Failed to copy sketch.icns"
    else:
        print "Successfully copied sketch.icns"

    # sign the app
    try:
        subprocess.check_call(["codesign", "-s",\
            "Developer ID Application: OpenBCI, Inc. (3P82WRGLM8)",\
            "-v", app_dir, "--force"])
    except CalledProcessError as err:
        print err
        print "WARNING: Failed to sign app."
    else:
        print "Successfully signed app."

# zip the file
print "Zipping ..."
zip_dir = build_dir + ".zip"

# mac app uses symlinks, and shutil does not handle symlinks, so we have to use the zip command
if LOCAL_OS == MAC:
    os.chdir(sketch_dir)
    subprocess.check_output(["zip", "-ry", zip_dir, build_dir_names[LOCAL_OS]])
    print "Done: " + zip_dir
else:
    # fix the directory structure: application.windows64/OpenBCI_GUI/OpenBCI_GUI.exe
    temp_dir = os.path.join(sketch_dir, "OpenBCI_GUI")
    os.rename(build_dir, temp_dir)
    os.mkdir(build_dir)
    shutil.move(temp_dir, build_dir)
    print "Done: " + shutil.make_archive(build_dir, 'zip', build_dir)

#cleanup to finish
cleanup_build_dirs()