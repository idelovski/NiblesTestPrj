//
//  FirstForm.h
//  NiblessTest
//
//  Created by me on 09.07.23.
//  Copyright (c) 2023 Delovski d.o.o. All rights reserved.
//

#import  <Cocoa/Cocoa.h>

#import  "WindowFactory.h"
#import  "DTBackView.h"
#import  "DTOverlayView.h"


@interface FirstForm : NSObject  {
}

@property (nonatomic, retain)  NSWindow       *window;
@property (nonatomic, retain)  NSWindow       *otherWindow;

@property (nonatomic, retain)  WindowFactory  *windowFactory;

- (id)initWithWindow:(NSWindow *)aWindow;

- (void)runMainLoop;

- (void)createContentInForm:(FORM_REC *)form;

// Buttons

- (NSButton *)coreCreateButtonWithFrame:(CGRect)frame
                                 inForm:(FORM_REC *)form
                                  title:(NSString *)buttonTitle;
- (NSButton *)createButtonInForm:(FORM_REC *)form;
- (void)buttonPressed:(id)button;
- (NSButton *)createNewWindowButtonInForm:(FORM_REC *)form;

- (NSButton *)coreCreateCheckBoxWithFrame:(CGRect)frame
                                   inForm:(FORM_REC *)form
                                    title:(NSString *)buttonTitle;
- (NSButton *)createCheckBoxInForm:(FORM_REC *)form;
- (void)checkPressed:(id)button;

- (NSButton *)coreCreateRadioButtonWithFrame:(CGRect)frame
                                      inForm:(FORM_REC *)form
                                       title:(NSString *)buttonTitle;
- (NSButton *)createRadioButtonWithOffset:(CGFloat)offset
                                   inForm:(FORM_REC *)form;
- (void)radioPressed:(id)idButton;

// Edit fields

- (NSTextField *)coreCreateEditFieldWithFrame:(CGRect)fldRect
                                       inForm:(FORM_REC *)form;

- (void)createEditFieldsInForm:(FORM_REC *)form;

- (NSTextField *)coreCreateLabelWithFrame:(CGRect)fldRect
                                   inForm:(FORM_REC *)form;
- (NSTextField *)createLabelInForm:(FORM_REC *)form version:(char *)titleStr;

// Image Button

- (NSButton *)createImgButtonInForm:(FORM_REC *)form withImageName:(NSString *)imgName;
- (void)imgButtonPressed:(id)button;

- (NSImageView *)coreCreateImageViewWithFrame:(CGRect)frame
                                       inForm:(FORM_REC *)form
                                withImageName:(NSString *)imgName;
- (NSImageView *)createImageViewInForm:(FORM_REC *)form withImageName:(NSString *)imgName;

// PopUp Button

- (NSPopUpButton *)coreCreatePopUpWithFrame:(CGRect)frame
                                     inForm:(FORM_REC *)form;

- (NSPopUpButton *)createPopUpWithOffset:(CGFloat)offset
                                   width:(CGFloat)width
                                  inForm:(FORM_REC *)form;
- (void)onSelectionChange:(id)button;

// Alerts

- (void)showAlertsButtonHit:(id)sender;
- (void)sheetModalEnded:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@end

int  pr_CreateDitlWindow (FORM_REC *form, short ditl_id, Rect *winRect, char *windowTitle, EDIT_item *edit_items);
int  id_alertErr (const char *message, const char *const info);

NSString  *id_Result2Msg (int result);
