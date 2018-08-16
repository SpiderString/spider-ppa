# spider-ppa
Repository of package pointers for the Advanced Macros Minecraft mod.
Each package should have its own script list pointed to by the packages file. The url to the packages file is what has to be added to the repository list for each person running the package manager.

Downloads can be done manually, but ideally you should install CobwebPackageManager first and let it handle them for you.
To do that, go to the CobwebPackageManager folder and download the zip file there.
Then, navigate to .minecraft/mods/advancedMacros/macros and create a folder named "CobwebPackageManager"
Extract the files from the zip to that folder.
Bind cobwebUI to the Chat event
Run the command "!cpm install CobwebPackageManager". Caps doesn't matter for the package name.

After that, you can install any of the packages here with !cpm install \[packageName] and it'll fetch it and install it for you.
Anytime you join a world after that it will check for updates for your installed packages and automatically download them.
