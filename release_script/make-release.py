#########################################################################################
#
#   Python script for building and packaging a release of the GUI software
#
#   Created: Daniel Lasry, Feb 2019
#
#   This is meant for members of the OpenBCI organization to quickly build new releases:
#   https://github.com/OpenBCI/OpenBCI_GUI/releases
#
#   Usage: > python release_script/make-release.py
#   No warranty. Use at your own risk. 
#
#########################################################################################

import sys
import os
import shutil
import platform
import subprocess
import argparse
import requests
from bs4 import  BeautifulSoup

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

data_dir_names = {
    WINDOWS : "data",
    LINUX : "data",
    MAC : os.path.join("OpenBCI_GUI.app", "Contents", "Java", "data")
}

def get_timestamp_ci():
    repo_slug = None
    commit_id = None

    repo_slug = os.getenv("TRAVIS_REPO_SLUG")
    if repo_slug is None:
        repo_slug = os.getenv("APPVEYOR_REPO_NAME")

    commit_id = os.getenv("TRAVIS_COMMIT")
    if commit_id is None:
        commit_id = os.getenv("APPVEYOR_REPO_COMMIT")

    if repo_slug and commit_id:
        url = "http://github.com/" + repo_slug + "/commit/" + commit_id;

        page = requests.get(url)
        soup = BeautifulSoup(page.content, features="html.parser")

        timestamp = soup.find("relative-time")["datetime"]
        timestamp = timestamp.replace(":", "-")
        timestamp = timestamp.replace("T", "_")
        timestamp = timestamp.replace("Z", "")

        # write timestamp to file for use in CI
        with open("temp/timestamp.txt", 'w') as tempFile:
            tempFile.write(timestamp)

        return timestamp

    return ""

### Function: Pretty format for timestamp
###########################################################
def make_timestamp_pretty(timestamp):
    dateAndTime = timestamp.split("_")

    date = dateAndTime[0]
    time = dateAndTime[1]

    dateString = "/".join(date.split("-"))
    timeString = ":".join(time.split("-"))

    return dateString + " " + timeString

### Function: Apply timestamp in code
###########################################################
def apply_timestamp(sketch_dir, timestamp):
    main_file_dir = os.path.join(sketch_dir, "OpenBCI_GUI.pde")

    pretty_timestamp = make_timestamp_pretty(timestamp)

    data = []
    with open(main_file_dir, 'r') as sketch_file:
        data = sketch_file.readlines()

    for i in range(0, len(data)):
        if data[i].startswith("String localGUIVersionDate"):
            print(data[i])
            data[i] = "String localGUIVersionDate = \"" + pretty_timestamp + "\";\n"
            break

    with open(main_file_dir, 'w') as sketch_file:
        sketch_file.writelines(data)

### Function: Rename flavor with GUI version
###########################################################
def get_release_dir_name(sketch_dir, flavor, timestamp):
    main_file_dir = os.path.join(sketch_dir, "OpenBCI_GUI.pde")
    version_str = "VERSION.NOT.FOUND"
    with open(main_file_dir, 'r') as sketch_file:
        for line in sketch_file:
            if line.startswith("String localGUIVersionString"):
                quotes_pos = [pos for pos, char in enumerate(line) if char == '"']
                version_str = line[quotes_pos[0]+1:quotes_pos[1]]
                print(version_str)
                break

    # write version string to file for use in CI
    with open("temp/versionstring.txt", 'w') as tempFile:
        tempFile.write(version_str)

    new_name = "openbcigui_" + version_str + "_"
    if timestamp:
        new_name = new_name + timestamp + "_"
    return flavor.replace("application.", new_name)

### Function: Find the sketch directory
###########################################################
def find_sketch_dir():
    # processing-java requires the cwd to build a release
    cwd = os.getcwd()
    sketch_dir = os.path.join(cwd, "OpenBCI_GUI")

    # check that we are in the right directory to build
    main_file_dir = os.path.join(sketch_dir, "OpenBCI_GUI.pde")
    if not os.path.isfile(main_file_dir):
        sys.exit("ERROR: Could not find sketch file: " + main_file_dir)

    return sketch_dir

### Function: Clean up any old build directories or .zips
###########################################################
def cleanup_build_dirs():
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

### Function: Ask user for windows signing info
###########################################################
def ask_windows_signing():
    windows_signing = False
    windows_pfx_path = ''
    windows_pfx_password = ''
    if LOCAL_OS == WINDOWS:
        is_signing = input("Will you be signing the app? (Y/n): ")
        if is_signing.lower() != 'n':
            windows_signing = True
            windows_pfx_path = input("Path to PFX file: ")
            while not os.path.isfile(windows_pfx_path):
                windows_pfx_path = input("PFX file not found. Re-enter: ")
            windows_pfx_password = input("Password for the PFX file: ")

    return windows_signing, windows_pfx_path, windows_pfx_password

### Function: Run a build using processing-java
###########################################################
def build_app(sketch_dir, flavor):
    # unfortunately, processing-java always returns exit code 1,
    # so we can't reliably check for success or failure
    # https://github.com/processing/processing/issues/5468
    print ("Using sketch: " + sketch_dir)
    subprocess.check_call(["processing-java", "--sketch=" + sketch_dir, "--output=" +  os.path.join(os.getcwd(), flavor), "--export"])

### Function: Package the app in the expected file structure
###########################################################
def package_app(sketch_dir, flavor, timestamp, windows_signing=False, windows_pfx_path = '', windows_pfx_password = ''):
    # sanity check: is the build output there?
    build_dir = os.path.join(os.getcwd(), flavor)
    if not os.path.isdir(build_dir):
        sys.exit("ERROR: Could not find build ouput: " + build_dir)

    # rename the build dir
    release_dir_name = get_release_dir_name(sketch_dir, flavor, timestamp)
    new_build_dir = os.path.join(os.getcwd(), release_dir_name)
    os.rename(build_dir, new_build_dir)
    build_dir = new_build_dir

    # delete source directory
    source_dir = os.path.join(build_dir, "source")
    try:
        shutil.rmtree(source_dir)
    except OSError as err:
        print (err)
        print ("WARNING: Could not delete source dir: " + source_dir)
    else:
        print ("Successfully deleted source dir.")

    ### On mac, copy the icon file and sign the app
    ###########################################################
    if LOCAL_OS == MAC:
        app_dir = os.path.join(build_dir, "OpenBCI_GUI.app")
        icon_dir = os.path.join(sketch_dir, "sketch.icns")
        icon_dest = os.path.join(app_dir, "Contents", "Resources", "sketch.icns")
        try:
            shutil.copy2(icon_dir, icon_dest)
        except IOError:
            print ("WARNING: Failed to copy sketch.icns")
        else:
            print ("Successfully copied sketch.icns")

        # sign the app
        try:
            subprocess.check_call(["codesign", "-f", "-v", "-s"\
                "Developer ID Application: OpenBCI, Inc. (3P82WRGLM8)", app_dir])
        except subprocess.CalledProcessError as err:
            print (err)
            print ("WARNING: Failed to sign app.")
        else:
            print ("Successfully signed app.")

    if LOCAL_OS == WINDOWS:
        exe_dir = os.path.join(build_dir, "OpenBCI_GUI.exe")
        assert(os.path.isfile(exe_dir))

        # On Windows, set the application manifest
        ###########################################################
        try:
            subprocess.check_call(["mt", "-manifest", "release_script/windows_only/gui.manifest",
                "-outputresource:" + exe_dir + ";#1"])
        except subprocess.CalledProcessError as err:
            print (err)
            print ("WARNING: Failed to set manifest for OpenBCI_GUI.exe")

        java_exe_dir = os.path.join(build_dir, "java", "bin", "java.exe")
        javaw_exe_dir = os.path.join(build_dir, "java", "bin", "javaw.exe")
        assert (os.path.isfile(java_exe_dir))
        assert (os.path.isfile(javaw_exe_dir))
        try:
            subprocess.check_call(["mt", "-manifest", "release_script/windows_only/java.manifest",
                "-outputresource:" + java_exe_dir + ";#1"])
            subprocess.check_call(["mt", "-manifest", "release_script/windows_only/java.manifest",
                "-outputresource:" + javaw_exe_dir + ";#1"])
        except subprocess.CalledProcessError as err:
            print (err)
            print ("WARNING: Failed to set manifest for java.exe and javaw.exe")

        ### On Windows, sign the app
        ###########################################################
        if windows_signing:
            try:
                subprocess.check_call(["SignTool", "sign", "/f", windows_pfx_path, "/p",\
                    windows_pfx_password, "/tr", "http://timestamp.digicert.com", "/td", "SHA256", exe_dir])
            except subprocess.CalledProcessError as err:
                print (err)
                print ("WARNING: Failed to sign app.")

    ### On Mac, make a .dmg and sign it
    ###########################################################
    if LOCAL_OS == MAC:
        app_dir = os.path.join(build_dir, "OpenBCI_GUI.app")
        dmg_dir = build_dir + ".dmg"
        try:
            subprocess.check_call(["dmgbuild", "-s", "release_script/mac_only/dmgbuild_settings.py", "-D",\
                "app=" + app_dir, "OpenBCI_GUI", dmg_dir])
        except subprocess.CalledProcessError as err:
            print (err)
            print ("WARNING: Failed create the .dmg file.")
        else:
            print ("Successfully created " + dmg_dir)

        # sign the dmg
        try:
            subprocess.check_call(["codesign", "-f", "-v", "-s"\
                "Developer ID Application: OpenBCI, Inc. (3P82WRGLM8)", dmg_dir])
        except subprocess.CalledProcessError as err:
            print (err)
            print ("WARNING: Failed to sign dmg.")
        else:
            print ("Successfully signed dmg.")

    ### Else zip the file
    ###########################################################
    else:
        print ("Zipping ...")
        # fix the directory structure: application.windows64/OpenBCI_GUI/OpenBCI_GUI.exe
        temp_dir = os.path.join(sketch_dir, "OpenBCI_GUI")
        os.rename(build_dir, temp_dir)
        os.mkdir(build_dir)
        shutil.move(temp_dir, build_dir)
        print ("Done: " + shutil.make_archive(build_dir, 'zip', build_dir))


def main ():
    parser = argparse.ArgumentParser ()
    # use docs to check which parameters are required for specific board, e.g. for Cyton - set serial port
    parser.add_argument ('--no-prompts', action = 'store_true', help  = 'whether to prompt the user for anything', required = False)
    parser.add_argument ('--pfx-path', type = str, help  = 'path to the pfx file for windows signing', required = False, default = '', nargs='?')
    parser.add_argument ('--pfx-password', type = str, help  = 'password for the pfx file for windows signing', required = False, default = '', nargs='?')
    args = parser.parse_args ()

    # grab the sketch directory
    sketch_dir = find_sketch_dir()

    # ask about signing
    windows_signing = False
    windows_pfx_path = args.pfx_path
    windows_pfx_password = args.pfx_password

    if windows_pfx_path and windows_pfx_password:
        windows_signing = True
    elif(not args.no_prompts):
        windows_signing, windows_pfx_path, windows_pfx_password = ask_windows_signing()

    # Cleanup to start
    cleanup_build_dirs()

    flavor = flavors[LOCAL_OS]

    timestamp = get_timestamp_ci()
    if timestamp:
        apply_timestamp(sketch_dir, timestamp)

    # run the build (processing-java)
    build_app(sketch_dir, flavor)

    #package it up
    package_app(sketch_dir, flavor, timestamp, windows_signing, windows_pfx_path, windows_pfx_password)

if __name__ == "__main__":
    main ()