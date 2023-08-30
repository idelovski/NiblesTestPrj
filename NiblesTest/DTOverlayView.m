//
//  OverlayView.m
//  dTOOL
//
//  Created by me on Aug 24 2023.
//  Copyright (c) 2023 Delf. All rights reserved.
//

#import  "DTOverlayView.h"


@implementation DTOverlayView

- (BOOL)isOpaque
{
    return (NO); // The view is transparent
}

- (NSView *)hitTest:(NSPoint)point
{
    return (nil); // Pass clicks through to views below
}

- (BOOL)acceptsFirstResponder
{
    return (NO);
}

- (BOOL)becomeFirstResponder
{
    [self setNeedsDisplay:YES];
   
    return (NO/*[super becomeFirstResponder]*/);
}

- (BOOL)resignFirstResponder
{
   [self setNeedsDisplay:YES];
   
   return ([super resignFirstResponder]);
}

- (BOOL)isFirstResponder
{
   // if (![[self window] isKeyWindow])
   //    return (NO);
   // if ([[self window] firstResponder] == self)
   //    return (YES);
   
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

- (void)drawRect:(NSRect)dirtyRect
{
   CGRect     smallRect, rect = CGRectInset ((CGRect){.size = dirtyRect.size}, 50, 50);
   NSWindow  *win = self.window;
   FORM_REC  *form = id_FindForm (win);
   
   rect = CGRectOffset (rect, 0, 20);
   
   smallRect = CGRectInset (rect, 40, 60);
      
   form->drawRectCtx = [NSGraphicsContext currentContext].graphicsPort;
   
#ifdef _NIJE_
   CGMutablePathRef  path = CGPathCreateMutable ();
   
	CGPathAddRect (path, NULL, smallRect);
   
   CGContextAddPath (form->drawRectCtx, path);
   
   CGContextSetStrokeColorWithColor (form->drawRectCtx, [NSColor blueColor].toCGColor);
   CGContextDrawPath (form->drawRectCtx, kCGPathStroke);
   
   CGPathRelease (path);
#endif
   
#ifdef _NIJE_
   if (form->pathsArray)  {
      CFIndex  count = CFArrayGetCount (form->pathsArray);
      
      CGContextSetStrokeColorWithColor (form->drawRectCtx, [NSColor blueColor].toCGColor);

      for (CFIndex i=0; i<count; i++)  {
         CGPathRef  path = CFArrayGetValueAtIndex (form->pathsArray, i);

         CGContextAddPath (form->drawRectCtx, path);
         CGContextDrawPath (form->drawRectCtx, kCGPathStroke);
         
         CGPathRelease (path);
      }
      
      CFArrayRemoveAllValues (form->pathsArray);
   }      
#endif

   if (form->pdfsArray)  {
      CFIndex  count = CFArrayGetCount (form->pdfsArray);
      
      for (CFIndex i=0; i<count; i++)  {
         CFDataRef          pdfData = CFArrayGetValueAtIndex (form->pdfsArray, i);
         CGDataProviderRef  provider = CGDataProviderCreateWithCFData (pdfData); 
         CGPDFDocumentRef   pdfDocument = CGPDFDocumentCreateWithProvider (provider);
         
         CGDataProviderRelease (provider);  // almost same as CFRelease(currentPage);
         
         CGPDFPageRef  currentPage = CGPDFDocumentGetPage (pdfDocument, 1);
         // CGRect mediaBox = CGPDFPageGetBoxRect(currentPage, kCGPDFMediaBox);
         // CGContextSaveGState(cgContext);
         // Calculate the transform to position the page
         // float suggestedHeight = viewBounds.size.height * 2.0 / 3.0;
         // CGRect suggestedPageRect = CGRectMake (0, 0,
         //                                        suggestedHeight * (mediaBox.size.width / mediaBox.size.height), 
         //                                        suggestedHeight);
         // CGAffineTransform pageTransform = CGPDFPageGetDrawingTransform (currentPage, kCGPDFMediaBox, suggestedPageRect, 0, true);
         // CGContextConcatCTM (cgContext, pageTransform);
         CGContextDrawPDFPage (form->drawRectCtx, currentPage);
         // CGContextRestoreGState (cgContext);
         
         // CFRelease (currentPage);
         CGPDFDocumentRelease (pdfDocument);
         // CFRelease (pdfData);  - NO WAY - dobio si ga sa GET
      }
      
      CFArrayRemoveAllValues (form->pdfsArray);
      
      form->pdfsArray = NULL;
   }      
   
#ifdef _NIJE_
   CGContextRef  context = form->drawRectCtx;
   
   // Quartz drawing in UIKit context
   
   // Save the state
   CGContextSaveGState (context);
   
   // Set the line width
   CGContextSetLineWidth (context, 4);
   
   [[NSColor redColor] set];

   // Set the line color
   CGContextSetStrokeColorWithColor (context, [NSColor redColor].toCGColor);
   
   // Draw an ellipse
   CGContextStrokeEllipseInRect (context, rect);

   // Restore the previous state
   CGContextRestoreGState(context);
#endif   
   // Clean up background (we ignore "dirtyRect", drawing entire view at once)
   
   // Draw the frame
   
   [[NSColor lightGrayColor] set];
   
   smallRect = [self bounds];
   
   smallRect.size.height -= kSBAR_HEIGHT;
   
   NSFrameRect (NSInsetRect(smallRect, 3, 3));
   
   // Draw the image
   
   NSImage  *image = [NSImage imageNamed:@"Bouquet512"];
   
   smallRect = CGRectMake (5, self.bounds.size.height-image.size.height-5, image.size.width, image.size.height);
   
   smallRect = CGRectOffset (smallRect, 0, -kSBAR_HEIGHT);
   
   [MainLoop drawImage:image inFrame:smallRect form:form];
   
   id_DrawStatusbar (form, TRUE);

   form->drawRectCtx = NULL;
}

@end

@implementation NSColor(Additions)

- (CGColorRef)toCGColor
{
   CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB ();
	
   NSColor* selfCopy = [self colorUsingColorSpaceName:NSDeviceRGBColorSpace];
   
   CGFloat colorValues[4];
   
	[selfCopy getRed:&colorValues[0] green:&colorValues[1] blue:&colorValues[2] alpha:&colorValues[3]];
   
   CGColorRef color = CGColorCreate (colorSpace, colorValues);
   
	CGColorSpaceRelease (colorSpace); 
   
   return (color);
}

@end
