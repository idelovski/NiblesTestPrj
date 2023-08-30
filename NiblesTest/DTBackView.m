//
//  BackView.m
//  EventMonitor
//
//  Created by me on Fri Nov 02 2001.
//  Copyright (c) 2023 Delovski d.o.o. All rights reserved.
//

#import  "DTBackView.h"


@implementation DTBackView

- (BOOL)acceptsFirstResponder
{
    return (YES);
}

- (BOOL)becomeFirstResponder
{
    [self setNeedsDisplay:YES];
   
    return ([super becomeFirstResponder]);
}

- (BOOL)resignFirstResponder
{
   [self setNeedsDisplay:YES];
   
   return ([super resignFirstResponder]);
}

- (BOOL)isFirstResponder
{
   if (![[self window] isKeyWindow])
      return (NO);
   if ([[self window] firstResponder] == self)
      return (YES);
   
   return (NO);
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
   NSLog (@"acceptsFirstMouse [Back]: NOPE!");
   
   return (NO);
}

- (BOOL)isFlipped
{
   return (YES);
}

#pragma mark -

- (void)handleToolbar:(id)sender
{
   NSButton  *btn = (NSButton *)sender;
   
   NSLog (@"Toolbar Button: %d", (int)btn.tag);
}

@end
