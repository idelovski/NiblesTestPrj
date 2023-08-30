//
//  NiblesTestAppDelegate.m
//  NiblesTest
//
//  Created by me on 16.08.23.
//  Copyright (c) 2023 Delovski d.o.o. All rights reserved.
//

#import  "NiblesTestAppDelegate.h"

#import  "transitionHeader.h"

static FORM_REC  theMainForm;

@implementation NiblesTestAppDelegate

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
#ifdef _NIJE_
	// Insert code here to initialize your application
   
   CGFloat  menuBarHeight = NSStatusBar.systemStatusBar.thickness;
   NSRect   availableFrame = [NSScreen mainScreen].visibleFrame;
   
   availableFrame.origin.y += menuBarHeight;
   availableFrame.size.height -= menuBarHeight;
      
   NSLog (@"Menu bar height: %.0f", menuBarHeight);
   NSLog (@"Screen Frame orig: %@", NSStringFromRect (availableFrame));
   NSLog (@"Screen Frame normal: %@", NSStringFromRect (id_CocoaRect(nil, availableFrame)));
   
   
   NSRect  winFrame = NSMakeRect (100, 64, 640, 360);
   
   self.window = [[[NSWindow alloc] initWithContentRect:id_CocoaRect(nil, winFrame)
                                               styleMask:NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
                                                 backing:NSBackingStoreBuffered
                                                   defer:NO] autorelease];
   CGRect  viewFrame = { { 0, 0 }, { winFrame.size.width, winFrame.size.height } };
   // viewFrame.size = winFrame.size;

   NSView  *view = [[DTBackView alloc] initWithFrame:viewFrame];
   
   [self.window setContentView:view];
   
   [self.window setTitle:@"Bouquet"];
   
   [self.window setBackgroundColor:[NSColor windowBackgroundColor]];
   [self.window makeKeyAndOrderFront:NSApp];
#endif
   
   self.window = [MainLoop openInitialWindowAsForm:&theMainForm];
   
   self.firstFormHandler = [[FirstForm alloc] initWithWindow:self.window];
   
   [self.firstFormHandler performSelector:@selector(runMainLoop) withObject:nil afterDelay:.1];
   
   // [view release];
}

- (void)didFuckinPopUp:(id)sender
{
   NSMenuItem  *mi = (NSMenuItem *)sender;
   
   NSString  *msg = [NSString stringWithFormat:@"didFuckingPopUp:  %@", mi.title];
   
   NSLog (@"Message: %@", msg);
}

@end
