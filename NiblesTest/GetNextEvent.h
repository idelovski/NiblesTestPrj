//
//  GetNextEvent.h
//  GeneralCocoaProject
//
//  Created by me on 09.07.23.
//  Copyright 2023 Delovski d.o.o. All rights reserved.
//

// #import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <AppKit/AppKit.h>

#import "transitionHeader.h"

@interface GetNextEvent : NSObject
{
}

@end


// #pragma options align=mac68k


#pragma mark -

// -------------------

BOOL  id_CoreGetNextEvent (EventRecord *evtRec, NSDate *expiration);
BOOL  id_GetNextEvent (EventRecord *evtRec, long timeout);

// -------------------

EventRecord  *id_GetFreeEventRecord (void);
