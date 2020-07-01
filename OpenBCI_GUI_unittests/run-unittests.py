import shutil
import subprocess
import os

# add files here that need to be copied to the unit testing sketch
# Question: Why not copy all PDE files?
# Answer:   Some PDE files depend on globals declared in OpenBCI_Gui.pde
#           and we do not copy OpenBCI_Gui.pde because it delcared a setup()
#           function which conflicts with the unit test sketch
files_to_unittest = [
    "PacketLossTracker.pde",
]

def main ():
    origin_path = "OpenBCI_GUI"
    destination_path = "OpenBCI_GUI_unittests"

    # copy any necessary files
    for filename in os.listdir(origin_path):
        if filename in files_to_unittest:
            orig = os.path.join(origin_path, filename)
            dest = os.path.join(destination_path, filename)
            shutil.copy(orig, dest)

    # run the unit testing sketch
    cwd = os.getcwd()
    sketch_dir = os.path.join(cwd, destination_path)
    subprocess.call(["processing-java", "--sketch=" + sketch_dir, "--run"])

if __name__ == "__main__":
    main ()