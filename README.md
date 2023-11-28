# NiblessTestPrj:
Experiments with Carbon/Cocoa mix

A bit chaotic code but it should contain all the Cocoa/Core Foundation components I need for my real application.

So, this should be an experiment with the older Carbon code that will have to change from 32 bit Carbon to 64 bit Cocoa.

General idea is to convert as little Carbon code to Cocoa and continue using CarbonCore for everything that is still possible with CarbonCore so it compiles on M1 and latest Xcode having the deprecations warnings off.

App starts without a NIB file - therefore, it's a so called nibless application. More information related to nibless applications: https://github.com/hammackj/niblesscocoa

There is no NIB/XIB file and everything is created in code except  for the things from an old Resource file in Classic Mac resorce format.

There are these three lines:

    GetResource ('MENU', menu_id);
    GetResource ('DITL', ditl_id);
    GetResource ('STR#', stra_id);

CarbonCore allows you to read these resources but then you are on your own, parsing them requires information from old Inside Macintosh volumes from the eighties and this project contains an example how to do exactly that. Menus and windows are recreated from these two resource types.

I don't think this rsrc file will be handled well by GitHub, but I have added a zip archive so at least it can be extracted into a good resource file.

**So, before running, code signing identity may be a problem, so add or remove "-" identity and then expand the zip archives in Rsrc folder after removing downloaded zero-length rsrc files - two of them.**

Project includes NSFont+CFTraits NSFont cat from the gist by Eric Methot: https://gist.github.com/macprog-guy/156d33bfefef570a7efb

Then, there's another thing related to classic resources. Xcode has this "Build Carbon Resources Phase" but that seems to be useless in newer Xcode versions. That is why there is a "Run Script Phase" ant that script does the thing with a rsrc file and later creates a zip archive of our target.

The script:

    RESOURCE_DIR="${PROJECT_DIR}/Rsrc"
    APP_BUNDLE="${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.app" 

    /Applications/Xcode.app/Contents/Developer/usr/bin/ResMerger -srcIs RSRC "${RESOURCE_DIR}/Appl_KnjigeNT.rsrc" -srcIs RSRC "${RESOURCE_DIR}/dTOOL_All.rsrc" -o "${APP_BUNDLE}/Contents/Resources/${TARGET_NAME}.rsrc"
    
    cd $BUILT_PRODUCTS_DIR

    rm -f ${TARGET_NAME}.zip

    zip -r ${TARGET_NAME} ${TARGET_NAME}.app

   
Since the project may be compiled on different Xcode/clang versions, certain flags may be reqired or not. But then the clang will complain about unrecognized flags:

    -Wall -Wno-unused-variable -Wno-parentheses -Wno-unused-but-set-variable -Wno-unknown-warning-option

Adding *-Wno-unknown-warning-option* will silence it.

And with Xcode 15.0.1 my project was failing to build properly.

Resources copied to the resulting app were somehow bad. GetResource() failed to load anything and CountResources() would give me count lower than I expected. After experimenting and finding out that app runs just fine if I manually copy the rsrsc file into the resulting app bundle, I think I found the problem.

ResMerger that ends up in /usr/bin does not work properly. Changing the above script to use ResMerger inside Xcode does the trick.

/Applications/Xcode.app/Contents/Developer/usr/bin/ResMerger works properly and application works as expected.
