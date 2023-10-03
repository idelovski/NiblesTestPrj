//
//  BackView.m
//  NiblessTest
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
   FORM_REC  *form = id_FindForm (btn.window);
   short      index = (short)btn.tag;

   IDToolbarHandle  tbHandle = (IDToolbarHandle)form->toolBarHandle;

   NSLog (@"Toolbar Button: %hd", index);
   
   id_PostMenuEvent ((*tbHandle)->tbMenu[index], (*tbHandle)->tbItem[index]);
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
   [MainLoop resizeControl:form->ditlButton inForm:form toNewRatio:ratio];
   [MainLoop resizeControl:form->aliasButton inForm:form toNewRatio:ratio];

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

/* .................................................................................. */
/* ....................................................... SCALING .................. */
/* .................................................................................. */

/* ----------------------------------------------------------- id_get_max_rect ------- */

int  id_get_max_rect (Rect *rect)
{
   Rect  screenBounds;

   id_CGRect2Rect ([[NSScreen mainScreen] frame], &screenBounds);
   // GetQDGlobalsScreenBounds (&screenBounds);

   rect->top  = 20;
   rect->left = 0;
   
   // rect->bottom = qd.screenBits.bounds.bottom;
   // rect->right  = qd.screenBits.bounds.right;
   rect->bottom = screenBounds.bottom;
   rect->right  = screenBounds.right;
   
   return (0);
}

/* ....................................................... id_adjust_button_rect .... */

void  id_adjust_edit_rect (
 FORM_REC  *form,
 short      index,
 Rect      *ctlRect
)
{
   InsetRect (ctlRect, -1, -1);
}

void  id_adjust_stat_rect (
 FORM_REC  *form,
 short      index,
 Rect      *ctlRect
)
{
   InsetRect (ctlRect, -1, -1);
}

/* ....................................................... id_adjust_button_rect .... */

void  id_adjust_button_rect (
 FORM_REC  *form,
 short      index,
 Rect      *ctlRect
)
{
   short   pureIType = form->ditl_def[index]->i_type & 127;
   short   overSize, normalSize = RectHeight (&form->ditl_def[index]->i_rect);

   if (pureIType == (ctrlItem+btnCtrl))  {  /* Simple Button */
      if (RectHeight(ctlRect) > (normalSize + 2))  {
         overSize = RectHeight (ctlRect) - normalSize - 2;
         ctlRect->top += overSize/2;
         ctlRect->bottom -= overSize/2;
      }
   }
}

/* ....................................................... id_adjust_pict_rect ...... */

void  id_adjust_pict_rect (
 FORM_REC  *form,
 short      index,
 Rect      *ctlRect
)
{
   int  diff;
   
   ctlRect->bottom = id_AdjustScaledPictBottom (form, index, ctlRect);
}

/* ....................................................... id_adjust_popUp_rect ..... */

void  id_adjust_popUp_rect (
 FORM_REC  *form,
 short      index,  // may be -1!!!
 Rect      *ctlRect
)
{
   InsetRect (ctlRect, -2, -1);  // MacOS X adjusting
   ctlRect->left -= 2;
   ctlRect->right += 1;
   ctlRect->bottom += 1;
   OffsetRect (ctlRect, 0, -1);
   
   if (RectHeight(ctlRect) % 2)
      ctlRect->bottom += 1;
}

/* ....................................................... id_adjust_popUp_rect ..... */

void  id_adjust_tePop_rect (
 FORM_REC  *form,
 short      index,  // may be -1!!!
 Rect      *ctlRect
)
{
   short   overSize, normalSize = RectHeight(&form->ditl_def[index]->i_rect);
   
   if (RectHeight(ctlRect) > normalSize)  {
      overSize = RectHeight (ctlRect) - normalSize;
      ctlRect->bottom -= overSize;
      ctlRect->right -= overSize;
      OffsetRect (ctlRect, overSize / 2, overSize / 2);
   }
}

/* ....................................................... id_get_max_scaled_rect ... */

int  id_get_max_scaled_rect (FORM_REC *form, Rect *retMaxRect)
{
   short      newScaleLevel = 0;
   short      maxLevel;  // calculation only
   Rect       tmpRect, minRect, maxRect;
   Rect       scrnRect;  // whole screen, minus sys stuff
   
   maxLevel = kScaleLevels - 1;
   
   id_get_max_rect (&scrnRect);
   
   id_FormRect2WinRectEx (form, &form->w_rect, retMaxRect, 100);
   
   for (newScaleLevel=1; newScaleLevel<kScaleLevels; newScaleLevel++)  {
      id_FormRect2WinRectEx (form, &form->w_rect, &tmpRect, id_Level2ScaleRatio(newScaleLevel));
      
      if (RectWidth(&tmpRect) > RectWidth(&scrnRect) || RectHeight(&tmpRect) > RectHeight(&scrnRect))
         return (newScaleLevel-1);
      id_FormRect2WinRectEx (form, &form->w_rect, retMaxRect, id_Level2ScaleRatio(newScaleLevel));
   }
   
   return (maxLevel);
}

#pragma mark -

/* ....................................................... id_scale_form ............ */

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
      
      // CGRect  newCtlRect = CGRectMake (origRect.origin.x * newScaleRatio / 100, origRect.origin.y * newScaleRatio / 100,
      //                                  origRect.size.width * newScaleRatio / 100, origRect.size.height * newScaleRatio / 100);
      
      // newCtlRect = NSOffsetRect (newCtlRect, 0., dtGData->toolBarHeight);
      
      if (f_ditl_def->i_type & editText)  {
         id_adjust_edit_rect (form, index, &tmpRect);
         id_my_edit_layout (form, index);
      }
      else  if (f_ditl_def->i_type & statText)  {
         id_adjust_stat_rect (form, index, &tmpRect);
         id_my_stat_layout (form, index);
      }
      else  if (f_ditl_def->i_type & ctrlItem)  {
         id_adjust_button_rect (form, index, &tmpRect);
         id_set_system_layout (form, index);
      }
      else  if ((form->ditl_def[index]->i_type & 127) == userItem)  {
         if ((form->edit_def[index]->e_type == ID_UT_POP_UP) /*&& !form->edit_def[index]->e_regular*/)  {
            
            NSPopUpButton      *popUp = (NSPopUpButton *)form->ditl_def[index]->i_handle;
            NSPopUpButtonCell  *cell = popUp.cell;
            
            if (RectHeight(&tmpRect) < 16)  {
               [popUp setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize] - 1]];
               cell.controlSize = NSMiniControlSize;  // NSSmallControlSize
            }
            else
               cell.controlSize = NSRegularControlSize;  // NSSmallControlSize

            id_adjust_popUp_rect (form, index, &tmpRect);
            id_my_popUp_layout (form, index);
            
            // id_resetPopUpSize (form, index, &tmpRect);
         }
      }
      
      CGRect  newCtlRect = id_Rect2CGRect (&tmpRect);

      if (f_ditl_def->i_handle)  {
         [(NSControl *)f_ditl_def->i_handle setFrame:newCtlRect];
         /*if ((form->edit_def[index]->e_type == ID_UT_POP_UP))  {
            NSView      *popUp = (NSView *)form->ditl_def[index]->i_handle;
            popUp.visibleRect = CGRectInset (popUp.visibleRect, -1, -1);
         }*/
            
      }
   } /* end of for */
   
   // if (!controlsOnly)
   //    SizeWindow (form->my_window, RectWidth(&newRect), RectHeight(&newRect), FALSE);
   
   // GetWindowRect (form->my_window, &winRect);
   // InvalWinRect (form->my_window, &winRect);
   
   // SetWinPort (savedPort);
}

#pragma mark -

int  gGScaleValues[kScaleLevels]  = { 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200 };

int  id_ScaleRatio2Level (short scaleRatio)
{
   short  i;
   
   for (i=0; i<kScaleLevels; i++)  {
      if (scaleRatio == gGScaleValues[i])
         return (i);
   }
   return (0);
}

// This can recieve non-legal values and handle them correctly

int  id_Level2ScaleRatio (short sLevel)
{
   if (sLevel >=0 && sLevel < kScaleLevels)
      return (gGScaleValues[sLevel]);
   return (sLevel < 0 ? gGScaleValues[0] : gGScaleValues[kScaleLevels-1]);
}
