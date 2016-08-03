INSTALL

This repository is organized so that you can place it in a folder named minim inside of your Processing sketchbook's libraries folder.

You can accomplish this in two ways:

1) Download the repository.

* Click on the Downloads button (at https://github.com/ddf/Minim) and select one of the packages provided.
* Extract the contents of that package into a directory named minim inside of the libraries folder in your sketchbook.
* Remove the version of Minim that is included with Processing:
  - On OSX: Find your Processing.app and right click, choose ÒShow Package ContentsÓ. Then dig down to Contents/Resources/Java/modes/java/libraries and delete the minim folder in there.
  - On Windows: From the directory that contains Processing.exe, dig down to modes/java/libraries and delete the minim folder there. 
* Open (or restart) Processing and in the Sketch -> Import Library menu you should see 'minim' in the contributed libraries list. 

2) Clone the repository using git.

* Install git on your machine.
* From the libraries folder in your Processing sketchbook, clone the repository into a directory called minim, like so:

	git clone git://github.com/ddf/Minim.git minim

* You will now have a readonly copy of this repository that you can keep sync'd by periodically pulling the latest updates ( using 'git pull' ).
* Remove the version of Minim that is included with Processing:
  - On OSX: Find your Processing.app and right click, choose ÒShow Package ContentsÓ. Then dig down to Contents/Resources/Java/modes/java/libraries and delete the minim folder in there.
  - On Windows: From the directory that contains Processing.exe, dig down to modes/java/libraries and delete the minim folder there.
* Open (or restart) Processing and in the Sketch -> Import Library menu you should see 'minim' in the contributed libraries list. 

DEVELOP

This repository is already setup as an Eclipse project. Once you have acquired a copy of the repository in one of the above two ways, you can import it into Eclipse as an existing project and browse around the source, making any changes you want. To do so you must:

* Set your Eclipse workspace to be the 'libraries' folder of your Processing sketchbook.
* Right-click in the Package Explorer and choose 'Import...'.
* Under General choose 'Existing Projects into Workspace' and hit 'Next'.
* Use the 'Select root directory' option and use Browse to choose the libraries folder of your Processing sketchbook.
* It should find a project named 'minim'. Make sure it is checked.
* Make sure that 'Copy projects into workspace' is not checked.
* Click 'Finish'.

You should now have a browsable project in the package explorer called 'minim' that will auto-build class files. You may encounter errors if you don't have a default JRE set in Eclipse. Make sure that you have an installed JRE by going to Preferences and looking under Java -> Installed JREs.

To build the project right-click on build.xml and choose Run As -> Ant Build. 
Once you do this, you can use the build in Processing immediately. 
It is not necessary to restart Processing after building the library.
If you want local documentation, choose Run As -> Ant Build... and make sure that the 'doc' option is checked and then build the project.

CONTRIBUTE

If you'd like to contribute to the development of Minim, you will need to fork the repository on Github.

* If you have an account with Github, you can fork the repository by simply clicking the Fork button on the Minim github page (https://github.com/ddf/Minim).
* From the libraries folder in your Processing sketchbook, clone your forked repository into a directory called minim, like so:

	git clone <the ssh link to your github fork> minim

* You will now have a copy of your forked repository that you can push changes to and keep sync'd with the main development branch by performing periodic merges.

When you've made a change that you'd like to see included in the main development branch, you can send a Pull Request through Github. The Minim dev team will review your changes and accept them if they are in line with our goals and standards. If they are not, we will probably let you know why we didn't accept the Pull Request. Development of Minim is by no means a full-time endeavor, so don't be surprised if it takes us a while to review your request.

If you intend to make changes to the source that you want submit to the main development branch, please use the code_formatting_style.xml file as your Java formatting rules. To do so, you must:

* Open your Eclipse Preferences and go to Java -> Code Style -> Formatter
* Click on Import... and choose code_formatting_style.xml from the sketchbook/libraries/minim directory
* Click Apply and then OK.

If you change your Active profile, be sure to change it back to 'Minim Standards' before editing Minim source.


HAVE FUN!
