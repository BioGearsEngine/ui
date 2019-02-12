Overview
==========

BioGears Simulation UI
----------------------

BioGears® simulation UI source code is hosted here. Our latest deployment is still in a beta phase, and is intended to be an intermediate release to showcase the capabilities of the BioGears® simulation UI. This version of the software is meant to elicit feedback and enhance community involvement in establishing end product expectations.

Objectives
----------

* To allow users to visually compose and execute BioGears® simulation scenarios
* To allow users to visualize BioGears® scenario actions and outputs in an intuitive timeline format

Building from Source
====================

BioGears® simulation UI requires the following dependencies:
* BioGears Physiology Engine - build requirements can be found [here](https://github.com/BioGearsEngine/core/wiki).
* Boost - build requirements can be found [here](https://www.boost.org/doc/libs/1_68_0/more/getting_started/index.html).
* QT 5 -  build requirements can be found [here](https://wiki.qt.io/Building_Qt_5_from_Git).

Building the Visualizer
------------------

To begin, make sure your copies of visualizer and external (both are submodules of BioGears) are up to date. Before you CMake:
1. Create a folder within your visualizer folder titled "build"
1. Point the source code and the binaries to the visualizer (refer to image below)
1. Add paths for usr and the windows external
     1. Click add entry
     1. Specify the name as "CMAKE_PREFIX_PATH"
     1. Specify the type as a path
     1. Enter the path to each folder (usr and windows-vc15-amd64 respectively) as the value
     1. Click OK
Once done, configure, generate, and open the project.

Running the Visualizer
------------------

Once open in Microsoft Visual Studios (MVS), right-click on BioGearsUI on the lefthand side of the screen in the Solution Explorer. Switch the configuration in the top left corner of the property page to be "All Configurations." On the left hand side of the screen, navigate to Configuration Properties→Debugging, and fill in the Environment box with the QT Path:

* QT_PLUGIN_PATH=D:\remotes\sed-stash\biogears\external\windows-vc15-amd64\plugins

**Note**: The above path is an example. Be sure to switch the path to your specific plugin folder of the windows build based on your folder configuration. 

Specify the configuration (release or debug) you wish to build in at the top of the MVS screen. Click the F7 key or navigate to the Build→Build Solution tab at the top of the screen. Make sure the build is successful. Then, navigate in the solution explorer to CMakePredefinedTargets→STAGE, right-clock on stage, and select build. Make sure this build is also successful. 

Click F5 or click the play button to run the solution. The viualizer/UI should pop up and prompt you with further directions.

**Note**: For full details, visit our wiki [here]( https://github.com/BioGearsEngine/ui/wiki/Running-the-Visualizer).


Additional Information
======================

Code of Conduct
------------------
We support the [contributor covenant](https://github.com/BioGearsEngine/Engine/blob/master/CODE_OF_CONDUCT.md) and the scope and enforcement it details. We reserve the right of enforcement that we feel is appropriate given the nature of the offense up to and including a permanent ban from the project.


Contributing 
-------------
Details will be filled in shortly. In the meantime if you have a contribution or issue to post/push feel free to contact abaird@ara.com with the details. 

Additional Documentation
--------------------------
For more detailed documentation including model discussions and implementation details can be found at www.BioGearsEngine.com


