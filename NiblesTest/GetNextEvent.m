//
//  GeneralCocoaProjectAppDelegate.m
//  GeneralCocoaProject
//
//  Created by me on 09.07.23.
//  Copyright 2023 Delovski d.o.o. All rights reserved.
//

//  WindowPtr is 64bit, evt->message is 32bit so I need to put windowNumber in there on Cocoa
//  ... and a function like winPtr = EvtMsg2WindowPtr(evt->message)

#import "GetNextEvent.h"

static BOOL  id_handleRightMouse (NSEvent *event);

@implementation GetNextEvent

@end

BOOL  id_CoreGetNextEvent (EventRecord *evtRec, NSDate *expiration)
{
   BOOL  dontSendEvent = NO;
   
   evtRec->what = 0;
   
   NSEvent  *event = [NSApp nextEventMatchingMask:NSAnyEventMask
                                        untilDate:expiration
                                           inMode:NSDefaultRunLoopMode
                                          dequeue:YES];
   
   if (!event)
      return (NO);

   if (event.type == NSKeyDown)  {
      evtRec->what = keyDown;
      evtRec->message = event.keyCode;
      NSLog (@"Keys: %@", event.characters);
      evtRec->message = [event.characters characterAtIndex:0];
   }
   else  if (event.type == NSLeftMouseDown)  {
      evtRec->what = mouseDown;
      NSLog (@"Mouse: %@, %@ (%.0f, %.0f)",
             event.window, event.window? event.window.title : @"#",
             event.locationInWindow.x, event.locationInWindow.x);
      if (event.window)  {
         NSView *subview = [event.window.contentView hitTest:event.locationInWindow];
         if (subview && [subview isKindOfClass:[NSControl class]])
            NSLog (@"We hit something");
      }
   }
   else  if (event.type == NSRightMouseDown)  {
      evtRec->what = mouseDown;
      if (id_handleRightMouse(event))
         dontSendEvent = YES;
   }
      
   // Pass events down to AppDelegate to be handled in sendEvent:
   
   if (!dontSendEvent)
      [NSApp sendEvent:event];

   return (YES);
}

BOOL  id_GetNextEvent (EventRecord *evtRec, long timeout)
{
   // @autoreleasepool  {

      if (timeout > 0L)  {
         NSDate  *limitDate = [NSDate dateWithTimeIntervalSinceNow:(double)timeout / 1000.0];

         return (id_CoreGetNextEvent(evtRec, limitDate));
      }
      else
         return (id_CoreGetNextEvent(evtRec, [NSDate distantFuture]));
   // }
}

static BOOL  id_handleRightMouse (NSEvent *event)
{
   NSWindow  *frontWindow = [NSApp keyWindow];
   NSPoint    windowLocation = [event locationInWindow];
   NSPoint    location = [[frontWindow contentView] convertPoint:windowLocation fromView:nil/*frontWindow.contentView*/];
   
   if (frontWindow)  {
      NSMenuItem    *newItem;
      NSMenu        *newMenu;
      CGRect         bounds = [frontWindow.contentView bounds];
      // NSEnumerator  *enumerator = nil;
      // NSMenu        *mainMenu = [NSApp mainMenu];
      
      NSLog (@"loc: (%f, %f),  wloc: (%f, %f)", location.x, location.y, windowLocation.x, windowLocation.y);

      if (CGRectContainsPoint(bounds, location))  {
      
         newMenu = [[NSMenu alloc] initWithTitle:@"PopUp"/*gNewMenuName*/];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
         newItem = [[NSMenuItem alloc] initWithTitle:@"PopUp Numero Uno"
                                              action:@selector(didFuckinPopUp:) keyEquivalent:@""];  // If you send nil as hotKey then Trump becomes the president again
         
         [newItem setTarget:[NSApp delegate]];
         [newMenu addItem:newItem];
         newItem = [[NSMenuItem alloc] initWithTitle:@"PopUp Numero Dva"
                                              action:@selector(didFuckinPopUp:) keyEquivalent:@""];  // If you send nil as hotKey then Trump becomes the president again
#pragma clang diagnostic pop
         
         [newItem setTarget:[NSApp delegate]];
         newItem.state = YES;
         [newMenu addItem:newItem];
         
         NSView  *winView = frontWindow.contentView;
         CGFloat  halfHeight = (newMenu.size.height / newMenu.numberOfItems) / 2;
         
         if (location.y < winView.frame.size.height - halfHeight)
            location.y += halfHeight;
            
         // if (windowLocation.y > 20)
         //    windowLocation.y -= 20;
      
         [newMenu popUpMenuPositioningItem:newItem
                                atLocation:location
                                    inView:frontWindow.contentView]; // If view is nil, the location is interpreted in the screen coordinate system
         
         return (YES);
      }
   }
   
   return (NO);
}

/* .................................................................................. */
/* ................................................ Internal Events Handling ........ */
/* .................................................................................. */

// Assumes FIFO, if that's not OK, compare evt->when...

EventRecord  *id_GetFreeEventRecord (void)
{
   short  i;
   
   // Goeas backwards...
   
   for (i=kEVENTS_STACK-1; i>=0; i--)  {
      if (!dtGData->eventsUsed[i])  {
         if (!i || dtGData->eventsUsed[i-1])  {
            dtGData->eventsUsed[i] = TRUE;
            id_SetBlockToZeros (&dtGData->eventRecord[i], sizeof(EventRecord));
            return (&dtGData->eventRecord[i]);
         }
      }
   }
   
   // NSLog (@"Too many Events!");
   id_stop_emsg ("Too many Events!");
   
   return (NULL);
}

EventRecord *id_GetUsedEventRecord (void)
{
   short  i;
   
   for (i=0; i<kEVENTS_STACK; i++)  {
      if (dtGData->eventsUsed[i])  {
         dtGData->eventsUsed[i] = FALSE;
         return (&dtGData->eventRecord[i]);
      }
   }
   
   return (NULL);
}

int  id_EventRecordScarcity (void)
{
   short  i, eventsCount = 0;
   
   for (i=0; i<kEVENTS_STACK; i++)  {
      if (dtGData->eventsUsed[i])  {
         eventsCount++;
      }
   }
   
   return (eventsCount < (kEVENTS_STACK/2) ? FALSE : TRUE);
}

#ifdef  _NOT_YET_

int  id_AvailableUsedEvent (short eventMask, FORM_REC *form)
{
   short  i;
   
   for (i=0; i<kEVENTS_STACK; i++)  {
      if (dtGData->eventsUsed[i])  {
         if ((eventMask & activMask) && dtGData->eventRecord[i].what == activateEvt)  {
            if (!form || dtGData->eventRecord[i].nswindow == form->my_window)
               return (TRUE);
         }
         if ((eventMask & updateMask) && dtGData->eventRecord[i].what == updateEvt)  {
            if (!form || dtGData->eventRecord[i].nswindow == form->my_window)
               return (TRUE);
         }
      }
   }
   
   return (FALSE);
}

void  id_FlushUsedEvents (FORM_REC *form)
{
   short  i;
   // char   tmpStr[256], msgStr[256];
   
   for (i=0; i<kEVENTS_STACK; i++)  {
      if (dtGData->eventsUsed[i] &&
          dtGData->eventRecord[i].what != nullEvent &&
          dtGData->eventRecord[i].what != activateEvt &&
          dtGData->eventRecord[i].what != updateEvt)  {
#ifdef _MAYBE_
         id_PrintUsedEvent (NULL, i, tmpStr);
         sprintf (msgStr, "%s 1st > %s", "id_FlushUsedEvents", tmpStr);
         id_LogFileLineWithFormForEvt (form, msgStr);
#endif
         dtGData->eventsUsed[i] = FALSE;
      }
   }
   
   if (form && form->my_window)  {
      for (i=0; i<kEVENTS_STACK; i++)  {
         if (dtGData->eventsUsed[i] &&
             dtGData->eventRecord[i].what != nullEvent &&
             dtGData->eventRecord[i].nswindow == form->my_window)  {
#ifdef _MAYBE_
            id_PrintUsedEvent (NULL, i, tmpStr);
            sprintf (msgStr, "%s 2nd > %s", "id_FlushUsedEvents", tmpStr);
            id_LogFileLineWithFormForEvt (form, msgStr);
#endif
            dtGData->eventsUsed[i] = FALSE;
         }
      }
   }
}

void  id_FlushParentActivations (FORM_REC *form)
{
   short  i;
   // char   tmpStr[256], msgStr[256];
   
   // GetForegroundWindow() does not return just created window!
   
   if (form && form->my_window)  {
      for (i=0; i<kEVENTS_STACK; i++)  {
         if (dtGData->eventsUsed[i] &&
             dtGData->eventRecord[i].what == activateEvt &&
             dtGData->eventRecord[i].modifiers == activeFlag &&
             dtGData->eventRecord[i].nswindow == form->my_window)  {
#ifdef _MAYBE_
            id_PrintUsedEvent (NULL, i, tmpStr);
            sprintf (msgStr, "%s > %s", "id_FlushParentActivations", tmpStr);
            id_LogFileLineWithFormForEvt (form, msgStr);
#endif
            dtGData->eventsUsed[i] = FALSE;
         }
      }
   }
}
#endif  // _NOT_YET_

/*extern*/ EventRecord  gGSavedEventRecord;

void  id_BuildKeyDownEvent (
 FORM_REC *form,       // may be NULL
 short     charCode,
 short     keyCode,
 short     modifiers,
 EventRef  evtRef      // may be NULL
)
{
   long         loWord;
   EventRecord *evtPtr =  &gGSavedEventRecord; // &dtGData->eventRecord;  // id_GetFreeEventRecord()

   id_SetBlockToZeros (evtPtr, sizeof(EventRecord));
   
   if (!evtPtr)  return;   // handle this better!
   
   // evtPtr->hwnd = form->my_window;

   evtPtr->what = keyDown;
   if (evtRef)
      evtPtr->when = GetEventTime (evtRef);
   else
      evtPtr->when = TickCount ();
   
   // SetPt (&evtPtr->where, dtGData->mousePos.x, dtGData->mousePos.y);  //  Jesus!
   
   // ovo ako neke pretumbacije
   
   // switch (charCode)  {  //  Spec cases...  Jesus!  WM_KEYDOWN, ne treba za WM_CHAR
   
   //    case  190:  if (GetKeyState(VK_CONTROL) < 0)  charCode = '.';  break;
   // }
   
   loWord = (keyCode << 8) | charCode;
#ifdef _NIJE_
   
   switch (charCode)  {
      case  VK_F1:  loWord = MAKEWORD (0x10, 0x7A);  break;
      case  VK_F2:  loWord = MAKEWORD (0x10, 0x78);  break;
      case  VK_F3:  loWord = MAKEWORD (0x10, 0x63);  break;
      case  VK_F4:  loWord = MAKEWORD (0x10, 0x76);  break;

      case  VK_F5:  loWord = MAKEWORD (0x10, 0x60);  break;
      case  VK_F6:  loWord = MAKEWORD (0x10, 0x61);  break;
      case  VK_F7:  loWord = MAKEWORD (0x10, 0x62);  break;
      case  VK_F8:  loWord = MAKEWORD (0x10, 0x64);  break;
      case  VK_F9:  loWord = MAKEWORD (0x10, 0x65);  break;
      case  VK_F10: loWord = MAKEWORD (0x10, 0x6D);  break;
      case  VK_F11: loWord = MAKEWORD (0x10, 0x67);  break;
      case  VK_F12: loWord = MAKEWORD (0x10, 0x6F);  break;
   }
#endif

   evtPtr->message = (loWord << 16) | loWord;  // lo-hi ?!
      
   evtPtr->modifiers = modifiers;
}
