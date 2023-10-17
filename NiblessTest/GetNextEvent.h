//
//  GetNextEvent.h
//  NiblessTest
//
//  Created by me on 09.07.23.
//  Copyright 2023 Delovski d.o.o. All rights reserved.
//

// #import <Cocoa/Cocoa.h>
#import  <Carbon/Carbon.h>
#import  <AppKit/AppKit.h>

#import  "transitionHeader.h"

@interface GetNextEvent : NSObject
{
}

@end


// #pragma options align=mac68k


#pragma mark -

// -------------------

BOOL  id_CoreGetNextEvent (EventRecord *evtRec, NSDate *expiration);
BOOL  id_GetNextEvent (EventRecord *evtRec, long timeout);

int   id_IsMenuEvent (EventRecord *myEvent, short partWind, short *theMenu, short *theItem);

NSPoint  id_LocationInWindow2Global (NSWindow *window, NSPoint locationInWindow);  // Origin is upperLeft corner
NSPoint  id_GlobalLocation2Window (NSWindow *window, NSPoint point);

void  id_GlobalToLocal (FORM_REC *form, Point *pt);
void  id_LocalToGlobal (FORM_REC *form, Point *pt);

Rect *id_LocalToGlobalRect (Rect *rect, NSWindow *window);
Rect *id_GlobalToLocalRect (Rect *rect, NSWindow *window);
int   id_RectInRect (Rect *aRect, Rect *mainRect);

NSEvent  *id_mouseEventForWindowFromEvent (NSEvent *event, NSWindow *modalWindow);

// -------------------

EventRecord  *id_GetFreeEventRecord (void);
EventRecord  *id_GetUsedEventRecord (void);

int  id_EventRecordScarcity (void);
int  id_AvailableUsedEvent (short eventMask, FORM_REC *form);
void id_FlushUsedEvents (FORM_REC *form);
void id_FlushParentActivations (FORM_REC *form);

void id_PostMenuEvent (short theMenu, short theItem);

void id_BuildKeyDownEvent (FORM_REC *form, short charCode, short keyCode, short modifiers, EventRef evtRef);
void id_BuildCloseWindowEvent (FORM_REC *form, EventRef evtRef);
void id_BuildActivateEvent (FORM_REC *form, short fActive);
void id_RemoveFutureActivateEvent (NSWindow *winPtr, short actFlag);


Boolean id_RunningOnClassic (void);
Boolean id_RunningOnMacOS9 (void);
Boolean id_RunningOnMacOSX (void);
Boolean id_RunningOnMacIntel (void);
Boolean id_RunningOnWindowsNT (void);
Boolean id_RunningOnWin32 (void);
Boolean id_RunningOnIntel (void);
Boolean id_RunningOnIOS (void);
