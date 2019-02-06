# Written for python 2.7, but could easily be adapted to python 3.

import sys, os, shutil, subprocess

# processing-java requires the cwd to build a release
cwd = os.getcwd()
sketch_dir = os.path.join(cwd, "OpenBCI_GUI")

# check that we are in the right directory to build
main_file_dir = os.path.join(sketch_dir, "OpenBCI_GUI.pde")
if not os.path.isfile(main_file_dir):
    sys.exit("ERROR: Could not find sketch file: " + main_file_dir)

# ask user for the hub directory
hub_dir = raw_input("Enter path to the HUB directory: ")
while not os.path.isdir(hub_dir):
    hub_dir = raw_input("Path does not exist, please re-enter: ")

# sanity check: does this directory contain the hub exe?
hub_exe = os.path.join(hub_dir, "OpenBCIHub.exe")
while not os.path.isfile(hub_exe):
    hub_dir = raw_input("OpenBCIHub.exe not found in this director, please re-enter: ")
    hub_exe = os.path.join(hub_dir, "OpenBCIHub.exe")

# unfortunately, processing-java always returns exit code 1,
# so we can't reliably check for success or failure
print "Using sketch: " + sketch_dir
subprocess.call(["processing-java", "--sketch="+sketch_dir, "--export"])

# sanity check: is the build output there?
build_dir = os.path.join(sketch_dir, "application.windows64")
if not os.path.isdir(build_dir):
    sys.exit("ERROR: Could not find build ouput: " + build_dir)

# delete source directory
source_dir = os.path.join(build_dir, "source")
if os.path.isdir(source_dir):
    print "Deleting source dir ..."
    shutil.rmtree(source_dir)
    

# sanity check: data directory?
data_dir = os.path.join(build_dir, "data")
if not os.path.isdir(data_dir):
    sys.exit("ERROR: Could not find data directory: " + data_dir)

# copy Hub to data directory
hub_dest_dir = os.path.join(data_dir, "OpenBCIHub")
try:
    shutil.copytree(hub_dir, hub_dest_dir)
except shutil.Error as err:
    print err
    sys.exit("ERROR: Failed to copy the Hub to the data dir.")
except WindowsError as err:
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
    print "Successfully created \"SavedData\" directory"

# TODO: Sign app!

# zip the file
print "Zipping ..."
print "Done: " + shutil.make_archive(build_dir, 'zip', build_dir)

build_dirs = ["application.windows32", "application.windows64"]
print "Cleanup ..."
for dir in build_dirs:
    print "Deleting " + dir
    shutil.rmtree(os.path.join(sketch_dir, dir))
