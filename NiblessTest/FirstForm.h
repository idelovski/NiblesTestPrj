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
- (NSButton *)createDITLButtonInForm:(FORM_REC *)form;
- (void)ditlButtonPressed:(id)button;
- (NSButton *)createOpenAliasButtonInForm:(FORM_REC *)form;
- (void)aliasButtonPressed:(id)button;

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

#define  MY_STOP_ALERT    256
#define  MY_NOTE_ALERT    257
#define  MY_SILENT_ALERT   MY_NOTE_ALERT
#define  MY_CHOOSE_ALERT  258
#define  MY_SAVE_YES_NO   260   // used on osx

#define  kAskSaveDITL     MY_SAVE_YES_NO
#define  kDevilsAlertDITL 262

#define  kCicnJagoda     512
#define  kCicnDevil      514
#define  kCicnBlank      516
#define  kCicnPlusSign   517
#define  kCicnBullet     518
#define  kCicnCheckMark  519



#define  kCTErrnoSTRings    255
#define  kPARSErrnoSTRings  141

#define  kDBErrSTRings      256

#define REMSG_init_data_base_s      1
#define REMSG_create_file_s         2
#define REMSG_koristiti_file_s_s    3
#define REMSG_postava_filea_s       4
#define REMSG_open_file_s_s         5
#define REMSG_open_other_s_s        6
#define REMSG_read_disk_d           7
#define REMSG_datent_s              8

int  id_note_emsg (const char *fmt, ...);
int  id_stop_emsg (const char *fmt, ...);

