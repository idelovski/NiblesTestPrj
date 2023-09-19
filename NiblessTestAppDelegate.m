//
//  NiblessTestAppDelegate.m
//  NiblessTest
//
//  Created by me on 16.08.23.
//  Copyright (c) 2023 Delovski d.o.o. All rights reserved.
//

#import  "NiblessTestAppDelegate.h"

#import  "transitionHeader.h"

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
   [MainLoop handleApplicationDidFinishLaunchingWithAppDelegate:self];
}

- (void)didFuckinPopUp:(id)sender
{
   NSMenuItem  *mi = (NSMenuItem *)sender;
   
   NSString  *msg = [NSString stringWithFormat:@"didFuckingPopUp:  %@", mi.title];
   
   NSLog (@"Message: %@", msg);
}

@end
