#import "WindowFactory.h"

@implementation WindowFactory

@synthesize  window;

/*
- (IBAction)createWindowFromNib:(id)sender
{
   // Note: This leaks.
   controller = [[NSWindowController alloc] initWithWindowNibName: @"Window"];
   [controller showWindow: self];
}
*/

- (id)initWithWindow:(NSWindow *)aWindow;  // Should I have this for each window and why? dont need this property
{
   if (self = [super init])  {
      self.window = aWindow;
   }
   
   return (self);
}

+ (NSWindow *)createWindowWithRect:(CGRect)wFrame
                         withTitle:(NSString *)wTitle
{
   NSUInteger  style = NSClosableWindowMask | NSMiniaturizableWindowMask;
   
   if (wTitle)
      style |= NSTitledWindowMask;

   // if ([isTextured state] == NSOnState)
      style |= NSTexturedBackgroundWindowMask;

   // NSRect frame = [[sender window] frame];
   
   // frame.origin.x += (((double)random()) / LONG_MAX) * 200;
   // frame.origin.y += (((double)random()) / LONG_MAX) * 200;
   
   NSWindow  *win = [[NSWindow alloc] initWithContentRect:wFrame
                                                styleMask:style
                                                  backing:NSBackingStoreBuffered
                                                    defer:NO];
   [win setOpaque:YES];  // Default is NO
   [win setAlphaValue:1.];
   
   [win setHasShadow:NSOnState];
   
   if (wTitle)
      [win setTitle:wTitle];
   [win makeKeyAndOrderFront:self];  // NSApp or me?
   
   return (win);
}

- (void)dealloc
{
   [controller release];
   
   [super dealloc];
}

#pragma mark -

- (BOOL)windowShouldClose:(id)sender
{
   NSWindow  *aWindow = (NSWindow *)sender;
   
   NSLog (@"windowShouldClose: %@ %d", aWindow.title, (int)aWindow.windowNumber);
   
   return (NO);
}

- (void)windowDidExpose:(NSNotification *)aNotification
{
   NSLog (@"windowDidExpose:");
}

- (void)windowWillMove:(NSNotification *)aNotification
{
   NSLog (@"windowWillMove:");
}

- (void)windowDidMove:(NSNotification *)aNotification
{
   NSLog (@"windowDidMove:");
}

- (void)windowDidResize:(NSNotification *)aNotification
{
   NSLog (@"windowDidResize:");
}

- (void)windowDidMiniaturize:(NSNotification *)aNotification
{
   NSLog (@"windowDidMiniaturize:");
}

- (void)windowDidDeminiaturize:(NSNotification *)aNotification
{
   NSLog (@"windowDidDeminiaturize:");
}

- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
   NSLog (@"windowDidBecomeKey:");

}

- (void)windowDidResignKey:(NSNotification *)aNotification
{
   NSLog (@"windowDidResignKey:");
}

- (void)windowDidChangeBackingProperties:(NSNotification *)aNotification
{
   NSLog (@"windowDidChangeBackingProperties:");
}

- (void)windowDidChangeScreenProfile:(NSNotification *)aNotification
{
   NSLog (@"windowDidChangeScreenProfile:");
}

- (void)windowWillEnterFullScreen:(NSNotification *)aNotification
{
   NSLog (@"windowWillEnterFullScreen:");
}

- (void)windowDidFailToEnterFullScreen:(NSNotification *)aNotification
{
   NSLog (@"windowDidFailToEnterFullScreen:");
}

- (void)windowWillExitFullScreen:(NSNotification *)aNotification
{
   NSLog (@"windowWillExitFullScreen:");
}

- (void)windowDidFailToExitFullScreen:(NSNotification *)aNotification
{
   NSLog (@"windowDidFailToExitFullScreen:");
}

- (void)windowDidExitFullScreen:(NSNotification *)aNotification
{
   NSLog (@"windowDidExitFullScreen:");
}

#pragma mark -

- (void)keyDown:(NSEvent *)theEvent
{
   NSLog (@"keyDown:");
}
- (void)keyUp:(NSEvent *)theEvent
{
   NSLog (@"keyUp:");
}

- (BOOL)processHitTest:(NSEvent *)theEvent
{
   NSLog (@"processHitTest:");

   return (NO);  /* not a special area, carry on. */
}

- (void)mouseDown:(NSEvent *)theEvent
{
   NSLog (@"mouseDown:");
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
   NSLog (@"rightMouseDown:");

   [self mouseDown:theEvent];
}

- (void)otherMouseDown:(NSEvent *)theEvent
{
   NSLog (@"otherMouseDown:");
   
   [self mouseDown:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
   NSLog (@"mouseUp:");
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
   NSLog (@"rightMouseUp:");

   [self mouseUp:theEvent];
}

- (void)otherMouseUp:(NSEvent *)theEvent
{
   NSLog (@"otherMouseUp:");

   [self mouseUp:theEvent];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
   NSLog (@"mouseMoved:");
}

- (void)mouseDragged:(NSEvent *)theEvent;
{
   NSLog (@"mouseDragged:");

   [self mouseMoved:theEvent];
}

- (void)rightMouseDragged:(NSEvent *)theEvent
{
   NSLog (@"rightMouseDragged:");

   [self mouseMoved:theEvent];
}

- (void)otherMouseDragged:(NSEvent *)theEvent
{
   NSLog (@"otherMouseDragged:");

   [self mouseMoved:theEvent];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
   NSLog (@"scrollWheel:");
}

- (void)touchesBeganWithEvent:(NSEvent *)theEvent
{
   NSLog (@"touchesBeganWithEvent:");
}

- (void)touchesMovedWithEvent:(NSEvent *)theEvent
{
   NSLog (@"touchesMovedWithEvent:");
   
   [self handleTouches:NSTouchPhaseMoved withEvent:theEvent];
}

- (void)touchesEndedWithEvent:(NSEvent *)theEvent
{
   NSLog (@"touchesEndedWithEvent:");

   [self handleTouches:NSTouchPhaseEnded withEvent:theEvent];
}

- (void)touchesCancelledWithEvent:(NSEvent *)theEvent
{
   NSLog (@"touchesCancelledWithEvent:");

   [self handleTouches:NSTouchPhaseCancelled withEvent:theEvent];
}

- (void)handleTouches:(NSTouchPhase)phase withEvent:(NSEvent *)theEvent
{
   NSLog (@"touchesCancelledWithEvent:");

   // NSSet *touches = [theEvent touchesMatchingPhase:phase inView:nil];
}

#pragma mark -

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor;
{
   NSLog (@"control:textShouldBeginEditing: %@", fieldEditor.string);
      
   return (YES);
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor;
{
   NSLog (@"control:textShouldBeginEditing: %@", fieldEditor.string);
   
   return (YES);
}

- (BOOL)     control:(NSControl *)control
            textView:(NSTextView *)textView
 doCommandBySelector:(SEL)command
{
   NSLog (@"control:textView:doCommandBySelector:");
   
   return (YES);
}

#pragma mark -

- (BOOL)textShouldBeginEditing:(NSText *)textObject;
{
   NSLog (@"textShouldBeginEditing:");
   
   return (YES);
}

- (BOOL)textShouldEndEditing:(NSText *)textObject;
{
   NSLog (@"textShouldEndEditing:");

   return (YES);
}

- (void)textDidChange:(NSNotification*)notification
{
   NSLog (@"textDidChange:");
#ifdef _NIJE_
   unref(notification);
   if ([self isEnabled] == YES && self->OnFilter != NULL)
   {
      EvText params;
      EvTextFilter result;
      NSText *text = NULL;
      params.text = (const char_t*)[[self stringValue] UTF8String];
      text = [[self window] fieldEditor:YES forObject:self];
      params.cpos = (uint32_t)[text selectedRange].location;
      result.apply = FALSE;
      result.text[0] = '\0';
      result.cpos = UINT32_MAX;
      listener_event(self->OnFilter, ekEVTXTFILTER, (OSEdit*)self, &params, &result, OSEdit, EvText, EvTextFilter);
      
      if (result.apply == TRUE)
         _oscontrol_set_text(self, &self->attrs, result.text);
      
      if (result.cpos != UINT32_MAX)
         [text setSelectedRange:NSMakeRange((NSUInteger)result.cpos, 0)];
      else
         [text setSelectedRange:NSMakeRange((NSUInteger)params.cpos, 0)];
   }
#endif
}

/*---------------------------------------------------------------------------*/

- (void)textDidBeginEditing:(NSNotification *)obj
{
   NSLog (@"textDidBeginEditing:");
#ifdef _NIJE_
   unref(obj);
   if (BIT_TEST(self->flags, ekEDAUTOSEL) == TRUE)
       [[self currentEditor] selectAll:nil];
#endif
}

/*---------------------------------------------------------------------------*/

- (void)textDidEndEditing:(NSNotification*)notification
{
   NSLog (@"textDidEndEditing:");
#ifdef _NIJE_
   unref(notification);
   if ([self isEnabled] == YES && self->OnChange != NULL
       && _oswindow_in_destroy([self window]) == NO)
   {
      EvText params;
      params.text = (const char_t*)[[self stringValue] UTF8String];
      listener_event(self->OnChange, ekEVTXTCHANGE, (OSEdit*)self, &params, NULL, OSEdit, EvText, void);
   }
   
   [[self window] endEditingFor:nil];
   
   if (self->OnFocus != NULL)
   {
      bool_t params = FALSE;
      listener_event(self->OnFocus, ekEVFOCUS, (OSEdit*)self, &params, NULL, OSEdit, bool_t, void);
   }
   
   {
      unsigned int whyEnd = [[[notification userInfo] objectForKey:@"NSTextMovement"] unsignedIntValue];
      NSView *nextView = nil;
      
      if (whyEnd == NSReturnTextMovement)
      {
         [[self window] keyDown:(NSEvent*)231];
         nextView = self;
      }        
      else if (whyEnd == NSTabTextMovement)
      {
         nextView = [self nextValidKeyView];
      }
      else if (whyEnd == NSBacktabTextMovement)
      {
         nextView = [self previousValidKeyView];
      }
      
      if (nextView != nil)
         [[self window] makeFirstResponder:nextView];
   }
#endif
}

#pragma mark -

- (void)controlTextDidChange:(NSNotification *)notification
{
   NSTextField  *textField = [notification object];

   NSLog (@"controlTextDidChange: stringValue = '%@'", [textField stringValue]);
   
   NSCharacterSet  *charSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFabcdf"];
   
   char  *stringResult = malloc ([textField.stringValue length]);
   
   int    cpt = 0;
   
   for (int i = 0; i < [textField.stringValue length]; i++) {
      unichar c = [textField.stringValue characterAtIndex:i];
      if ([charSet characterIsMember:c]) {
         stringResult[cpt]=c;
         cpt++;
      }
   }
   stringResult[cpt]='\0';
   
   textField.stringValue = [NSString stringWithUTF8String:stringResult];
   
   free (stringResult);
}

- (void)controlTextDidBeginEditing:(NSNotification *)notification;
{
   NSTextField  *textField = [notification object];
   
   NSLog (@"controlTextDidBeginEditing: stringValue = '%@'", [textField stringValue]);
}

- (void)controlTextDidEndEditing:(NSNotification *)notification;
{
   NSTextField  *textField = [notification object];
   
   NSLog (@"controlTextDidEndEditing: stringValue = '%@'", [textField stringValue]);
}

@end
