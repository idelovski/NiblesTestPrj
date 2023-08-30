//
//  NiblesTestAppDelegate.h
//  NiblesTest
//
//  Created by Sophie Marceau on 16.08.23.
//  Copyright 2023 __MyCompanyName__. All rights reserved.
//

#import  <Cocoa/Cocoa.h>

#import  "WindowFactory.h"
#import  "FirstForm.h"
#import  "MainLoop.h"

@interface NiblesTestAppDelegate : NSObject <NSApplicationDelegate> {
//     NSWindow  *window;
}

@property (nonatomic, retain)  NSWindow   *window;
@property (nonatomic, retain)  FirstForm  *firstFormHandler;

@property (nonatomic, retain)  NSMutableDictionary  *menuDict;  // key=menu, value=menu_id

- (void)didFuckinPopUp:(id)sender;

@end
