//
//  FirstForm.h
//  GeneralCocoaProject
//
//  Created by Sophie Marceau on 09.07.23.
//  Copyright 2023 __MyCompanyName__. All rights reserved.
//

#import  <Cocoa/Cocoa.h>

#import  "WindowFactory.h"
#import  "DTBackView.h"


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
- (NSTextField *)createLabelInForm:(FORM_REC *)form version:(char *)verStr;

// Image Button

- (NSButton *)createImgButtonInForm:(FORM_REC *)form withImageName:(NSString *)imgName;
- (void)imgButtonPressed:(id)button;
- (NSImageView *)createImageViewInForm:(FORM_REC *)form withImageName:(NSString *)imgName;

// PopUp Button

- (NSPopUpButton *)createPopUpInForm:(FORM_REC *)form;
- (void)onSelectionChange:(id)button;

@end

