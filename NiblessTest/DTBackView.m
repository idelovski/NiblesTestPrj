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

- (void)drawRect:(NSRect)dirtyRect
{
   NSWindow  *win = self.window;
   FORM_REC  *form = id_FindForm (win);
   
   id_DrawTBPadding (form);
   
   // NSLog (@".");
}

#pragma mark -

- (void)handleToolbar:(id)sender
{
   NSButton  *btn = (NSButton *)sender;
   
   NSLog (@"Toolbar Button: %d", (int)btn.tag);
}

- (void)onScaleSelectionChange:(id)sender
{
   NSPopUpButton  *btn = (NSPopUpButton *)sender;
   NSWindow       *win = self.window;
   CGRect          winRect = win.frame;
   FORM_REC       *form = id_FindForm (win);
   
   NSLog (@"Toolbar PopUp Button: %d: %d %%", (int)btn.tag, (int)[btn.selectedItem.title intValue]);
   
   short  oldRatio = form->scaleRatio;
   short  ratio = 100 + 10 * btn.indexOfSelectedItem;
   
   if (!form->ditl_def)  {
   
      CGRect  origRect = CGRectMake (winRect.origin.x, winRect.origin.y, winRect.size.width * 100 / oldRatio, winRect.size.height * 100 / oldRatio);
      CGRect  newRect = CGRectMake (origRect.origin.x, origRect.origin.y, origRect.size.width * ratio / 100, origRect.size.height * ratio / 100);
      
      // win.frame = newRect;
      
      newRect.origin.y -= newRect.size.height - winRect.size.height;
      
      [win setFrame:newRect display:YES animate:YES];
      
      form->overlayView.frame = ((NSView *)[win contentView]).frame;
      
      [self resizeContentInForm:form toNewRatio:ratio];
   }
   else  {
      id_scale_form (form, ratio, FALSE);
   }
   
   form->scaleRatio = ratio;
}

- (void)resizeContentInForm:(FORM_REC *)form toNewRatio:(short)ratio
{
   [MainLoop resizeControl:form->okButton inForm:form toNewRatio:ratio];
   [MainLoop resizeControl:form->newWinButton inForm:form toNewRatio:ratio];
   
   [MainLoop resizeControl:form->imgButton inForm:form toNewRatio:ratio];
   [MainLoop resizeControl:form->imgView inForm:form toNewRatio:ratio];
   
   [MainLoop resizeControl:form->checkBoxButton inForm:form toNewRatio:ratio];

   [MainLoop resizeControl:form->radioButton[0] inForm:form toNewRatio:ratio];
   [MainLoop resizeControl:form->radioButton[1] inForm:form toNewRatio:ratio];
   [MainLoop resizeControl:form->radioButton[2] inForm:form toNewRatio:ratio];

   [MainLoop resizeControl:form->leftField inForm:form toNewRatio:ratio];
   [MainLoop resizeControl:form->rightField inForm:form toNewRatio:ratio];
   [MainLoop resizeControl:form->bigField inForm:form toNewRatio:ratio];
   
   [MainLoop resizeControl:form->labelField inForm:form toNewRatio:ratio];
   
   [MainLoop resizeControl:form->popUpButtonL inForm:form toNewRatio:ratio];
   [MainLoop resizeControl:form->popUpButtonS inForm:form toNewRatio:ratio];
   [MainLoop resizeControl:form->popUpButtonR inForm:form toNewRatio:ratio];

   id_frame_fields (form, form->radioButton[0], form->radioButton[2], 0, NULL);
}

@end

void  id_scale_form (FORM_REC *form, short newScaleRatio, short controlsOnly)
{
   short      index;
   Rect       tmpRect, winRect, newRect;
   WindowPtr  savedPort;
   // ID_LAYOUT *theLayout = NULL;
   
   DITL_item  *f_ditl_def;
   EDIT_item  *f_edit_def;
   
   if (!form->my_window || (form->scaleRatio == newScaleRatio))  return;
   
   // Need top-left position, the rest is recalculated later
   GetWindowRect ((WindowPtr)form->my_window, &winRect);
   id_WinRect2FormRect (form, &winRect, &tmpRect);
   SetRect (&winRect, tmpRect.left, tmpRect.top,
            tmpRect.left + RectWidth(&form->w_rect), tmpRect.top + RectHeight(&form->w_rect));
   
   form->scaleRatio = newScaleRatio;
   
   id_FormRect2WinRect (form, &winRect, &newRect);
   
   CGRect  newFrame = id_CocoaRect(nil, id_Rect2CGRect(&newRect));
   
   newFrame = [form->my_window frameRectForContentRect:newFrame];
   
   // newFrame.origin.y -= newFrame.size.height - form->my_window.frame.size.height;
   
   [form->my_window setFrame:newFrame display:YES animate:YES];
   
   form->overlayView.frame = ((NSView *)[form->my_window contentView]).frame;
   
   // a) maybe one day have these 2
   
   // GetWinPort (&savedPort);
   // SetWinPort (form->my_window);
   
   // b) if I need to erase the background, if setNeedsDisplay is not enough
   
   // id_get_form_rect (&tmpRect, form, TRUE);  // client rect
   
   // if (form->w_procID == documentProc)  // useful even before form->toolBarHandle created!
   //    tmpRect.bottom += dtGData->statusBarHeight;
   
   // EraseRect (&tmpRect);
   
   [(NSView *)form->my_window.contentView setNeedsDisplay:YES];
   
   for (index=0; index<=form->last_fldno; index++)  {
      
      f_ditl_def = form->ditl_def[index];
      f_edit_def = form->edit_def[index];
      
      // if (!form->ditl_def[index]->i_handle)   continue;
      
      id_CopyMac2Rect (form, &tmpRect, &form->ditl_def[index]->i_rect);
      
      CGRect  newCtlRect = id_Rect2CGRect (&tmpRect);
      
      // CGRect  newCtlRect = CGRectMake (origRect.origin.x * newScaleRatio / 100, origRect.origin.y * newScaleRatio / 100,
      //                                  origRect.size.width * newScaleRatio / 100, origRect.size.height * newScaleRatio / 100);
      
      // newCtlRect = NSOffsetRect (newCtlRect, 0., dtGData->toolBarHeight);
      
      if (f_ditl_def->i_type & editText)
         newCtlRect = CGRectInset (newCtlRect, -3, -3);
      else  if (f_ditl_def->i_type & statText)
         newCtlRect = CGRectInset (newCtlRect, -3, -3);
      else  if (f_ditl_def->i_type & ctrlItem)  {
         short  pureIType = f_ditl_def->i_type & 127, itsaControl = TRUE;
         
         if (pureIType == (ctrlItem+btnCtrl))  {       /* Simple Button */
            newCtlRect = CGRectInset (newCtlRect, -3, -3);
         }
      }
      
      if (f_ditl_def->i_handle)  {
         [(NSControl *)f_ditl_def->i_handle setFrame:newCtlRect];
      }
   } /* end of for */
   
   // if (!controlsOnly)
   //    SizeWindow (form->my_window, RectWidth(&newRect), RectHeight(&newRect), FALSE);
   
   // GetWindowRect (form->my_window, &winRect);
   // InvalWinRect (form->my_window, &winRect);
   
   // SetWinPort (savedPort);
}

