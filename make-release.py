# Written for python 2.7, but could easily be adapted to python 3.

import sys, os, shutil, platform, subprocess

WINDOWS = 'Windows'
MAC = 'Darwin'
LOCAL_OS = platform.system()

build_dir_names = {
    WINDOWS : "application.windows64",
    MAC : "application.macosx"
}

data_dir_names = {
    WINDOWS : "data",
    MAC : os.path.join("OpenBCI_GUI.app", "Contents", "Java", "data")
}

hub_dir_names = {
    WINDOWS : "OpenBCIHub",
    MAC : "OpenBCIHub.app"
}

# processing-java requires the cwd to build a release
cwd = os.getcwd()
sketch_dir = os.path.join(cwd, "OpenBCI_GUI")

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

elif LOCAL_OS == MAC:
    while not hub_dir.endswith("OpenBCIHub.app"):
        hub_dir = raw_input("Expected a path to OpenBCIHub.app, please re-enter:")

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
    print "WARNING: Could not delete source dir: " + source_dir
    print err
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
except OSError as err:
    print err
    sys.exit("ERROR: Failed to copy the Hub to the data dir.")
else:
    print "Successfully copied Hub to the data dir."

# create SavedData dir
saved_data_dir = os.path.join(build_dir, "SavedData")
try:
    os.mkdir(saved_data_dir)
except OSError:
    print "ERROR: failed to create directory: " +  saved_data_dir
else:
    print "Successfully created 'SavedData' directory"

# on mac, copy the icon file
if LOCAL_OS == MAC:
    icon_dir = os.path.join(sketch_dir, "sketch.icns")
    icon_dest = os.path.join(build_dir, "OpenBCI_GUI.app", "Contents", "Resources", "sketch.icns")
    try:
        shutil.copy2(icon_dir, icon_dest)
    except IOError:
        print "WARNING: Filed to copy sketch.icns"
    else:
        print "Successfully copied sketch.icns"

# TODO: Sign app!
# TODO: Delete existing zip!

# zip the file
print "Zipping ..."
zip_dir = build_dir + ".zip"
# windows print "Done: " + shutil.make_archive(build_dir, 'zip', build_dir)
try:
    os.chdir(sketch_dir)
    subprocess.check_output(["zip", "-ry", zip_dir, build_dir_names[LOCAL_OS]])
except subprocess.CalledProcessError as err:
    sys.exit("ERROR: could not zip " + build_dir)
else:
    print "Zip successful: " + zip_dir

# clean up build dirs
build_dirs = ["application.windows32", "application.windows64", "application.macosx"]
print "Cleanup ..."
for dir in build_dirs:
    try:
        shutil.rmtree(os.path.join(sketch_dir, dir))
    except OSError:
        pass
    else:
        print "Successfully deleted " + dir
