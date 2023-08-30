//
//  NiblesTestAppDelegate.h
//  NiblesTest
//
//  Created by me on 16.08.23.
//  Copyright (c) 2023 Delovski d.o.o. All rights reserved.
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
