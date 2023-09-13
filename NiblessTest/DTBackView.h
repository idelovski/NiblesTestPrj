//
//  DTBackView.h
//  dTOOL
//
//  Created by me on Aug 11 2023.
//  Copyright (c) 2023 Delf. All rights reserved.
//

#import  <AppKit/AppKit.h>

#import  "MainLoop.h"
#import  "WindowFactory.h"

@interface  DTBackView : NSView
{
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;

- (void)handleToolbar:(id)sender;
- (void)onScaleSelectionChange:(id)sender;

- (void)resizeContentInForm:(FORM_REC *)form toNewRatio:(short)ratio;

@end

int   id_get_max_rect (Rect *rect);
void  id_adjust_button_rect (FORM_REC *form, short index, Rect *ctlRect);
void  id_adjust_pict_rect (FORM_REC *form, short index, Rect *ctlRect);
void  id_adjust_popUp_rect (FORM_REC *form, short index, Rect *ctlRect);
void  id_adjust_tePop_rect (FORM_REC *form, short index, Rect *ctlRect);

int   id_get_max_scaled_rect (FORM_REC *form, Rect *retMaxRect);

void  id_scale_form (FORM_REC *form, short newScaleRatio, short controlsOnly);

int  id_ScaleRatio2Level (short scaleRatio);
int  id_Level2ScaleRatio (short sLevel);
