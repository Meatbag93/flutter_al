# flutter_al

a flutter plugin to use OpenALSoft.

## building


### android

android builds by default automatically, no additional steps required.

### ios/macos

for ios/macos you need to manually build the library into a framework and embed it into xcode, thankfully that process is simplified into a phew steps.
1. Clone openAl soft.

$ git clone https://github.com/kcat/openal-soft.git
cd openal-soft

2. Build using CMake.
mkdir build
cd build
for ios:
cmake .. -DCMAKE_SYSTEM_NAME=iOS -DALSOFT_OSX_FRAMEWORK=ON
for macos:
cmake .. -DALSOFT_OSX_FRAMEWORK=ON
cmake --build .
3. Copy the resulting soft_oal.framework folder/file into the ios directory found in your flutter project's main directory.
4. In the ios directory open runner.xworkspace, after xcode launchs, go to the editor  and select the general tab, you'll find an embeded frameworks section, click on the add button and select 
the other button to open the file browse, select the soft_oal.framework file/folder that you just moved, might require you to move back a folder or 2.


should work afterward.

