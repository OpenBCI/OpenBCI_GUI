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
                print("GUI Version: " + version)
                break

    new_name = "openbcigui_" + version + "_"
    build_directory = os.path.join(os.getcwd(), flavors[LOCAL_OS])
    print("Build directory: " + build_directory)

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

        print ("Fixed issue on Linux when launching from directory with spaces.")

    if LOCAL_OS == MAC:
        shutil.move(flavors[LOCAL_OS] + ".dmg", new_name + "macosx.dmg")
    elif LOCAL_OS == LINUX:
        release_directory = flavors[LOCAL_OS].replace("application.", new_name)
        release_directory = os.path.join(os.getcwd(), release_directory)
        print("Release directory: " + release_directory)

        temporary_directory = os.path.join(sketch_directory, "OpenBCI_GUI")
        print("Temporary directory: " + temporary_directory)
        os.rename(build_directory, temporary_directory)
        os.mkdir(release_directory)
        shutil.move(temporary_directory, release_directory)
        shutil.make_archive(release_directory, 'zip', release_directory)
    else:
        update_wix_version(version)
        print("Making WiX installer for Windows")
        wix_command = f'dotnet build {os.getcwd()}\\release\\wix\\OpenBCI_GUI.wixproj -c Release -p:ProductVersion={version}'
        print(wix_command)
        os.system(wix_command)
        name = 'msi_path'
        found_msi_files = [f for f in os.listdir(os.path.join(os.getcwd(), 'release', 'wix', 'bin', 'Release', 'en-US')) if f.endswith('.msi')]
        print(f'Found MSI files: {found_msi_files}')
        msi_path = os.path.join(os.getcwd(), 'release', 'wix', 'bin', 'Release', 'en-US', found_msi_files[0])
        github_output = os.getenv('GITHUB_OUTPUT')
        if github_output is not None:
            with open(os.environ['GITHUB_OUTPUT'], 'a') as fh:
                print(f'{name}={msi_path}', file=fh)
        else:
            print(f'{name}={msi_path}')

def update_wix_version(version):
    wix_file = os.path.join(os.getcwd(), "release", "wix", "Package.wxs")
    with open(wix_file, 'r') as file :
        filedata = file.read()

    filedata = replace_between_identifiers(filedata, 'Version="', '"', version + '"')
    with open(wix_file, 'w') as file:
        file.write(filedata)
                                
def replace_between_identifiers(text, start_id, end_id, replacement):
    start_index = text.find(start_id)
    end_index = text.find(end_id, start_index + len(start_id))
    
    if start_index == -1 or end_index == -1:
        # If either identifier is not found, return the original text
        return text
    
    # Include the end identifier in the part to be replaced
    end_index += len(end_id)
    
    # Replace the part between the identifiers
    new_text = text[:start_index + len(start_id)] + replacement + text[end_index:]
    return new_text

if __name__ == "__main__":
    main ()
