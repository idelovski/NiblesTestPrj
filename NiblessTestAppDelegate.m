//
//  NiblessTestAppDelegate.m
//  NiblessTest
//
//  Created by me on 16.08.23.
//  Copyright (c) 2023 Delovski d.o.o. All rights reserved.
//

#import  "NiblessTestAppDelegate.h"

#import  "transitionHeader.h"

static FORM_REC  theMainForm;

@implementation NiblessTestAppDelegate

@synthesize  window, menuDict, firstFormHandler;

- (id)init;
{
   if (self = [super init])  {
      self.menuDict = [NSMutableDictionary dictionary];
   }
   
   return (self);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   self.window = [MainLoop openInitialWindowAsForm:&theMainForm];
   
   self.firstFormHandler = [[FirstForm alloc] initWithWindow:self.window];
   
   [self.firstFormHandler performSelector:@selector(runMainLoop) withObject:nil afterDelay:.1];
   
   [self.window makeKeyAndOrderFront:NSApp];
   // [view release];
}

- (void)didFuckinPopUp:(id)sender
{
   NSMenuItem  *mi = (NSMenuItem *)sender;
   
   NSString  *msg = [NSString stringWithFormat:@"didFuckingPopUp:  %@", mi.title];
   
   NSLog (@"Message: %@", msg);
}

@end
