//
//  main.m
//  NiblessTest
//
//  Created by me on 16.08.23.
//  Copyright (c) 2023 Delovski d.o.o. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NiblessTestAppDelegate.h"
#import "MainLoop.h"

int  main (int argc, char *argv[])
{
    // return NSApplicationMain(argc,  (const char **) argv);
   NSAutoreleasePool  *pool = [[NSAutoreleasePool alloc] init]; 

   [NSApplication sharedApplication]; 
   
   NiblessTestAppDelegate  *appDelegate = [[NiblessTestAppDelegate alloc] init]; 
   
   [NSApp setDelegate:appDelegate];
   
   [MainLoop buildMainMenu];
   
   [NSApp run];
   
   [appDelegate release];
   
   [pool release]; 
   
   return (0);
}
