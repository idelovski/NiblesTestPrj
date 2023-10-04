//
//  GetNextEvent.m
//  NiblessTest
//
//  Created by me on 09.07.23.
//  Copyright 2023 Delovski d.o.o. All rights reserved.
//

// There is -runModalSession:
// Typically, you use this method in situations where you want to do some additional processing on the current thread while the modal loop runs. For example, while processing a large data set, you might want to use a modal dialog to display progress and give the user a chance to cancel the operation.

// Subclass of NSWindow can have -worksWhenModal
// The value of this property is YES if the window is able to receive keyboard and mouse events even when some other window is being run modally; otherwise, NO. By default, the NSWindow value of this property is NO. Only subclasses of NSPanel should override this default.

// updateEvt may be even just an info set after drawRect call so the outer code knows it happened,
// I don't think it's needed before but if it's possible I wouldn't mind

// Or maybe monitor needsDisplay property?

#import  "GetNextEvent.h"

#import  "MainLoop.h"

static BOOL  id_handleRightMouse (NSEvent *event);
static BOOL  id_TextFieldsHitTest (NSWindow *window, NSPoint locationInWindow, short *retIndex);

// /*extern*/ EventRecord  gGSavedEventRecord = { 0 };

@implementation GetNextEvent

@end

BOOL  id_CoreGetNextEvent (EventRecord *evtRec, NSDate *expiration)
{
   BOOL  dontSendEvent = NO;
   
   id_SetBlockToZeros (evtRec, sizeof(EventRecord));
   
   NSEvent  *event = [NSApp nextEventMatchingMask:NSAnyEventMask
                                        untilDate:expiration
                                           inMode:NSDefaultRunLoopMode
                                          dequeue:YES];
   
   if (!event)  {
      EventRecord  *dtEvtPtr = id_GetUsedEventRecord ();  // &dtGData->eventRecord;

      if (dtEvtPtr && dtEvtPtr->what)  {
         BlockMove (dtEvtPtr, evtRec, sizeof(EventRecord));
         id_SetBlockToZeros (dtEvtPtr, sizeof(EventRecord));
         
         return (YES);
      }

      return (NO);
   }

   if (event.type == NSKeyDown)  {  // see NSUndoFunctionKey etc.
      char  ch;
      
      evtRec->what = keyDown;
      evtRec->message = event.keyCode;
      if (event.modifierFlags)  {
         if (event.modifierFlags & NSAlternateKeyMask)
            evtRec->modifiers |= optionKey;
         if (event.modifierFlags & NSShiftKeyMask)
            evtRec->modifiers |= shiftKey;
         if (event.modifierFlags & NSControlKeyMask)
            evtRec->modifiers |= controlKey;
         if (event.modifierFlags & NSCommandKeyMask)
            evtRec->modifiers |= cmdKey;
      }
      
      NSLog (@"Key: (code:%d)[%d] - '%@' / '%@'",
             (int)event.keyCode, (int)event.characters.length, event.characters, event.charactersIgnoringModifiers);
      
      // if (!id_UniCharToChar([event.charactersIgnoringModifiers characterAtIndex:0], &ch))
      //    evtRec->message = (unsigned char)ch;
      if (!id_UniCharToChar([event.characters characterAtIndex:0], &ch))
         evtRec->message = (unsigned char)ch;
      if ((evtRec->message == '\t') || (evtRec->message == 25))  {  // Well, yes, Shift+Tab
         evtRec->message = kTabCharCode;  // '\t';
         dontSendEvent = YES;
      }
   }
   else  if (event.type == NSLeftMouseDown)  {
      evtRec->what = mouseDown;
      evtRec->message = (unsigned long)event.window;
      
      NSPoint  globalPt = id_LocationInWindow2Global (event.window, event.locationInWindow);
      NSPoint  localPt = id_GlobalLocation2Window (event.window, globalPt);  // Just a check, not used later for anything
      
      SetPt (&evtRec->where, globalPt.x, globalPt.y);
      NSLog (@"Mouse: %@, %@ (%.0f, %.0f) (%.0f, %.0f)",
             event.window, event.window? event.window.title : @"#",
             event.locationInWindow.x, event.locationInWindow.y,
             localPt.x, localPt.y);
      if (event.window)  {
         // If modal form is in front of everything, then don't bother with the click, just activate that window
         if (dtGData->modalFormsCount)  {
            NSWindow  *frontWin = FrontWindow ();
            NSWindow  *eventWin = event.window;
            
            // Well, I'll be damned....
            
            if (eventWin != frontWin)  {
               // Maybe move newMouseEvent to the top and set it to NULL, then check if not NULL for SetPt()
               NSEvent  *newMouseEvent = id_mouseEventForWindowFromEvent (event, frontWin);
               
               globalPt = id_LocationInWindow2Global (newMouseEvent.window, newMouseEvent.locationInWindow);
               
               SetPt (&evtRec->where, globalPt.x, globalPt.y);

               [NSApp sendEvent:newMouseEvent];
               
               NSLog (@"EvtWin: %@ - FrontWin: %@", eventWin.title, frontWin.title);
               dontSendEvent = YES;
            }
         }
         if (!dontSendEvent)  {
            NSView  *subview = [event.window.contentView hitTest:event.locationInWindow];
            if (subview)  {
               if ([subview isKindOfClass:[NSTextField class]])  {
                  // Now, if we're coming back as user hits a field, the app is activated here
                  NSTextField  *fld = (NSTextField *)subview;
                  
                  NSLog (@"We hit NSTextField");
                  
                  if (event.window == FrontWindow())  {
                     // So, this will make the app active if we're coming from behind with this click...
                     // But we shouldn't send this mouseDown to the field. Instead...
                     // WELL, WELL, WELL,
                     // I need TExClick() that will receive the click if we're front window
                     // And for that, I need to save this nsevent or ... bum tss ... create a new one!
                     // Just translate the where point to locationInWindow and send it ... or I can can save this one
                     // But first, create a new one ... ha, ha, ha
                     if (![NSApp isActive])
                        [NSApp activateIgnoringOtherApps:YES];
                     else  if ([fld isEditable])  {
                        FORM_REC  *form = id_FindForm (event.window);
                        
                        if (dtGData->texEvent)
                           NSLog (@"WTF - dtGData->texEvent!!!");
                        if (!form->ditl_def)
                           [fld mouseDown:event];  // For that initial non-ditl window
                        else
                           dtGData->texEvent = [event retain];  // Plan A - retain a real event
                     }
                     dontSendEvent = YES;
                     // Add -> And if we're in the background then need to SelectWindow()!
                  }
                  else  /*if (![NSApp isActive])*/  {
                     // 1. This doesn't really work as the window behind stays behind even as our app goes to the front
                     // so I need to recreate the event with a click to some othe place and send that to NSApp
                     
                     // [NSApp activateIgnoringOtherApps:YES];
                     // SelectWindow (event.window);
                     
                     // 2. But, with a fake event I managed to do it, he, he
                     
                     FORM_REC *form = id_FindForm (event.window);
                     NSEvent  *newMouseEvent = id_mouseEventForWindowFromEvent (event, event.window);
                     
                     globalPt = id_LocationInWindow2Global (newMouseEvent.window, newMouseEvent.locationInWindow);
                     
                     SetPt (&evtRec->where, globalPt.x, globalPt.y);
                     
                     [NSApp sendEvent:newMouseEvent];
                     
                     dontSendEvent = YES;
                  }
               }
               else  if ([subview isKindOfClass:[NSControl class]])
                  NSLog (@"We hit something");
               if (id_TextFieldsHitTest(event.window, event.locationInWindow, NULL))
                  NSLog (@"We definetely hit text control");
            }
         }
      }
   }
   else  if (event.type == NSRightMouseDown)  {
      evtRec->what = mouseDown;
      if (id_handleRightMouse(event))
         dontSendEvent = YES;
   }
   else  if (event.type == NSMouseMoved)  {
      // NSLog (@"Mouse Moved!");
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

#pragma mark -

/* ........................................................... id_IsMenuEvent ....... */

// This is created via id_PostMenuEvent()

int  id_IsMenuEvent (
 EventRecord  *myEvent,
 short         partWind,  // ignored in Cocoa
 short        *theMenu,
 short        *theItem
)
{
   if ((myEvent->what == nullEvent) && dtGData->postedMenu)  {
      *theMenu = dtGData->postedMenu;
      *theItem = dtGData->postedItem;
      
      dtGData->postedMenu = 0;
      dtGData->postedItem = 0;
      
      return (TRUE);
   }

   return (FALSE);
}   

#pragma mark -

// Well, this thing converts loc in win to global coordinates where 0,0 is upper left corner
// But it probably falls apart if event location is not on the same screen as the windows screen
// there is a property screen of each window so check what happens if I move a mouse on another screen

NSPoint  id_LocationInWindow2Global (NSWindow *window, NSPoint locationInWindow)
{
   NSPoint  point;
   NSRect   windowFrame = window.frame;
   NSRect   screenFrame = [[NSScreen mainScreen] frame];
   
   point.x = windowFrame.origin.x + locationInWindow.x;
   point.y = screenFrame.size.height - (locationInWindow.y + windowFrame.origin.y);

   return (point);
}

// Global upper-left coordinates to window's local lower-left coordinates

NSPoint  id_GlobalLocation2Window (NSWindow *window, NSPoint point)
{
   NSPoint  locationInWindow;
   NSRect   windowFrame = window.frame;
   NSRect   screenFrame = [[NSScreen mainScreen] frame];
   
   locationInWindow.x = point.x - windowFrame.origin.x;
   locationInWindow.y = screenFrame.size.height - point.y - windowFrame.origin.y;
   
   return (locationInWindow);
}

// Global screen upper-left coordinates to window's local upper-left coordinates

void  id_GlobalToLocal (FORM_REC *form, Point *pt)
{
   NSPoint  point = NSMakePoint (pt->h, pt->v);
   NSPoint  locPt = id_GlobalLocation2Window (form->my_window, point);

   NSView  *contentView = [form->my_window contentView];
   CGRect   contentRect = contentView.bounds;

   locPt.y = contentRect.size.height - locPt.y;
   
   SetPt (pt, locPt.x, locPt.y);
}

// Local window's upper-left coordinates to global screen upper-left coordinates

void  id_LocalToGlobal (FORM_REC *form, Point *pt)
{
   NSView  *contentView = [form->my_window contentView];
   CGRect   contentRect = contentView.bounds;

   NSPoint  point = NSMakePoint (pt->h, contentRect.size.height - pt->v);
   NSPoint  globPt = id_LocationInWindow2Global (form->my_window, point);

   SetPt (pt, globPt.x, globPt.y);
}

#pragma mark -

NSEvent  *id_mouseEventForWindowFromEvent (NSEvent *event, NSWindow *modalWindow)
{
   // NSPoint    windowLocation = [event locationInWindow];
   // NSPoint    location = [[frontWin contentView] convertPoint:windowLocation fromView:nil/*frontWindow.contentView*/];
   
   // NSPoint  newLocation = NSMakePoint (location.x + 100.0, location.y);
   NSPoint  newLocation = NSMakePoint (1., 1.);
   
   NSEventType    eventType = event.type;
   NSUInteger     modifiers = event.modifierFlags;
   NSTimeInterval timestamp = event.timestamp;
   
   NSInteger  windowNumber = modalWindow.windowNumber;
   NSInteger  eventNumber = event.eventNumber;
   NSInteger  clickCount = event.clickCount;
   
   float  pressure = event.pressure;
   
   NSEvent  *newMouseEvent = [NSEvent mouseEventWithType:eventType
                                                location:newLocation
                                           modifierFlags:modifiers
                                               timestamp:timestamp
                                            windowNumber:windowNumber
                                                 context:nil // Pass nil for context to use global screen location
                                             eventNumber:eventNumber
                                              clickCount:clickCount
                                                pressure:pressure];
   return (newMouseEvent);
}

static BOOL  id_TextFieldsHitTest (
 NSWindow  *window,
 NSPoint    locationInWindow,
 short     *retIndex  // Optional
) 
{
   short       index;
   NSPoint     location = [[window contentView] convertPoint:locationInWindow fromView:nil/*frontWindow.contentView*/];

   FORM_REC   *form = id_FindForm (window);
   DITL_item  *f_ditl_def;
   EDIT_item  *f_edit_def;
   
   if (retIndex)
      *retIndex = -1;

   if (form && form->ditl_def)  {
      for (index=0; index<=form->last_fldno; index++)  {
         
         f_ditl_def = form->ditl_def[index];
         f_edit_def = form->edit_def[index];
         
         if (!form->ditl_def[index]->i_handle)   continue;
         
         if ((f_ditl_def->i_type & editText) || (f_ditl_def->i_type & statText))  {
            NSRect  fldRect = [(NSControl *)form->ditl_def[index]->i_handle frame];
            
            if (NSPointInRect(location, fldRect))  {
               if (retIndex)
                  *retIndex = index;
               return (YES);
            }
         }
      }
   }
   
   return (NO);
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
         
#if defined(__clang__)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#endif

         newItem = [[NSMenuItem alloc] initWithTitle:@"PopUp Numero Uno"
                                              action:@selector(didFuckinPopUp:) keyEquivalent:@""];  // If you send nil as hotKey then Trump becomes the president again
         
         [newItem setTarget:[NSApp delegate]];
         [newMenu addItem:newItem];
         newItem = [[NSMenuItem alloc] initWithTitle:@"PopUp Numero Dva"
                                              action:@selector(didFuckinPopUp:) keyEquivalent:@""];  // If you send nil as hotKey then Trump becomes the president again

#if defined(__clang__)
#pragma clang diagnostic pop
#endif
         
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

EventRecord  *id_GetUsedEventRecord (void)
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

int  id_AvailableUsedEvent (short eventMask, FORM_REC *form)
{
   short  i;
   
   for (i=0; i<kEVENTS_STACK; i++)  {
      if (dtGData->eventsUsed[i])  {
         if ((eventMask & activMask) && dtGData->eventRecord[i].what == activateEvt)  {
            if (!form || (NSWindow *)dtGData->eventRecord[i].message == form->my_window)
               return (TRUE);
         }
         if ((eventMask & updateMask) && dtGData->eventRecord[i].what == updateEvt)  {
            if (!form || (NSWindow *)dtGData->eventRecord[i].message == form->my_window)
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
             (NSWindow *)dtGData->eventRecord[i].message == form->my_window)  {
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
             (NSWindow *)dtGData->eventRecord[i].message == form->my_window)  {
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

#pragma mark -

/* ........................................................... id_PostMenuEvent ..... */

void  id_PostMenuEvent (short theMenu, short theItem)
{
   dtGData->postedMenu = theMenu;
   dtGData->postedItem = theItem;
}

#pragma mark -

void  id_BuildKeyDownEvent (
 FORM_REC *form,       // must not be NULL
 short     charCode,
 short     keyCode,
 short     modifiers,
 EventRef  evtRef      // may be NULL
)
{
   long          loWord;
   EventRecord  *evtPtr =  id_GetFreeEventRecord (); // &dtGData->eventRecord;  // id_GetFreeEventRecord()

   id_SetBlockToZeros (evtPtr, sizeof(EventRecord));
   
   if (!evtPtr)  return;   // handle this better!
   
   // evtPtr->message = (unsigned long )form->my_window;

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

// On Windows I have id_BuildCloseEvent() that uses invented closeEvent or keyDown + Esc

void  id_BuildCloseWindowEvent (  // Made up evt that I need to close the window, find one day the real position of the mouse
 FORM_REC  *form,       // must not be NULL
 EventRef   evtRef      // may be NULL
)
{
   long   loWord;
   Point  where = { 0, 0 };
   
   EventRecord  *evtPtr =  id_GetFreeEventRecord (); // &dtGData->eventRecord;  // id_GetFreeEventRecord()

   id_SetBlockToZeros (evtPtr, sizeof(EventRecord));
   
   if (!evtPtr)  return;   // handle this better!
   
   evtPtr->message = (unsigned long )form->my_window;

   evtPtr->what = mouseDown;
   if (evtRef)
      evtPtr->when = GetEventTime (evtRef);
   else
      evtPtr->when = TickCount ();
   
   evtPtr->where = where;
   
   evtPtr->modifiers = 1 << (activeFlagBit+1);  // This flag is unused by OS - hope so
}

void  id_BuildActivateEvent (FORM_REC *form, short fActive) // Why form? Send only window
{
   EventRecord  *evtPtr = id_GetFreeEventRecord (); // &dtGData->eventRecord;
   
   // id_SetBlockToZeros (evtPtr, sizeof(EventRecord));
   
   if (!evtPtr)  return;   // handle this better!
   
   // evtPtr->hwnd = form->my_window;
   
   evtPtr->what = activateEvt;
   evtPtr->when = TickCount ();
   
   // Could have used GetMessagePos() !!!
   
   SetPt (&evtPtr->where, dtGData->mousePos.x, dtGData->mousePos.y);  //  Jesus!
   
   evtPtr->message = (unsigned long)form->my_window;
      
   if (fActive)
      evtPtr->modifiers = activeFlag;
}
