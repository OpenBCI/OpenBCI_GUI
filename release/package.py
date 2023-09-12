#########################################################################################
#
#   Python script for packaging a build of the GUI software
#
#   This is meant for members of the OpenBCI organization to quickly create new releases:
#   https://github.com/OpenBCI/OpenBCI_GUI/releases
#
#   Usage: > python release/package.py
#   No warranty. Use at your own risk. 
#
#########################################################################################

import os
import shutil
import platform
import subprocess

MAC = 'Darwin'
LINUX = 'Linux'
WINDOWS = 'Windows'
LOCAL_OS = platform.system()

flavors = {
    WINDOWS : "application.windows64",
    LINUX : "application.linux64",
    MAC : "application.macosx"
}

def main ():
    cwd = os.getcwd()
    sketch_directory = os.path.join(cwd, "OpenBCI_GUI")
    main_file = os.path.join(sketch_directory, "OpenBCI_GUI.pde")

    version = "VERSION.NOT.FOUND"
    with open(main_file, 'r') as sketch_file:
        for line in sketch_file:
            if line.startswith("String localGUIVersionString"):
                quotes_pos = [pos for pos, char in enumerate(line) if char == '"']
                version = line[quotes_pos[0]+1:quotes_pos[1]]
                print(version)
                break

    new_name = "openbcigui_" + version + "_"
    
    timestamp = subprocess.check_output(['git', 'log', '-1', '--date=format:"%Y-%m-%d_%H-%M-%S"', '--format=%ad']).decode("utf-8").strip('"\n')
    new_name = new_name + timestamp + "_"

    build_directory = os.path.join(os.getcwd(), flavors[LOCAL_OS])

    # Allow GUI to launch from directory with spaces #916
    if LOCAL_OS == LINUX:
        # Read in the file
        with open(build_directory + '/OpenBCI_GUI', 'r') as file :
            filedata = file.read()

        # Replace the target string
        filedata = filedata.replace('$APPDIR/java/bin/java', '\"$APPDIR/java/bin/java\"')

        # Write the file out again
        with open(build_directory + '/OpenBCI_GUI', 'w') as file:
            file.write(filedata)

        print ( "Fixed issue on Linux when launching from directory with spaces.")

    if LOCAL_OS == MAC:
        shutil.move(flavors[LOCAL_OS] + ".dmg", new_name + "macosx.dmg")
    else:
        release_directory = flavors[LOCAL_OS].replace("application.", new_name)
        release_directory = os.path.join(os.getcwd(), release_directory)

        temporary_directory = os.path.join(sketch_directory, "OpenBCI_GUI")
        os.rename(build_directory, temporary_directory)
        os.mkdir(release_directory)
        shutil.move(temporary_directory, release_directory)
        shutil.make_archive(release_directory, 'zip', release_directory)

if __name__ == "__main__":
    main ()
