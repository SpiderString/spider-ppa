This is the package for the CobwebPackageManager. CPM is used to facilitate automatic installation, binding, and upgrading of Advanced Macros packages in-game from any properly set up Github repository.

When installing for the first time, download the zip file which corresponds to your major AM version. For example, if you are running AM version 7.x.x, download CobwebPackageManager_AM7.zip.

To install CPM, simply download the correct zip and place the folder contained within it in .minecraft/mods/advancedMacros/macros.
Then, bind CobwebPackageManager/cobwebUI to the "ChatSendFilter" event and type '!cpm upgrade' to grab the latest version for your AM installation.

To list available packages, type '!cpm list'. Third party repositories are supported, though at current the url must be entered in the repository list manually. To install a package, type '!cpm install \[packageName\]'. If you decide you no longer want a package, just type '!cpm remove \[packageName\]'. This will unbind all scripts in the package's directory and delete it. It will not delete any content used by the package in other directories, such as ~/common/. This means if you reinstall it in the future things such as configuration files will still be there so long as the package used files in a directory other than its native one.

These instructions may be subject to change as newer versions of the zip are uploaded after major changes.
