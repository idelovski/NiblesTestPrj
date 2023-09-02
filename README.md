# NiblesTestPrj
Experiments with Carbon/Cocoa mix

A bit chaotic code but it should contain all the UI components I need for my real application.

So, this should be an experiment with the older Carbon code that will have to change from 32 bit Carbon to 64 bit Cocoa.

General idea is to convert as little Carbon code to Cocoa and continue using CarbonCore for everything that is still possible with CarbonCore so it compiles on M1 and latest Xcode having the deprecations warnings off.

There is no NIB/XIB file and everything is created in code except  for the things from an old Resource file in Classic Mac resorce format.

App starts without a NIB file - therefore, it's so called a nibless application.

I don't think this rsrc file will be handled well by GitHub, but I have added a zip archive so at least it can be extracted into a good resource file.

# So, before running, code signing identity may be a problem, so add or remove "-" identity and then expand the zip archive in Rsrc folder after removing downloaded zero-length rsrc file.

Project includes NSFont+CFTraits NSFont cat from the gist by Eric Methot: https://gist.github.com/macprog-guy/156d33bfefef570a7efb
