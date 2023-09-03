//
//  NiblesTestAppDelegate.m
//  NiblesTest
//
//  Created by me on 16.08.23.
//  Copyright 2023 Delovski d.o.o. All rights reserved.
//

#import "WindowFactory.h"
#import "MainLoop.h"

@implementation WindowFactory

@synthesize  window;

// TO DO!
// Well, this windowFactory should be allecated for each window
// as it has KVO for a window so one instance can't observe all the windows out there


- (id)initWithWindow:(NSWindow *)aWindow;  // Should I have this for each window and why? dont need this property
{
   if (self = [super init])  {
      self.window = aWindow;
      // self.menuDict = [NSMutableDictionary dictionary];
      
      [aWindow addObserver:self
                forKeyPath:@"firstResponder"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
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
   
	[win setAcceptsMouseMovedEvents: YES];

   if (wTitle)
      [win setTitle:wTitle];
   [win makeKeyAndOrderFront:self];  // NSApp or me?
   
   return (win);
}

- (void)dealloc
{
   [window removeObserver:self forKeyPath:@"firstResponder"];

   [window release];
   
   [super dealloc];
}

#pragma mark -

- (BOOL)handleCurrentFieldChange:(NSTextField *)textField
{
   FORM_REC  *form = id_FindForm (textField.window);
   
   if (form)  {
      form->cur_fldno = textField.tag - 1;
      NSLog (@"Current field: %hd", form->cur_fldno);
      
      if ((textField != form->leftField) && (form->prev_cur_fldno == form->leftField.tag - 1))  {
         if ([form->leftField.stringValue isEqual:@"NoExit"])
            [form->leftField becomeFirstResponder];
      }
   }
   
   return (YES);
}

- (void)handleFirstResponderChange:(NSResponder *)newFirstResponder
{
   if ([newFirstResponder isKindOfClass:[NSTextView class]]) {
      NSTextView  *textView = (NSTextView *)newFirstResponder;
      if ([textView.delegate isKindOfClass:[NSTextField class]])  {
         NSTextField  *textField = (NSTextField *)textView.delegate;
         
         NSLog (@"NSTextField gained input focus");
         WindowFactory  *wf = (WindowFactory *)textField.delegate;
         
         [wf handleCurrentFieldChange:textField];
      }
   }
}

// KVO callback method
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
   // if (change)
   //    NSLog (@"observeValueForKeyPath: change: %@", change);

   if ([keyPath isEqualToString:@"firstResponder"])  {
      NSResponder  *firstResponder = self.window.firstResponder;
      
      if ([firstResponder isKindOfClass:[NSTextField class]]) {
         NSTextField  *field = (NSTextField *)firstResponder;
         NSLog (@"WUHU! NSTextField gained input focus: %@", field.stringValue);
      }
      else  if ([firstResponder isKindOfClass:[NSTextView class]]) {
         NSTextView  *textView = (NSTextView *)firstResponder;
         /*if ([textView.delegate isKindOfClass:[NSTextField class]]) {
            NSLog(@"NSTextField gained input focus");
         }
         else  {
            NSLog (@"observeValueForKeyPath: delegate: %@ %@", textView.delegate, [textView.delegate class]);
         }*/
         /*if ([textView.nextResponder isKindOfClass:[NSTextField class]]) {
            NSLog(@"NSTextField gained input focus");
         }
         else  {
            NSLog (@"observeValueForKeyPath: nextResponder: %@ %@", textView.nextResponder, [textView.nextResponder class]);
         }*/
         // At this point delegate is nil
         [self performSelector:@selector(handleFirstResponderChange:)
                    withObject:textView
                    afterDelay:.001]; // Adjust delay as needed         
      }
      else
         NSLog (@"observeValueForKeyPath: %@ %@", firstResponder, [firstResponder class]);
   }
}

#pragma mark -

extern  FORM_REC  *dtRenderedForm;

- (BOOL)windowShouldClose:(id)sender
{
   NSWindow  *aWindow = (NSWindow *)sender;
   
   NSLog (@"windowShouldClose: %@ %d", aWindow.title, (int)aWindow.windowNumber);
   
   if (![aWindow isDocumentEdited])
      return (YES);
   
   return (NO);
}

- (void)windowWillClose:(NSNotification *)notification;
{
   NSWindow  *aWindow = (NSWindow *)[notification object];
   FORM_REC  *form = id_FindForm (aWindow);
   
   if (form == dtRenderedForm)  {
      id_release_form (form);
   }
   
   NSLog (@"windowWillClose: %@ %d", aWindow.title, (int)aWindow.windowNumber);
}

#pragma mark -

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

- (void)setFieldEditor:(NSText *)fieldEditor
{
   NSLog (@"setFieldEditor: %@", fieldEditor.string);
}

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor;
{
   NSTextField  *textField = (NSTextField *)control;
   NSEvent      *event = [NSApp currentEvent];

   NSLog (@"control:textShouldBeginEditing = '%@' -> '%@' / '%@'",
          (event.type == NSKeyDown) ? event.characters : @"º",
          [textField stringValue], fieldEditor.string);

   return (YES);
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor;
{
   NSLog (@"control:textShouldBeginEditing: %@", fieldEditor.string);
   
   return (YES);
}

- (BOOL)     control:(NSControl *)control
            textView:(NSTextView *)textView
 doCommandBySelector:(SEL)commandSelector
{
   BOOL  result = NO;

   if ([control isKindOfClass:[NSTextField class]])
      NSLog (@"control:textView:doCommandBySelector: [NSTextField]");
      
   if (commandSelector == @selector(insertNewline:))  {
      //Do something against ENTER key
      NSLog (@"control:textView:doCommandBySelector: insertNewline");
      [textView insertNewlineIgnoringFieldEditor:self];  // or self
      result = YES;
   }
   else if (commandSelector == @selector(deleteForward:))  {
      //Do something against DELETE key
      NSLog (@"control:textView:doCommandBySelector: deleteForward");
   }
   else if (commandSelector == @selector(deleteBackward:))  {
      //Do something against BACKSPACE key
      NSLog (@"control:textView:doCommandBySelector: deleteBackward");
   }
   else if (commandSelector == @selector(insertTab:))  {
      //Do something against TAB key
      NSLog (@"control:textView:doCommandBySelector: insertTab");
   }
   
   return (result);
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
}

/*---------------------------------------------------------------------------*/

- (void)textDidBeginEditing:(NSNotification *)obj
{
   NSLog (@"textDidBeginEditing:");
}

/*---------------------------------------------------------------------------*/

- (void)textDidEndEditing:(NSNotification*)notification
{
   NSLog (@"textDidEndEditing:");
}

#pragma mark -

- (void)controlTextDidChange:(NSNotification *)notification
{
   NSTextField  *textField = [notification object];
   
   NSEvent  *event = [NSApp currentEvent];
   
   NSLog (@"controlTextDidChange: stringValue = '%@' -> '%@'",
          (event.type == NSKeyDown) ? event.characters : @"º",
          [textField stringValue]);
   
   NSCharacterSet  *charSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzŠĐČĆŽšđčćž#$%&?*\n "];
   
   unichar  *stringResult = malloc ([textField.stringValue length] * sizeof(unichar) + 1);
   
   int    cpt = 0;
   
   for (int i = 0; i < [textField.stringValue length]; i++) {
      unichar c = [textField.stringValue characterAtIndex:i];
      if ([charSet characterIsMember:c]) {
         stringResult[cpt]=c;
         cpt++;
      }
   }
   stringResult[cpt]='\0';
   
   textField.stringValue = [NSString stringWithCharacters:stringResult length:cpt];
   
   free (stringResult);
   
   [textField.window setDocumentEdited:YES];
}

- (void)controlTextDidBeginEditing:(NSNotification *)notification;
{
   NSTextField  *textField = [notification object];
   
   NSLog (@"controlTextDidBeginEditing: stringValue = '%@'", [textField stringValue]);
   
   // [control setFieldEditor:]
}

- (void)controlTextDidEndEditing:(NSNotification *)notification;
{
   NSTextField  *textField = [notification object];
   
   NSLog (@"controlTextDidEndEditing: stringValue = '%@'", [textField stringValue]);
   
   if ([self isTextFieldInFocus:textField])  {
      FORM_REC  *form = id_FindForm (textField.window);
      
      if (form && (form->cur_fldno == textField.tag - 1))
         form->prev_cur_fldno = textField.tag - 1;
   }
}

#pragma mark -

- (BOOL)isTextFieldInFocus:(NSTextField *)textField
{
	BOOL inFocus = NO;
	
	inFocus = ([[[textField window] firstResponder] isKindOfClass:[NSTextView class]]
              && [[textField window] fieldEditor:NO forObject:nil]!=nil
              && [textField isEqualTo:(id)[(NSTextView *)[[textField window] firstResponder]delegate]]);
	
	return inFocus;
}

#ifdef _NIJE_
- (void)textFieldDidBeginEditing:(NSNotification *)notification;
{
   NSTextField  *textField = [notification object];
   
   NSLog (@"textFieldDidBeginEditing: stringValue = '%@'", [textField stringValue]);
}
#endif

@end
