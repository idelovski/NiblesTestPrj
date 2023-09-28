//
//  NiblessTestAppDelegate.m
//  NiblessTest
//
//  Created by me on 16.08.23.
//  Copyright (c) 2023 Delovski d.o.o. All rights reserved.
//

#import  "NiblessTestAppDelegate.h"

#import  "transitionHeader.h"

extern  DTGlobalData  *dtGData;

@implementation NiblessTestAppDelegate

@synthesize  window, menuDict, firstFormHandler;

- (id)init;
{
   if (self = [super init])  {
      self.menuDict = [NSMutableDictionary dictionary];
   }
   
   return (self);
}

#pragma mark -

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   [MainLoop handleApplicationDidFinishLaunchingWithAppDelegate:self];
}

- (void)applicationWillHide:(NSNotification *)notification;
{
   NSLog (@"applicationWillHide:");
}
- (void)applicationDidHide:(NSNotification *)notification;
{
   NSLog (@"applicationDidHide:");
}
- (void)applicationWillUnhide:(NSNotification *)notification;
{
   NSLog (@"applicationWillUnhide:");
}
- (void)applicationDidUnhide:(NSNotification *)notification;
{
   NSLog (@"applicationDidUnhide:");
}
- (void)applicationWillBecomeActive:(NSNotification *)notification;
{
   NSLog (@"applicationWillBecomeActive:");
}

- (void)applicationDidBecomeActive:(NSNotification *)notification;
{
   static short  once = FALSE;
   NSLog (@"applicationDidBecomeActive:");
   // Call this only if there are more than one window acive or I don't know... well, if there's a modal window!
   // For some reason at startup if I call -activateWithOptions: my window becomes inactive
   if (!once)
      once = TRUE;
   else  if (dtGData->modalFormsCount)
      [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateAllWindows];
   dtGData->appInBackground = FALSE;
}

- (void)applicationWillResignActive:(NSNotification *)notification;
{
   NSLog (@"applicationWillResignActive:");
}

- (void)applicationDidResignActive:(NSNotification *)notification;
{
   NSLog (@"applicationDidResignActive:");
   
   dtGData->appInBackground = TRUE;
}

- (void)applicationWillUpdate:(NSNotification *)notification;
{
   // NSLog (@"applicationWillUpdate:");  - Too chatty
}
- (void)applicationDidUpdate:(NSNotification *)notification;
{
   // NSLog (@"applicationDidUpdate:");  - Too chatty
}
- (void)applicationWillTerminate:(NSNotification *)notification;
{
   NSLog (@"applicationWillTerminate:");
}
- (void)applicationDidChangeScreenParameters:(NSNotification *)notification;
{
   NSLog (@"applicationDidChangeScreenParameters:");
}

#pragma mark -

- (void)didFuckinPopUp:(id)sender
{
   NSMenuItem  *mi = (NSMenuItem *)sender;
   
   NSString  *msg = [NSString stringWithFormat:@"didFuckingPopUp:  %@", mi.title];
   
   NSLog (@"Message: %@", msg);
}

@end
