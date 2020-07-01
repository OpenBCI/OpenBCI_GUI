import shutil
import subprocess
import os

# add files here that need to be copied to the unit testing sketch
# Question: Why not copy all PDE files?
# Answer:   Some PDE files depend on globals declared in OpenBCI_GUI.pde
#           and we do not copy OpenBCI_GUI.pde because it delcared a setup()
#           function which conflicts with the unit test sketch
#           Once we get rid of globals we could copy all PDEs
files_to_unittest = [
    "PacketLossTracker.pde",
]

def main ():
    origin_path = "OpenBCI_GUI"
    sketch_dir = "OpenBCI_GUI_unittests"

    # copy any necessary files
    for filename in os.listdir(origin_path):
        if filename in files_to_unittest:
            orig = os.path.join(origin_path, filename)
            dest = os.path.join(sketch_dir, filename)
            shutil.copy(orig, dest)

    # run the unit testing sketch
    cwd = os.getcwd()
    sketch_dir = os.path.join(cwd, sketch_dir)
    subprocess.check_call(["processing-java", "--sketch=" + sketch_dir, "--run"])

    fail_file = os.path.join(sketch_dir, "UNITTEST_FAILURE")
    print(fail_file)
    if os.path.exists(fail_file):
        exit(1)


if __name__ == "__main__":
    main ()