#########################################################################################
#
#   Python script for building a release of the GUI software
#
#   Created: Daniel Lasry, Feb 2019
#
#   This is meant for members of the OpenBCI organization to quickly build new releases:
#   https://github.com/OpenBCI/OpenBCI_GUI/releases
#
#   Usage: > python release/build.py
#   No warranty. Use at your own risk. 
#
#########################################################################################

import sys
import os
import shutil
import platform
import subprocess

### Define platform-specific strings
###########################################################
MAC = 'Darwin'
LINUX = 'Linux'
WINDOWS = 'Windows'
LOCAL_OS = platform.system()

flavors = {
    WINDOWS : "application.windows64",
    LINUX : "application.linux64",
    MAC : "application.macosx"
}

def find_sketch_directory():
    # processing-java requires the cwd to build a release
    cwd = os.getcwd()
    sketch_directory = os.path.join(cwd, "OpenBCI_GUI")

    # Check that we are in the right directory to build
    main_file = os.path.join(sketch_directory, "OpenBCI_GUI.pde")
    if not os.path.isfile(main_file):
        sys.exit("ERROR: Could not find sketch file: " + main_file)

    return sketch_directory

def clean():
    print("Cleanup ...")
    for file in os.listdir(os.getcwd()):
        if file.startswith("application.") or file.startswith("openbcigui_"):
            file_path = os.path.join(os.getcwd(), file)
            if os.path.isdir(file_path):
                shutil.rmtree(file_path)
                print ("Successfully deleted " + file)
            elif os.path.isfile(file_path):
                os.remove(file_path)
                print ("Successfully deleted " + file)

def update_timestamp():
    sketch = find_sketch_directory()
    main_file = os.path.join(sketch, "OpenBCI_GUI.pde")

    timestamp = subprocess.check_output(['git', 'log', '-1', '--date=format:"%Y/%m/%d %T"', '--format=%ad']).decode("utf-8").strip('"\n')

    data = []
    with open(main_file, 'r') as sketch_file:
        data = sketch_file.readlines()

    for i in range(0, len(data)):
        if data[i].startswith("String localGUIVersionDate"):
            print(data[i])
            data[i] = "String localGUIVersionDate = \"" + timestamp + "\";\n"
            print(data[i])
            break

    with open(main_file, 'w') as sketch_file:
        sketch_file.writelines(data)

def build():
    # unfortunately, processing-java always returns exit code 1,
    # so we can't reliably check for success or failure
    # https://github.com/processing/processing/issues/5468
    
    sketch = find_sketch_directory()
    flavor = flavors[LOCAL_OS]
    print ("Using sketch: " + sketch)
    subprocess.check_call(["processing-java", "--sketch=" + sketch, "--output=" +  os.path.join(os.getcwd(), flavor), "--export"])

def delete_source_directory():
    build_directory = os.path.join(os.getcwd(), flavors[LOCAL_OS])
    source_directory = os.path.join(build_directory, "source")
    try:
        shutil.rmtree(source_directory)
    except OSError as error:
        print (error)
        print ("WARNING: Could not delete source directory: " + source_directory)
    else:
        print ("Successfully deleted source directory.")

def main ():
    clean()
    update_timestamp()
    build()
    delete_source_directory()

if __name__ == "__main__":
    main ()
