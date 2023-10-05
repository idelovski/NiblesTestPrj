//
//  WindowFactory.h
//  NiblessTest
//
//  Created by me on 16.08.23.
//  Copyright 2023 Delovski d.o.o. All rights reserved.
//

#import  <Cocoa/Cocoa.h>
#import  <Carbon/Carbon.h>

#import  "transitionHeader.h"


@interface WindowFactory : NSObject
<
NSWindowDelegate,
NSTextFieldDelegate
>
{
	IBOutlet  NSButton     *isTextured;
	IBOutlet  NSButton     *isOpaque;
	IBOutlet  NSButton     *isTitled;
	IBOutlet  NSButton     *hasShadow;
	IBOutlet  NSTextField  *title;
   
   // NSWindowController  *controller;  // Why do I need this?
   NSWindow            *window;
}

@property (nonatomic, retain)  NSWindow             *window;

- (id)initWithWindow:(NSWindow *)aWindow;  // Should I have this for each window and why? dont need this property

// - (IBAction)createWindowFromNib: (id)sender;
+ (NSWindow *)createWindowWithRect:(CGRect)wFrame
                         withTitle:(NSString *)wTitle;

- (void)windowDidExitFullScreen:(NSNotification *)aNotification;

// - (void)textFieldDidBeginEditing:(NSNotification *)notification;


#pragma mark -

- (BOOL)windowShouldClose:(id)sender;
- (void)windowDidExpose:(NSNotification *)aNotification;
- (void)windowWillMove:(NSNotification *)aNotification;
- (void)windowDidMove:(NSNotification *)aNotification;
- (void)windowDidResize:(NSNotification *)aNotification;
- (void)windowDidMiniaturize:(NSNotification *)aNotification;
- (void)windowDidDeminiaturize:(NSNotification *)aNotification;

- (void)windowDidBecomeKey:(NSNotification *)aNotification;
- (void)windowDidResignKey:(NSNotification *)aNotification;
- (void)windowDidChangeBackingProperties:(NSNotification *)aNotification;
- (void)windowDidChangeScreenProfile:(NSNotification *)aNotification;
- (void)windowWillEnterFullScreen:(NSNotification *)aNotification;
- (void)windowDidFailToEnterFullScreen:(NSNotification *)aNotification;
- (void)windowWillExitFullScreen:(NSNotification *)aNotification;
- (void)windowDidFailToExitFullScreen:(NSNotification *)aNotification;

- (void)keyDown:(NSEvent *)theEvent;
- (void)keyUp:(NSEvent *)theEvent;
- (BOOL)processHitTest:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)theEvent;
- (void)rightMouseDown:(NSEvent *)theEvent;
- (void)otherMouseDown:(NSEvent *)theEvent;
- (void)mouseUp:(NSEvent *)theEvent;
- (void)rightMouseUp:(NSEvent *)theEvent;
- (void)otherMouseUp:(NSEvent *)theEvent;
- (void)mouseMoved:(NSEvent *)theEvent;
- (void)mouseDragged:(NSEvent *)theEvent;
- (void)rightMouseDragged:(NSEvent *)theEvent;
- (void)otherMouseDragged:(NSEvent *)theEvent;
- (void)scrollWheel:(NSEvent *)theEvent;
- (void)touchesBeganWithEvent:(NSEvent *)theEvent;
- (void)touchesMovedWithEvent:(NSEvent *)theEvent;
- (void)touchesCancelledWithEvent:(NSEvent *)theEvent;
- (void)handleTouches:(NSTouchPhase) phase withEvent:(NSEvent *)theEvent;

/*
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor;
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor;
- (BOOL)control:(NSControl *)control didFailToFormatString:(NSString *)string errorDescription:(NSString *)error;
- (void)control:(NSControl *)control didFailToValidatePartialString:(NSString *)string errorDescription:(NSString *)error;
- (BOOL)control:(NSControl *)control isValidObject:(id)obj;

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector;
- (NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index;
*/

- (BOOL)textShouldBeginEditing:(NSText *)textObject;
- (BOOL)textShouldEndEditing:(NSText *)textObject;
- (void)textDidBeginEditing:(NSNotification *)notification;
- (void)textDidEndEditing:(NSNotification *)notification;
- (void)textDidChange:(NSNotification *)notification;

- (void)controlTextDidBeginEditing:(NSNotification *)notification;
- (void)controlTextDidEndEditing:(NSNotification *)notification;
- (void)controlTextDidChange:(NSNotification *)notification;

- (BOOL)isTextFieldInFocus:(NSTextField *)textField;

@end
