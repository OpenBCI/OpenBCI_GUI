import shutil
import subprocess
import os
import traceback

# add files here that need to be copied to the unit testing sketch
# Question: Why not copy all PDE files?
# Answer:   Some PDE files depend on globals declared in OpenBCI_GUI.pde
#           and we do not copy OpenBCI_GUI.pde because it delcares a setup()
#           function which conflicts with the unit test sketch
#           Once we get rid of globals we could copy all PDEs
files_to_unittest = [
    "PacketLossTracker.pde",
    "TimeTrackingQueue.pde"
]

def main ():
    origin_path = "OpenBCI_GUI"
    sketch_dir = "OpenBCI_GUI_UnitTests"

    # copy any necessary files
    for filename in os.listdir(origin_path):
        if filename in files_to_unittest:
            orig = os.path.join(origin_path, filename)
            dest = os.path.join(sketch_dir, filename)
            shutil.copy(orig, dest)

    try:
        # run the unit testing sketch
        cwd = os.getcwd()
        sketch_dir = os.path.join(cwd, sketch_dir)
        subprocess.check_call(["processing-java", "--sketch=" + sketch_dir, "--run"])
    except Exception as e:
        print(e)
        delete_files(sketch_dir)
        exit(1) # create CI failure

    delete_files(sketch_dir)

    fail_file = os.path.join(sketch_dir, "UNITTEST_FAILURE")
    if os.path.exists(fail_file):
        exit(1) # create CI failure


def delete_files(sketch_dir):
    # delete files copied above
    for filename in files_to_unittest:
        filepath = os.path.join(sketch_dir, filename)
        os.remove(filepath)

if __name__ == "__main__":
    main ()