//
//  OverlayView.m
//  dTOOL
//
//  Created by me on Aug 24 2023.
//  Copyright (c) 2023 Delf. All rights reserved.
//

#import  "DTOverlayView.h"

extern  FORM_REC  *dtMainForm;
extern  FORM_REC  *dtRenderedForm;

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

// Called repeatedly if I have a default glowing button in this view

// So in the real project check if there's a default button and ...
// ... see if dirtyRect is basically just that and then ignore everything

- (void)drawRect:(NSRect)dirtyRect
{
   CGRect     smallRect, rect = CGRectInset ((CGRect){.size = dirtyRect.size}, 50, 50);
   NSWindow  *win = self.window;
   FORM_REC  *form = id_FindForm (win);
   
   // NSLog (@"drawRect: %@", NSStringFromRect(dirtyRect));
   
   rect = CGRectOffset (rect, 0, 20);
   
   smallRect = CGRectInset (rect, 40, 60);
      
   form->drawRectCtx = [NSGraphicsContext currentContext].graphicsPort;
   
   CGContextSetStrokeColorWithColor (form->drawRectCtx, [NSColor blackColor].toCGColor);
   CGContextSetLineWidth (form->drawRectCtx, 1.);
   
#ifdef _NIJE_
   CGMutablePathRef  path = CGPathCreateMutable ();
   
	CGPathAddRect (path, NULL, smallRect);
   
   CGContextAddPath (form->drawRectCtx, path);
   
   CGContextSetStrokeColorWithColor (form->drawRectCtx, [NSColor blueColor].toCGColor);
   CGContextDrawPath (form->drawRectCtx, kCGPathStroke);
   
   CGPathRelease (path);
#endif
   
   if (form->update_func)
      (*form->update_func)(form, NULL, ID_BEGIN_OF_UPDATE, 0);

   if (form == dtRenderedForm)
      id_FrameCard (form, 12);
   
   if (form->pathsArray)  {
      CFIndex  count = CFArrayGetCount (form->pathsArray);
      
      CGContextSetStrokeColorWithColor (form->drawRectCtx, [NSColor blueColor].toCGColor);

      for (CFIndex i=0; i<count; i++)  {
         CGPathRef  path = CFArrayGetValueAtIndex (form->pathsArray, i);

         CGContextAddPath (form->drawRectCtx, path);
         CGContextDrawPath (form->drawRectCtx, kCGPathStroke);
         
         // CGPathRelease (path); -> release it where you create it
      }
      
      CFArrayRemoveAllValues (form->pathsArray);
   }      

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
      
      // form->pdfsArray = NULL;
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
   
   if (form == dtMainForm)  {
   
   // Draw the frame
   
   [[NSColor lightGrayColor] set];
   
   smallRect = [self bounds];
   
   smallRect.origin.y += dtGData->toolBarHeight;
   smallRect.size.height -= kSBAR_HEIGHT + dtGData->toolBarHeight;
   
   NSFrameRect (NSInsetRect(smallRect, 3, 3));
   
   // Draw the image
   
   NSImage  *image = [NSImage imageNamed:@"Bouquet512"];
   
   smallRect = CGRectMake (5,
                           self.bounds.size.height-image.size.height-5,
                           image.size.width,
                           image.size.height);
   
   smallRect = CGRectOffset (smallRect, 0, -kSBAR_HEIGHT);
   
   [MainLoop drawImage:image inFrame:smallRect form:form];
      
   }
   
   id_DrawStatusbar (form, TRUE);
   
   // Draw fields
   
   if (form->ditl_def)  {
      short        index;
      Rect         macRect;
      CGRect       tmpRect;
      CFStringRef  winTitleRef;

      DITL_item  *f_ditl_def;
      EDIT_item  *f_edit_def;

      for (index=0; index<=form->last_fldno; index++)  {
         
         f_ditl_def = form->ditl_def[index];
         f_edit_def = form->edit_def[index];
         
         macRect = f_ditl_def->i_rect;
         
         tmpRect = NSMakeRect (macRect.left, macRect.top, macRect.right-macRect.left, macRect.bottom-macRect.top);
         
         tmpRect = NSOffsetRect (tmpRect, 0., dtGData->toolBarHeight);
         
         if (f_ditl_def->i_type & editText)  {  /* If TE field */
            id_frame_editText (form, index);
         }
         else  if ((f_ditl_def->i_type & 127) == userItem)  {
            
            if (f_edit_def->e_type == ID_UT_PICTURE)  {
               id_draw_Picture (form, index);
               // id_create_picture (form, index, savedPort);
               form->usedETypes |= ID_UT_PICTURE;
            }
         }
      } /* end of for */
   }

   if (form->update_func)
      (*form->update_func)(form, NULL, ID_END_OF_UPDATE, 0);

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

/* ::::::::::::::::::::::::::::::::::::::::::::::::::::: Mac 2 Win Graph Ports ::::::: */

/* ----------------------------------------------------- id_GetPort ------------------ */

// Idea is to have this use existing ctx inside drawRect and create new one otherwise

int id_GetPort (FORM_REC *form, WindowPtr *savedPort)
{
   // GetWinPort (savedPort);
   
   if (form->drawRectCtx)
      *savedPort = (WindowPtr)NULL;
   else  if ([form->overlayView canDraw])  {
      [form->overlayView lockFocus];
      form->drawRectCtx = [NSGraphicsContext currentContext].graphicsPort;
      *savedPort = (WindowPtr)form->overlayView;
   }      
   else
      return (-1);
   
   return (0);
}

/* ----------------------------------------------------- id_SetPort ------------------ */

// The game: on win if port == form->my_win, do nothing, else release DC

int id_SetPort (FORM_REC *form, WindowPtr whichPort)
{
   if (whichPort)  {
      if (whichPort == (WindowPtr)form->my_window)  // Do nothing
         return (0);
      else  if (whichPort == (WindowPtr)form->overlayView)  // unlock it
         [form->overlayView unlockFocus];
      else
         return (-1);
   }
   
   return (0);
}

static void  id_DrawOrSavePathInForm (FORM_REC *form, CGPathRef path)
{
   if (form->drawRectCtx)  {
      CGContextSaveGState (form->drawRectCtx);
      CGContextSetShouldAntialias (form->drawRectCtx, NO);
      CGContextAddPath (form->drawRectCtx, path);
      
      // CGContextSetStrokeColorWithColor (form->drawRectCtx, [NSColor blackColor].toCGColor);
      CGContextDrawPath (form->drawRectCtx, kCGPathStroke);
      CGContextRestoreGState (form->drawRectCtx);
   }
   else
      CFArrayAppendValue (form->pathsArray, path);
}

/* ----------------------------------------------------- id_FrameRect ---------------- */

void  id_FrameRect (FORM_REC *form, Rect *theRect)
{
   CGRect  cgRect = id_Rect2CGRect (theRect);
   // FrameRect (theRect);
   CGMutablePathRef  path = CGPathCreateMutable ();
   
	CGPathAddRect (path, NULL, cgRect);
   // CGPathAddRoundedRect ();
   
#ifdef _NIJE_
      CGFloat  cornerRadius = 3.9;
      
   CGPathMoveToPoint (path, NULL, cgRect.origin.x + cornerRadius, cgRect.origin.y ) ;
      
      CGFloat maxX = CGRectGetMaxX (cgRect) ;
      CGFloat maxY = CGRectGetMaxY (cgRect) ;
      
      CGPathAddArcToPoint( path, NULL, maxX, cgRect.origin.y, maxX, cgRect.origin.y + cornerRadius, cornerRadius ) ;
      CGPathAddArcToPoint( path, NULL, maxX, maxY, maxX - cornerRadius, maxY, cornerRadius ) ;
      
      CGPathAddArcToPoint( path, NULL, cgRect.origin.x, maxY, cgRect.origin.x, maxY - cornerRadius, cornerRadius ) ;
      CGPathAddArcToPoint( path, NULL, cgRect.origin.x, cgRect.origin.y, cgRect.origin.x + cornerRadius, cgRect.origin.y, cornerRadius ) ;
#endif
   
   id_DrawOrSavePathInForm (form, path);
   
   CGPathRelease (path);   
}

/* ----------------------------------------------------- id_FrameEditRect ------------ */

void  id_FrameEditRect (FORM_REC *form, Rect *theRect)  // context must be available
{
   CGRect  cgRect = id_Rect2CGRect (theRect);
   // FrameRect (theRect);
   // CGPathAddRect (path, NULL, cgRect);
   // CGPathAddRoundedRect ();

   CGFloat  maxX = CGRectGetMaxX (cgRect);
   CGFloat  maxY = CGRectGetMaxY (cgRect);
   
   if (!form->drawRectCtx)
      return;
   
   CGContextSaveGState (form->drawRectCtx);
   CGContextSetShouldAntialias (form->drawRectCtx, YES);
   
   CGContextSetStrokeColorWithColor (form->drawRectCtx, [NSColor blackColor].toCGColor);  // Top

   CGContextMoveToPoint (form->drawRectCtx, cgRect.origin.x, cgRect.origin.y);
   CGContextAddLineToPoint (form->drawRectCtx, maxX, cgRect.origin.y);
   CGContextDrawPath (form->drawRectCtx, kCGPathStroke);
   
   CGContextSetStrokeColorWithColor (form->drawRectCtx, [NSColor grayColor].toCGColor);  // Right
   CGContextMoveToPoint (form->drawRectCtx, maxX, cgRect.origin.y);
   CGContextAddLineToPoint (form->drawRectCtx, maxX, maxY) ;
   CGContextDrawPath (form->drawRectCtx, kCGPathStroke);
   
   CGContextSetShouldAntialias (form->drawRectCtx, NO);
   CGContextSetStrokeColorWithColor (form->drawRectCtx, [NSColor lightGrayColor].toCGColor);  // Bottom
   CGContextMoveToPoint (form->drawRectCtx, maxX, maxY) ;
   CGContextAddLineToPoint (form->drawRectCtx, cgRect.origin.x, maxY) ;
   CGContextDrawPath (form->drawRectCtx, kCGPathStroke);

   CGContextSetStrokeColorWithColor (form->drawRectCtx, [NSColor grayColor].toCGColor);  // Right
   CGContextMoveToPoint (form->drawRectCtx, cgRect.origin.x, maxY) ;
   CGContextAddLineToPoint (form->drawRectCtx, cgRect.origin.x, cgRect.origin.y);
   CGContextDrawPath (form->drawRectCtx, kCGPathStroke);
   
   CGContextRestoreGState (form->drawRectCtx);

}

/* ----------------------------------------------------- id_FrameCard ---------------- */

int  id_FrameCard (FORM_REC *form, short fromLeft)
{
   Rect  tmpRect;
   
   id_get_form_rect (&tmpRect, form, TRUE);
   
   InsetRect (&tmpRect, 3, 3);
   
   tmpRect.left += fromLeft;
   tmpRect.bottom -= 2;
   tmpRect.right  -= 2;
   
   CGMutablePathRef  path = CGPathCreateMutable ();
   
   CGPathMoveToPoint (path, NULL, tmpRect.left, tmpRect.top);  // MoveTo (tmpRect.left, tmpRect.top);

   CGPathAddLineToPoint (path, NULL, tmpRect.right, tmpRect.top);   // LineTo (tmpRect.right, tmpRect.top);
   CGPathAddLineToPoint (path, NULL, tmpRect.right, tmpRect.bottom);   // LineTo (tmpRect.right, tmpRect.bottom);
   CGPathAddLineToPoint (path, NULL, tmpRect.left, tmpRect.bottom);   // LineTo (tmpRect.left, tmpRect.bottom);

   CGPathMoveToPoint (path, NULL, tmpRect.right+2, tmpRect.top+2);  // MoveTo (tmpRect.right+2, tmpRect.top+2);
   
   CGPathAddLineToPoint (path, NULL, tmpRect.right+2, tmpRect.bottom+2);   // LineTo (tmpRect.right+2, tmpRect.bottom+2);
   CGPathAddLineToPoint (path, NULL, tmpRect.left+2, tmpRect.bottom+2);   // LineTo (tmpRect.left+2, tmpRect.bottom+2);
   
   id_DrawOrSavePathInForm (form, path);
   
   return (0);
}

void  id_InvalWinRect (FORM_REC *form, Rect *invalRect)
{
   NSView  *contentView = [form->my_window contentView];
      
   if (!invalRect)  {
      [contentView setNeedsDisplay:YES];
      [form->overlayView setNeedsDisplay:YES];
   }
   else  {
      CGRect  cgRect = id_Rect2CGRect (invalRect);
      
      [contentView setNeedsDisplayInRect:cgRect];
      [form->overlayView setNeedsDisplayInRect:cgRect];
   }
// [form->my_window.contentView setNeedsDisplayInRect:(NSRect)invalidRect; -> InvalWinRect (form->my_window, &tmpRect);
}
