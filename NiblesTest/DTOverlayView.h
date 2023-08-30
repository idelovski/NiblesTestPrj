//
//  DTOverlayView.h
//  dTOOL
//
//  Created by me on Aug 24 2023.
//  Copyright (c) 2023 Delf. All rights reserved.
//

#import  <AppKit/AppKit.h>
#import  <QuartzCore/QuartzCore.h>

#import  "MainLoop.h"
#import  "WindowFactory.h"

@interface  DTOverlayView : NSView
{
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;

@end

@interface NSColor(Additions)
- (CGColorRef)toCGColor;
@end

