# NiblessTestPrj
Experiments with Carbon/Cocoa mix

A bit chaotic code but it should contain all the UI components I need for my real application.

So, this should be an experiment with the older Carbon code that will have to change from 32 bit Carbon to 64 bit Cocoa.

General idea is to convert as little Carbon code to Cocoa and continue using CarbonCore for everything that is still possible with CarbonCore so it compiles on M1 and latest Xcode having the deprecations warnings off.

There is no NIB/XIB file and everything is created in code except  for the things from an old Resource file in Classic Mac resorce format.

App starts without a NIB file - therefore, it's a so called nibless application.

I don't think this rsrc file will be handled well by GitHub, but I have added a zip archive so at least it can be extracted into a good resource file.

# So, before running, code signing identity may be a problem, so add or remove "-" identity and then expand the zip archive in Rsrc folder after removing downloaded zero-length rsrc file.

Project includes NSFont+CFTraits NSFont cat from the gist by Eric Methot: https://gist.github.com/macprog-guy/156d33bfefef570a7efb

Then, there's another thing related to classic resources. Xcode has this 'Build Carbon Resources Phase' but that seems to be useless in newer Xcode versions. That is why there is a ''Run Script Phase' ant that script does the thing with a rsrc file and later creates a zip archive of our target.

More information related to nibless applications: https://github.com/hammackj/niblesscocoa
