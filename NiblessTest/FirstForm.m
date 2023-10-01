//
//  FirstForm.m
//  NiblessTest
//
//  Created by me on 17.08.23.
//  Copyright 2023 Delovski d.o.o. All rights reserved.
//

#import  "FirstForm.h"
#import  "NiblessTestAppDelegate.h"

#import  "MainLoop.h"
#import  "GetNextEvent.h"
#import  "Bouquet.h"

extern FORM_REC  *dtMainForm;

static double  gXOffset = 60.;
static double  gYOffset = 30.;

@implementation FirstForm

@synthesize  window, otherWindow, windowFactory;

- (id)initWithWindow:(NSWindow *)aWindow
{
   if (self = [super init])  {
      self.window = aWindow;
      
      self.windowFactory = [[WindowFactory alloc] initWithWindow:self.window];
      
      [self.window setDelegate:self.windowFactory];
   }
   
   return (self);
}

- (void)runMainLoop
{
   // id_InitDTool (0/*idApple*/, 0/*idFile*/, 0/*idEdit*/, NULL);
   
   // initMacOSVersion (0, verStr);
   
   [self createContentInForm:dtMainForm];
   
   id_MainLoop (dtMainForm);
   
   [NSApp terminate:self];
   
   // NSMenuItem(title: "Quit", action: #selector(quitClicked), keyEquivalent: "q")
   // @objc private func quitClicked() { ... }
}

- (void)createContentInForm:(FORM_REC *)form
{
   char  tmpStr[256];
   
   form->okButton = [self createButtonInForm:form];
   form->newWinButton = [self createNewWindowButtonInForm:form];
   form->ditlButton = [self createDITLButtonInForm:form];
   form->aliasButton = [self createOpenAliasButtonInForm:form];
   
   form->imgButton = [self createImgButtonInForm:form withImageName:@"Bouquet512"];
   
   form->imgView = [self createImageViewInForm:form withImageName:@"Bouquet512"];
   
   form->checkBoxButton = [self createCheckBoxInForm:form];
   form->radioButton[0] = [self createRadioButtonWithOffset:gXOffset inForm:form];
   form->radioButton[1] = [self createRadioButtonWithOffset:gXOffset+120. inForm:form];
   form->radioButton[2] = [self createRadioButtonWithOffset:gXOffset+240. inForm:form];
   
   [self createEditFieldsInForm:form];
   
   sprintf (tmpStr, "Date: %s", id_form_date(id_sys_date(), _DD_MM_YYYY));
   
   form->labelField = [self createLabelInForm:form version:tmpStr];

   form->popUpButtonL = [self createPopUpWithOffset:0 width:80 inForm:form];
   form->popUpButtonS = [self createPopUpWithOffset:100 width:60 inForm:form];
   form->popUpButtonR = [self createPopUpWithOffset:167 width:166 inForm:form];
   
   [form->popUpButtonR selectItemWithTitle: @"Lucida Grande"];
   
   /*
   CGRect   viewFrame = { { 0, 0 }, { form->my_window.frame.size.width, form->my_window.frame.size.height } };
   NSView  *foreView = [[DTOverlayView alloc] initWithFrame:viewFrame];
   
   [(NSView *)form->my_window.contentView addSubview:foreView];
   
   [foreView release];
   */
   
   // Well, this is called only once.
   
   id_frame_fields (form, form->radioButton[0], form->radioButton[2], 0, NULL);
   
   [MainLoop finalizeFormWindow:form];
}

#pragma mark -

- (NSButton *)coreCreateButtonWithFrame:(CGRect)frame
                                 inForm:(FORM_REC *)form
                                  title:(NSString *)buttonTitle
{
   NSButton  *myButton = [[NSButton alloc] initWithFrame:id_CocoaRect(form->my_window, frame)];
   
   [myButton setButtonType:NSMomentaryLightButton]; //Set what type button You want
   [myButton setBezelStyle:NSRoundedBezelStyle]; //Set what style You want
   
   [[form->my_window contentView] addSubview:myButton];
   
   if (buttonTitle)
      [myButton setTitle:buttonTitle];
   
   [myButton setTag:++form->creationIndex];
   
   // [myButton setButtonType:NSMomentaryLightButton]; //Set what type button You want
   // [myButton setBezelStyle:NSRoundedBezelStyle]; //Set what style You want
   
   return (myButton);
}

- (NSButton *)createButtonInForm:(FORM_REC *)form
{
   NSString  *buttonTitle = @"A button";
   
   //Start from bottom left corner
   
   int  x = gXOffset; //possition x
   int  y = 16 + gYOffset; //possition y
   
   int  width = 130;
   int  height = 24; 
   
   NSButton  *myButton = [[self coreCreateButtonWithFrame:NSMakeRect(x, y, width, height)
                                                  inForm:form
                                                   title:buttonTitle] autorelease];
   
   // [myButton setButtonType:NSMomentaryLightButton]; //Set what type button You want
   // [myButton setBezelStyle:NSRoundedBezelStyle]; //Set what style You want
   
   [myButton setTarget:self];
   [myButton setAction:@selector(buttonPressed:)];
   
   [myButton setKeyEquivalent:@"\r"];
   
   return (myButton);
}

- (void)buttonPressed:(id)button
{
   NSEvent  *event = [NSApp currentEvent];
   
   NSLog(@"Button pressed!");
   
   //Do what You want here...  
   FORM_REC  *form = id_FindForm (FrontWindow());
   
   [form->imgButton setEnabled:YES];
   [form->imgView setEnabled:YES];

   if (event.modifierFlags)  {
      if (event.modifierFlags & NSAlternateKeyMask)  {
         NSLog (@"Alt key!");
         [self showAlertsButtonHit:button];
      }
      if (event.modifierFlags & NSShiftKeyMask)  {
         NSLog (@"Shift key!");
      }
      if (event.modifierFlags & NSControlKeyMask)  {
         NSLog (@"Ctrl key!");
      }
   }
}

- (NSButton *)createNewWindowButtonInForm:(FORM_REC *)form
{
   NSString  *buttonTitle = @"Create Window";
   
   //Start from bottom left corner
   
   int  x = gXOffset; //possition x
   int  y = 46 + gYOffset; //possition y
   
   int  width = 130;
   int  height = 24; 
   
   NSButton  *myButton = [[self coreCreateButtonWithFrame:NSMakeRect(x, y, width, height)
                                                  inForm:form
                                                   title:buttonTitle] autorelease];
   
   // [myButton setButtonType:NSMomentaryLightButton]; //Set what type button You want
   // [myButton setBezelStyle:NSRoundedBezelStyle]; //Set what style You want
   
   [myButton setTarget:self];
   [myButton setAction:@selector(newWindowButtonPressed:)];
   
   return (myButton);
}

// FORM_REC         *dtMainForm = NULL;
// FORM_REC         *dtDialogForm = NULL;
// FORM_REC         *dtRenderedForm = NULL;

- (void)newWindowButtonPressed:(id)button
{
   extern FORM_REC  *dtDialogForm;
   
   EventRecord  evtRecord;
   BOOL         done = FALSE;
   FORM_REC     tmpForm;

   NSLog (@"Button pressed!"); 
   
   //Do what You want here...  
   FORM_REC  *form = id_FindForm (FrontWindow());
   
   NSWindow  *newWin = [WindowFactory createWindowWithRect:id_CocoaRect(nil, CGRectMake(100, 100, 640, 480))
                                                 withTitle:@"Hello world!"];
   
   [newWin setDelegate:self.windowFactory];
   
   [newWin setStyleMask:NSTitledWindowMask | NSClosableWindowMask];
   
   dtDialogForm = &tmpForm;
   
   id_init_form (&tmpForm);
   
   [MainLoop finalizeFormWindow:&tmpForm];
   
   tmpForm.my_window = newWin;
   tmpForm.parentForm = form;
   
   NSModalSession  modalSession = [NSApp beginModalSessionForWindow:newWin];  // seem to call -makeKeyAndOrderFront in there
   
   if (!modalSession)
      return;
   
   // [newWin makeKeyAndOrderFront:NSApp];
   
   dtGData->modalFormsCount++;
   
   do  {
      
      id_GetNextEvent (&evtRecord, 500.);
      
      // NSLog (@"One tick!...");
      
      if (evtRecord.what == keyDown)  {
         if (evtRecord.message == 27)
            done = TRUE;
      }
      else  if ((evtRecord.what = mouseDown) && (evtRecord.modifiers == 2))  // second bit, this goes to id_FindWindow()
         done = TRUE;
      
   } while (!done);
   
   dtGData->modalFormsCount--;
   
   form = id_FindForm (FrontWindow());
   
   [NSApp endModalSession:modalSession];
   
   newWin.delegate = nil;
   [newWin close];
   
   id_FlushUsedEvents (dtDialogForm);
   
   dtDialogForm->my_window = NULL;

   form = id_FindForm (FrontWindow());
   
   dtDialogForm = NULL;

   [newWin release];
}

- (NSButton *)createDITLButtonInForm:(FORM_REC *)form
{
   NSString  *buttonTitle = @"DITL Window";
   
   //Start from bottom left corner
   
   int  x = gXOffset; //possition x
   int  y = 76 + gYOffset; //possition y
   
   int  width = 130;
   int  height = 24; 
   
   NSButton  *myButton = [[self coreCreateButtonWithFrame:NSMakeRect(x, y, width, height)
                                                   inForm:form
                                                    title:buttonTitle] autorelease];
   
   // [myButton setButtonType:NSMomentaryLightButton]; //Set what type button You want
   // [myButton setBezelStyle:NSRoundedBezelStyle]; //Set what style You want
   
   [myButton setTarget:self];
   [myButton setAction:@selector(ditlButtonPressed:)];
      
   return (myButton);
}

- (void)ditlButtonPressed:(id)button
{
   // NSEvent  *event = [NSApp currentEvent];
   
   NSLog (@"ditlButtonPressed pressed!");
   
   pr_OpenKupdob ();
}

- (NSButton *)createOpenAliasButtonInForm:(FORM_REC *)form
{
   NSString  *buttonTitle = @"Open Alias";
   
   //Start from bottom left corner
   
   int  x = 370 + gXOffset; //possition x
   int  y = 236 + gYOffset; //possition y
   
   int  width = 130;
   int  height = 24; 
   
   NSButton  *myButton = [[self coreCreateButtonWithFrame:NSMakeRect(x, y, width, height)
                                                   inForm:form
                                                    title:buttonTitle] autorelease];
   
   // [myButton setButtonType:NSMomentaryLightButton]; //Set what type button You want
   // [myButton setBezelStyle:NSRoundedBezelStyle]; //Set what style You want
   
   [myButton setTarget:self];
   [myButton setAction:@selector(aliasButtonPressed:)];
      
   return (myButton);
}

- (void)aliasButtonPressed:(id)button
{
   FSRef  parentFSRef;
   char   fileName[256];
   
   Boolean  aliasFlag = FALSE;
   
   NSAlert  *alert = nil;
   NSArray  *allowedTypes = [NSArray arrayWithObjects:@"jpg", @"png", @"xls", @"doc", @"rtf", @"txt", @"xlsx", @"docx", @"jpeg", @"m", @"h", nil];
   
   NSLog (@"aliasButtonPressed pressed!");
   
   if (!id_NavGetFile(allowedTypes, fileName, &parentFSRef, &aliasFlag))  {
      
      if (!aliasFlag)
         alert = [NSAlert alertWithMessageText:@"Regular Title" 
                                 defaultButton:@"Create Alias" 
                               alternateButton:@"Cancel" 
                                   otherButton:nil 
                     informativeTextWithFormat:@"Create alias on desktop?"];
      else  {
         alert = [NSAlert alertWithMessageText:@"Alias File" 
                                 defaultButton:@"OK" 
                               alternateButton:nil
                                   otherButton:nil 
                     informativeTextWithFormat:@"Picked file seems to be an alias. There's nothing to do."];
      }
      
      NSInteger  result = [alert runModal];
      
      NSLog (@"alertWithMessageText...runModal: %d - %@; alias: %@", (int)result, id_Result2Msg((int)result), aliasFlag ? @"Yes" : @"No");
      
      if (!aliasFlag && (result == NSAlertDefaultReturn))  {
         char   parentPath[PATH_MAX], aliasPath[PATH_MAX];
         FSRef  desktopFSRef;
         
         NSLog (@"Here we create an alias!");
         if (!FSRefMakePath(&parentFSRef, (UInt8 *)parentPath, PATH_MAX))  {
            id_ConcatPath (parentPath, fileName);
            if (!id_GetDesktopDir(&desktopFSRef))  {
               if (!FSRefMakePath(&desktopFSRef, (UInt8 *)aliasPath, PATH_MAX))  {
                  id_CreateAliasToPath (parentPath, aliasPath, fileName, '????');
               }
            }
         }
      }
   }
}

#pragma mark -

- (NSButton *)createImgButtonInForm:(FORM_REC *)form withImageName:(NSString *)imgName
{
   int  x = gXOffset + 180.; //possition x
   int  y = 6 + gYOffset; //possition y
   
   int  width =  132;
   int  height = 107; 

   NSButton  *myButton = [[self coreCreateButtonWithFrame:NSMakeRect(x, y, width, height)
                                                  inForm:form
                                                   title:nil] autorelease];
   
   [myButton setBezelStyle:NSThickerSquareBezelStyle]; //Set what style You want

   // Load images from the app's resources
   NSImage  *image = [NSImage imageNamed:imgName /*@"icon1"*/];
   
   // Set images for the buttons
   [myButton setImage:image];
   
   [myButton setTarget:self];
   [myButton setAction:@selector(imgButtonPressed:)];

   return (myButton);
}

- (void)imgButtonPressed:(id)button
{
   NSLog(@"ImgButton pressed!"); 
   
   //Do what You want here... 
   
   FORM_REC  *form = id_FindForm (FrontWindow());
   
   [form->imgButton setEnabled:NO];
}

- (NSImageView *)createImageViewInForm:(FORM_REC *)form withImageName:(NSString *)imgName
{
   int  x = gXOffset + 320; //possition x
   int  y = 6 + gYOffset; //possition y
   
   int  width =  132;
   int  height = 107; 

   NSImageView  *myImgView = [[self coreCreateImageViewWithFrame:NSMakeRect(x, y, width, height)
                                                         inForm:form
                                                  withImageName:imgName] autorelease];
   
#ifdef _NIJE_   
   [[[NSImageView alloc] initWithFrame:id_CocoaRect(self.window, )] autorelease];
   
   [[self.window contentView] addSubview:myImgView];
   
   [myImgView setTag:++form->creationIndex];

   // Load images from the app's resources
   NSImage  *image = [NSImage imageNamed:imgName /*@"icon1"*/];
   
   // Set images for the buttons
   [myImgView setImage:image];
#endif
   
   // myImgView.userInteractionEnabled = YES;
   
   [myImgView setTarget:self];
   [myImgView setAction:@selector(checkPressed:)];

   return (myImgView);
}

- (NSImageView *)coreCreateImageViewWithFrame:(CGRect)frame
                                       inForm:(FORM_REC *)form
                                withImageName:(NSString *)imgName
{
   NSImageView  *myImgView = [[NSImageView alloc] initWithFrame:id_CocoaRect(form->my_window, frame)];
   
   [[form->my_window contentView] addSubview:myImgView];
   
   [myImgView setTag:++form->creationIndex];

   // Load images from the app's resources
   NSImage  *image = [NSImage imageNamed:imgName /*@"icon1"*/];
   
   // Set images for the buttons
   [myImgView setImage:image];
   
   // There are -setImageScaling:, -setImageAlignment: 
   
   return (myImgView);
}

#pragma mark -

- (NSButton *)coreCreateCheckBoxWithFrame:(CGRect)frame
                                 inForm:(FORM_REC *)form
                                  title:(NSString *)buttonTitle
{
   NSButton  *button = [[NSButton alloc] initWithFrame:id_CocoaRect(form->my_window, frame)];
   
   [[form->my_window contentView] addSubview:button];
   
   [button setTag:++form->creationIndex];
   
   [button setTitle:buttonTitle];
   [button setBezelStyle:NSRegularSquareBezelStyle];  // new: NSBezelStyleRegularSquare
   [button setBordered:NO];
   [button setShowsBorderOnlyWhileMouseInside:NO];
   [[button cell] setImageScaling:NSImageScaleNone];
   [button setButtonType:NSSwitchButton];  // new: NSButtonTypeSwitch, there is NSButtonTypeRadio
   [button setState:NSOffState];   // new: NSControlStateValueOff there is NSControlStateValueOn
   [button highlight:NO];
   [button setEnabled:YES];
   
   return (button);
}

- (NSButton *)createCheckBoxInForm:(FORM_REC *)form
{
   int  x = gXOffset + 410;  //possition x
   int  y = 116 + gYOffset;  //possition y
   
   NSInteger  width = 100, height = 24;
   
   NSButton  *button = [[self coreCreateCheckBoxWithFrame:NSMakeRect(x, y, width, height)
                                                  inForm:form
                                                   title:@"Box"] autorelease];
   
   // i_UNCHECKBOX_NORMAL_IMAGE = i_image_from_view(button, &i_CHECKBOX_RECT);
   
   [button highlight:YES];
   // i_UNCHECKBOX_PRESSED_IMAGE = i_image_from_view(button, NULL);
   
   [button highlight:NO];
   // [button setEnabled:NO];
   // i_UNCHECKBOX_DISABLE_IMAGE = i_image_from_view(button, NULL);
   
   // [button setState:BUTTON_ON];
   // [button highlight:NO];
   // [button setEnabled:YES];
   // i_CHECKBOX_NORMAL_IMAGE = i_image_from_view(button, NULL);
   
   // [button highlight:YES];
   // i_CHECKBOX_PRESSED_IMAGE = i_image_from_view(button, NULL);
   
   // [button highlight:NO];
   // [button setEnabled:NO];
   // i_CHECKBOX_DISABLE_IMAGE = i_image_from_view(button, NULL);
   
   [button setTarget:self];
   [button setAction:@selector(checkPressed:)];
   
   return (button);
}

- (void)checkPressed:(id)idButton
{
   NSButton  *button = (NSButton *)idButton;
   
   NSLog(@"Check pressed: %@!", [button state] ? @"ON" : @"OFF"); 
   
   //Do what You want here...
}

#pragma mark -

- (NSButton *)coreCreateRadioButtonWithFrame:(CGRect)frame
                                 inForm:(FORM_REC *)form
                                  title:(NSString *)buttonTitle
{
   NSButton  *button = [[NSButton alloc] initWithFrame:id_CocoaRect(form->my_window, frame)];
   
   [[form->my_window contentView] addSubview:button];
   
   [button setTag:++form->creationIndex];
   
   [button setButtonType:NSRadioButton];  // new: NSButtonTypeSwitch, there is NSButtonTypeRadio
   
   [button setTitle:buttonTitle];
   [button setBezelStyle:NSRegularSquareBezelStyle];  // new: NSBezelStyleRegularSquare
   [button setBordered:NO];
   [button setShowsBorderOnlyWhileMouseInside:NO];
   [[button cell] setImageScaling:NSImageScaleNone];
   [button setState:NSOffState];   // new: NSControlStateValueOff there is NSControlStateValueOn
   [button highlight:NO];
   [button setEnabled:YES];
   
   [button highlight:NO];
   
   return (button);
}

- (NSButton *)createRadioButtonWithOffset:(CGFloat)offset
                                   inForm:(FORM_REC *)form
{
   int  x = offset;  //possition x
   int  y = 116 + gYOffset;  //possition y
   
   NSInteger  width = 100, height = 24;
   
   NSButton  *button = [[self coreCreateRadioButtonWithFrame:NSMakeRect(x, y, width, height)
                                                     inForm:form
                                                      title:[NSString stringWithFormat:@"Radio %.0f", offset]] autorelease];
   
   [button setTarget:self];
   [button setAction:@selector(radioPressed:)];
   
   return (button);
}

- (void)radioPressed:(id)idButton
{
   NSButton  *button = (NSButton *)idButton;
   FORM_REC  *form = id_FindForm (FrontWindow());
   
   NSLog (@"%@ pressed: %@!", [button title], [button state] ? @"ON" : @"OFF");
   
   if (form->my_window == FrontWindow())  {
      NSLog (@"COOL - we're front window!");
      
      for (int i=0; i<3; i++)  {
         if (form->radioButton[i] != button)
            [form->radioButton[i] setState:NSOffState];
      }
   }
   
   // HERE: need FindForm(my_window), then go through the radios, change to array
   
   //Do what You want here...
}

#pragma mark -

- (void)createEditFieldsInForm:(FORM_REC *)form
{
   int  x = gXOffset;  //possition x
   int  y = 146 + gYOffset;  //possition y
   
   NSInteger  width = 160, height = 24;

   form->leftField = [self coreCreateEditFieldWithFrame:id_CocoaRect(self.window, NSMakeRect(x, y, width, height))
                                                 inForm:form];
   
   x += 170;
   
   form->rightField = [self coreCreateEditFieldWithFrame:id_CocoaRect(self.window, NSMakeRect(x, y, width, height))
                                                  inForm:form];

   x += 180;
   height += 52;
   

   form->bigField = [self coreCreateEditFieldWithFrame:id_CocoaRect(self.window, NSMakeRect(x, y, width, height))
                                                  inForm:form];
}

- (NSTextField *)coreCreateEditFieldWithFrame:(CGRect)fldRect
                                       inForm:(FORM_REC *)form
{
   NSTextField      *edit = nil;
   NSTextFieldCell  *cell = nil;
   
   edit = [[NSTextField alloc] initWithFrame:fldRect];
   
   [[form->my_window contentView] addSubview:edit];

   [edit setTag:++form->creationIndex];  // Nope, I need to set this tag on my own as there might be certain fields in rsrc that are not active

   [edit setDelegate:self.windowFactory];

#ifdef _USE_LAYER_   
   edit.wantsLayer = TRUE;
    
   CALayer  *layer = [CALayer new];
   edit.layer = layer;
   [layer release];
    
   // edit.backgroundColor = [NSColor selectedTextBackgroundColor];
    
   layer.borderColor = [NSColor lightGrayColor].toCGColor;
   layer.backgroundColor = [NSColor textBackgroundColor].toCGColor;
   layer.borderWidth = 1;
   layer.cornerRadius = 5;
#endif
   /*
    
    This din't help on field change
    
    [[NSNotificationCenter defaultCenter] addObserver:self.windowFactory
                                            selector:@selector(textFieldDidBeginEditing:)
                                                name:NSControlTextDidBeginEditingNotification
                                              object:edit];*/
   
   cell = [edit cell];  // from NSControl
   
   [cell setEditable:YES];
   [cell setSelectable:YES];
   [cell setBordered:NO];
   [cell setBezeled:NO];
   [cell setDrawsBackground:YES];
   [cell setStringValue:@""];
   
   [cell setFocusRingType:NSFocusRingTypeNone];
   
   // edit.textContainer cell.textContainerInset = NSMakeSize (0, 2);
   
   [cell setFont:[NSFont fontWithName:@"Lucida Grande" size:9.]];
   // [cell setAlignment:_oscontrol_text_alignment(ekLEFT)];

   /*
   edit->scell = [[NSSecureTextFieldCell alloc] init];
   [edit->scell setEchosBullets:YES];
   [edit->scell setEditable:YES];
   [edit->scell setSelectable:YES];
   [edit->scell setBordered:YES];
   [edit->scell setBezeled:YES];
   [edit->scell setDrawsBackground:YES];
   [edit->scell setAlignment:_oscontrol_text_alignment(ekLEFT)];
#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5
   [edit->cell setUsesSingleLineMode:((flags & 1) == 1) ? NO : YES];
   [edit->scell setUsesSingleLineMode:((flags & 1) == 1) ? NO : YES];
#endif
    */
   return (edit);
}

- (NSTextField *)coreCreateLabelWithFrame:(CGRect)fldRect
                                   inForm:(FORM_REC *)form
{
   NSTextField      *label = nil;
   NSTextFieldCell  *cell = nil;
   
   label = [[NSTextField alloc] initWithFrame:fldRect];
   
   [[form->my_window contentView] addSubview:label];

   [label setTag:++form->creationIndex];

   // [label setDelegate:self.windowFactory];
   
   cell = [label cell];  // from NSControl
   
   [cell setEditable:NO];
   [cell setSelectable:NO];
   [cell setBordered:NO];
   [cell setBezeled:NO];
   [cell setDrawsBackground:NO];
   [cell setStringValue:@""];
   
   [cell setFont:[NSFont fontWithName:@"Lucida Grande" size:10.]];
   // [cell setAlignment:_oscontrol_text_alignment(ekLEFT)];

   return (label);
}

- (NSTextField *)createLabelInForm:(FORM_REC *)form version:(char *)titleStr
{
   int  x = gXOffset;  //possition x
   int  y = 176 + gYOffset;  //possition y
   
   NSInteger  width = 180, height = 24;

   NSTextField  *label = [self coreCreateLabelWithFrame:id_CocoaRect(form->my_window, NSMakeRect(x, y, width, height))
                                                                     inForm:form];
   [label setStringValue:[NSString stringWithFormat:@"%s", titleStr]];

#ifdef _NIJE_
   NSTextFieldCell  *cell = nil;
   
   label = [[NSTextField alloc] initWithFrame:id_CocoaRect(self.window, NSMakeRect(x, y, width, height))];
   
   [[self.window contentView] addSubview:label];

   [label setTag:++form->creationIndex];

   cell = [label cell];  // from NSControl
   
   [cell setEditable:NO];
   [cell setSelectable:YES];
   [cell setBordered:NO];
   [cell setBezeled:NO];
   [cell setDrawsBackground:NO];
   // [cell setAlignment:_oscontrol_text_alignment(ekLEFT)];

   /*
   label->scell = [[NSSecureTextFieldCell alloc] init];
   [label->scell setEchosBullets:YES];
   [label->scell setEditable:YES];
   [label->scell setSelectable:YES];
   [label->scell setBordered:YES];
   [label->scell setBezeled:YES];
   [label->scell setDrawsBackground:YES];
   [label->scell setAlignment:_oscontrol_text_alignment(ekLEFT)];
#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5
   [label->cell setUsesSingleLineMode:((flags & 1) == 1) ? NO : YES];
   [label->scell setUsesSingleLineMode:((flags & 1) == 1) ? NO : YES];
#endif
    */
#endif
   
   return (label);
}

#pragma mark -

- (NSPopUpButton *)coreCreatePopUpWithFrame:(CGRect)frame
                                  inForm:(FORM_REC *)form
{
   NSPopUpButton      *popUp = nil;
   NSPopUpButtonCell  *cell = nil;
   
   popUp = [[NSPopUpButton alloc] initWithFrame:id_CocoaRect(form->my_window, frame)];
   
   [[form->my_window contentView] addSubview:popUp];
   
   [popUp setTag:++form->creationIndex];
   
   // popUp->OnSelect_listener = NULL;
   
   cell = [popUp cell];
   /*[cell setBezelStyle:NSShadowlessSquareBezelStyle];*/
   [cell setArrowPosition:NSPopUpArrowAtBottom];
   
   [popUp setPullsDown:NO];
   [popUp setTarget:self];
   [popUp setAction:@selector(onSelectionChange:)];
   
   if (frame.size.height < 20)  {
      [popUp setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize] - 1]];
      cell.controlSize = NSMiniControlSize;  // NSSmallControlSize
   }
   
   return (popUp);
}

- (NSPopUpButton *)createPopUpWithOffset:(CGFloat)offset
                                   width:(CGFloat)width
                                  inForm:(FORM_REC *)form
{
   int  x = gXOffset + offset;  //possition x
   int  y = 200 + gYOffset;  //possition y
   
   NSInteger  /*width = offset ? 166 : 120,*/ height = 24;
   
   NSPopUpButton      *popUp = nil;
   // NSPopUpButtonCell  *cell = nil;
   
   popUp = [self coreCreatePopUpWithFrame:NSMakeRect(x, y, width, height)
                                   inForm:form];
   
   if (!offset)  {
   
      [popUp addItemWithTitle:@"One"];
      [popUp addItemWithTitle:@"Two"];
      [popUp addItemWithTitle:@"Three"];
   }
   else  if (width > 100)  {
      NSFontManager  *fontManager = [NSFontManager sharedFontManager];
      
      NSArray  *fontFamilyNames = [fontManager availableFontFamilies];
      
      for (NSString  *fTitle in fontFamilyNames)
         [popUp addItemWithTitle:fTitle];
   }
   else  {
      [popUp addItemWithTitle:@"9"];
      [popUp addItemWithTitle:@"10"];
      [popUp addItemWithTitle:@"11"];
      [popUp addItemWithTitle:@"12"];
      [popUp addItemWithTitle:@"14"];
   }
   
   return (popUp);
}

- (void)onSelectionChange:(id)button
{
   NSPopUpButton  *popUp = (NSPopUpButton *)button;
   
   FORM_REC  *form = id_FindForm (FrontWindow());
   
   NSLog(@"PopUp selection changed?: %d %@", (int)[popUp indexOfItem:[popUp selectedItem]], [popUp titleOfSelectedItem]); 
   
   if ((popUp == form->popUpButtonR) || (popUp == form->popUpButtonS))  {
      NSString  *name = [form->popUpButtonR titleOfSelectedItem];
      NSString  *size = [form->popUpButtonS titleOfSelectedItem];
      NSFont    *font = [NSFont fontWithName:name size:[size doubleValue]];
      
      if (font)  {
         NSFont  *boldFont = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSBoldFontMask];
         
         [form->leftField setFont:font];
         [form->rightField setFont:boldFont];
         
         NSLog (@"Font: %@ (%.0f) can be bold: %@ italic: %@",
                [font fontName],
                [font pointSize],
                [font fontInFamilyExistsInBold] ? @"Yes" : @"No",
                [font fontInFamilyExistsInItalic] ? @"Yes" : @"No");
         
         CGFontRef  fontRef = CTFontCopyGraphicsFont ((CTFontRef)font, NULL);
         
         font = (NSFont *)CTFontCreateWithGraphicsFont (fontRef, [font pointSize], NULL, NULL);
         
         CFRelease (fontRef); 

         NSLog (@"Font: %@ (%.0f) can be bold: %@ italic: %@",
                [font fontName],
                [font pointSize],
                [font fontInFamilyExistsInBold] ? @"Yes" : @"No",
                [font fontInFamilyExistsInItalic] ? @"Yes" : @"No");
         
         [font release];
      }
   }
   
   //Do what You want here...  
}

#pragma mark -

- (void)buttonInDitlPressed:(id)sender
{
   NSLog (@"Button pressed!"); 
}

#pragma mark -

- (void)showAlertsButtonHit:(id)sender
{
   NSInteger  result = NSRunAlertPanel (@"Title",
                                        @"Message",
                                        @"Default Button",
                                        @"Alternate Button",
                                        @"Other Button");
   
   NSLog (@"NSRunAlertPanel: %d - %@", (int)result, id_Result2Msg((int)result));
   
   
   result = NSRunCriticalAlertPanel (@"Title",
                                     @"Message",
                                     @"Default Button",
                                     @"Alternate Button",
                                     @"Other Button");
   
   NSLog (@"NSRunCriticalAlertPanel: %d - %@", (int)result, id_Result2Msg((int)result));
   
   result = NSRunInformationalAlertPanel (@"Title",
                                          @"Message",
                                          @"Default Button",
                                          @"Alternate Button",
                                          @"Other Button");

   NSLog (@"NSRunInformationalAlertPanel: %d - %@", (int)result, id_Result2Msg((int)result));

   NSAlert *alert = [NSAlert alertWithMessageText:@"Alert Title" 
                                    defaultButton:@"Default Button" 
                                  alternateButton:@"Cancel" 
                                      otherButton:@"Other Button" 
                        informativeTextWithFormat:@"Something bad has happened."];

   result = [alert runModal];
   
   // [alert release]; NO NEED!

   NSLog (@"alertWithMessageText...runModal: %d - %@", (int)result, id_Result2Msg((int)result));
	
   result = id_alertErr ("This is the message", "Jašta!");

   NSLog (@"id_alertErr: %d - %@", (int)result, id_Result2Msg((int)result));

   alert = [NSAlert alertWithMessageText:@"Alert Title" 
						defaultButton:@"Default Button"
						alternateButton:@"Cancel" 
						otherButton:@"Other Button" 
						informativeTextWithFormat:@"Something bad has happened."];
	
   [alert beginSheetModalForWindow:[self window]
                     modalDelegate:self
                    didEndSelector:@selector(sheetModalEnded:returnCode:contextInfo:)
                       contextInfo:@"1-2-3"];
   
}

- (void)sheetModalEnded:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
   NSLog (@"sheet model ended.\nreturnCode: %d - %@\ncontextInfo: %@",
          (int)returnCode, id_Result2Msg((int)returnCode), contextInfo);
}

@end

#pragma mark -

/* ................................................... pr_CreateDitlWindow .......... */

extern  FORM_REC  *dtRenderedForm;

// do outside self.otherWindow = newWin;

int  pr_CreateDitlWindow (
 FORM_REC   *form,
 short       ditl_id,
 Rect       *w_rect,
 char       *windowTitle,
 EDIT_item  *edit_items
)
{
   short  index, retVal;
   // char   tmpStr[256];
   // FSRef  parentFSRef, bundleParentFolderFSRef;
   // char   fileName[256], pathStr[256];
   
   Rect        winRect;
   CGRect      winFrame;
   
   DITL_item  *f_ditl_def;
   EDIT_item  *f_edit_def;
   
   NiblessTestAppDelegate  *appDelegate = (NiblessTestAppDelegate *)[NSApp delegate];
   
   // id_SetBlockToZeros (form, sizeof (FORM_REC));
      
   form->w_rect = *w_rect;
   
   id_FormRect2WinRect (form, w_rect, &winRect);
   
   winFrame = id_Rect2CGRect (&winRect);
   
   /*if (!id_GetApplicationExeFSRef(&appParentFolderFSRef))  {
    if (FSRefMakePath(&appParentFolderFSRef, (UInt8 *)pathStr, 256))
    pathStr[0] = '\0';
    if (!id_ExtractFSRef(&appParentFolderFSRef, fileName, &parentFSRef))
    NSLog (@"Converted path: %s %s", pathStr, fileName);
    }*/
   
   if (form->DITL_handle=GetResource('DITL', ditl_id))  {
      
      form->last_fldno = *((short *)(*form->DITL_handle));
      NSLog (@".... last_fldno: %hd", form->last_fldno);
      
      if (!(form->ditl_def = (DITL_item **) id_malloc_array (form->last_fldno+1, sizeof (DITL_item))))  {
         // ReleaseResource (form->DITL_handle);
         form->DITL_handle = NULL;
         form->ditl_def = NULL;
      }
      else  {
         HLock (form->DITL_handle);
         id_copy_DITL_info (form->ditl_def, form->DITL_handle);
         HUnlock (form->DITL_handle);
         NSLog (@".... WOW!");
      }
      
      // errno = 0;
      
      ReleaseResource (form->DITL_handle);

      if (!(form->edit_def = (EDIT_item **) NewPtr ((form->last_fldno+1)*sizeof(char *))))  {
         // id_CloseWindow (form->my_window);
         return (-1);
      }
      id_attach_EDIT_info (form, edit_items, form->last_fldno, FALSE);
   }   

   // Now, lets build our window
   
   if (form->DITL_handle && form->ditl_def)  {
      Rect         tmpRect;
      CGRect       cgRect;
      CFStringRef  winTitleRef;
      
      id_Mac2CFString (windowTitle, &winTitleRef, strlen(windowTitle));

      NSWindow  *newWin = [WindowFactory createWindowWithRect:id_CocoaRect(nil, winFrame)
                                                    withTitle:(NSString *)winTitleRef];
      CFRelease (winTitleRef);
      
      [newWin setDelegate:appDelegate.firstFormHandler.windowFactory];
      
      CGRect   viewFrame = { { 0, 0 }, { 0, 0 } };
      viewFrame.size = winFrame.size;

      NSView  *view = [[[DTBackView alloc] initWithFrame:viewFrame] autorelease];
      
      [newWin setContentView:view];
      
      NSLog (@"NewWindow:\nCreation Frame: %@, WindowFrame: %@, ClientRect: %@",
             NSStringFromRect(id_CocoaRect(nil, winFrame)),
             NSStringFromRect(newWin.frame),
             NSStringFromRect([newWin contentRectForFrameRect:newWin.frame]));
      
      form->my_window = newWin; 
      // self.otherWindow = newWin;
      
      form->pen_flags |= ID_PEN_DOWN;
      
      dtRenderedForm = form;
      
      if (form->update_func)
         (*form->update_func)(form, NULL, ID_BEGIN_OF_OPEN, 0);

      for (index=0; index<=form->last_fldno; index++)  {
         
         f_ditl_def = form->ditl_def[index];
         f_edit_def = form->edit_def[index];
         
         id_CopyMac2Rect (form, &tmpRect, &form->ditl_def[index]->i_rect);
         
         // tmpRect = NSMakeRect (macRect.left, macRect.top, macRect.right-macRect.left, macRect.bottom-macRect.top);
         
         // tmpRect = NSOffsetRect (tmpRect, 0., dtGData->toolBarHeight);
         
         if (f_ditl_def->i_type & editText)  {              /* If TE field */
            
            id_adjust_edit_rect (form, index, &tmpRect);
            
            f_ditl_def->i_handle = (Handle) [appDelegate.firstFormHandler coreCreateEditFieldWithFrame:id_Rect2CGRect(&tmpRect)
                                                                                                inForm:form];
            TExSetAlignment ((NSTextField *)f_ditl_def->i_handle, form->edit_def[index]->e_justify);
            // id_create_edit (form, index, savedPort);
            if (f_edit_def->e_fld_edits & ID_FE_LINE_UNDER)  {
               [((NSTextField *)f_ditl_def->i_handle).cell setBordered:NO];
               [((NSTextField *)f_ditl_def->i_handle).cell setBezeled:NO];
            }
            ((NSTextField *)f_ditl_def->i_handle).tag = index + 1;
            
            id_my_edit_layout (form, index);
            
            if (form->cur_fldno < 0)
               form->cur_fldno = index;
            if (!form->TE_handle)
               form->TE_handle = (NSTextField *)f_ditl_def->i_handle;
         }
         else  if (f_ditl_def->i_type & statText)  {              /* If static text / label */
            
            id_adjust_stat_rect (form, index, &tmpRect);

            // tmpRect = NSOffsetRect (tmpRect, 2., 2.);  // I need adjust_stat_Rect() or something like that

            f_ditl_def->i_handle = (Handle) [appDelegate.firstFormHandler coreCreateLabelWithFrame:id_Rect2CGRect(&tmpRect)
                                                                                             inForm:form];
            TExSetAlignment ((NSTextField *)f_ditl_def->i_handle, form->edit_def[index]->e_justify);

            CFStringRef  labelText = id_Mac2CFString (f_ditl_def->i_data.d_text, &labelText, f_ditl_def->i_data_size);
            
            [((NSTextField *)f_ditl_def->i_handle).cell setFont:[NSFont fontWithName:@"Lucida Grande" size:10]];
            
            [(NSTextField *)f_ditl_def->i_handle setStringValue:(NSString *)labelText];

            // id_create_stat (form, index, savedPort);
            CFRelease (labelText);
            id_my_stat_layout (form, index);
         }
         else  if (f_ditl_def->i_type & ctrlItem)  {
            
            short  pureIType = f_ditl_def->i_type & 127, itsaControl = TRUE;
            
            id_adjust_button_rect (form, index, &tmpRect);

            CFStringRef  buttonTitle = id_Mac2CFString (f_ditl_def->i_data.d_text, &buttonTitle, f_ditl_def->i_data_size);
            
            if (pureIType == (ctrlItem+btnCtrl))  {       /* Simple Button */
               f_ditl_def->i_handle = (Handle) [appDelegate.firstFormHandler coreCreateButtonWithFrame:id_Rect2CGRect(&tmpRect)
                                                                                                inForm:form
                                                                                                 title:(NSString *)buttonTitle];
            }
            else  if (pureIType == (ctrlItem+chkCtrl))  {  /* Check Box */
               
               f_ditl_def->i_handle = (Handle) [appDelegate.firstFormHandler coreCreateCheckBoxWithFrame:id_Rect2CGRect(&tmpRect)
                                                                 inForm:form
                                                                  title:(NSString *)buttonTitle];
            }
            else  if (pureIType == (ctrlItem+radCtrl))  {  /* Radio Control */
               f_ditl_def->i_handle = (Handle) [appDelegate.firstFormHandler coreCreateRadioButtonWithFrame:id_Rect2CGRect(&tmpRect)
                                                                    inForm:form
                                                                     title:(NSString *)buttonTitle];
            }
            else
               itsaControl = FALSE;
            CFRelease (buttonTitle);
            id_set_system_layout (form, index);
         }
         else  if ((f_ditl_def->i_type & 127) == userItem)  {
            
            id_adjust_popUp_rect (form, index, &tmpRect);
            
            if (f_edit_def && f_edit_def->e_type == ID_UT_POP_UP)  {
               
               f_ditl_def->i_handle = (Handle) [appDelegate.firstFormHandler coreCreatePopUpWithFrame:id_Rect2CGRect(&tmpRect)
                                                                                                inForm:form];
               if (f_edit_def->e_entry_func)  {
                  retVal = (*f_edit_def->e_entry_func)(form, index+1, f_edit_def->e_occur, ID_ENTRY_FLAG);
                  if (!retVal)
                     id_resetPopUpMenu (form, index);
               }
               id_my_popUp_layout (form, index);
               
               // id_create_popUp (form, index, savedPort);
               form->usedETypes |= ID_UT_POP_UP;
            }
            
            else  if (f_edit_def->e_type & ID_UT_LIST)  {
               
               // id_create_list (form, index, savedPort);
               id_my_list_layout (form, index);
               form->usedETypes |= ID_UT_LIST;
            }
            
            else  if (f_edit_def->e_type == ID_UT_SCROLL_BAR)  {
               // id_create_scrollBar (form, index, savedPort);
               form->usedETypes |= ID_UT_SCROLL_BAR;
            }
            
            else  if (f_edit_def->e_type == ID_UT_ICON_ITEM)  {
               id_create_iconItem (form, index, /*savedPort*/NULL);
               form->usedETypes |= ID_UT_ICON_ITEM;
            }

            else  if (f_edit_def->e_type == ID_UT_PICTURE)  {  // Yes, it should be id_create_picture(), this is wrong
               id_draw_Picture (form, index);
               // id_create_picture (form, index, savedPort);
               form->usedETypes |= ID_UT_PICTURE;
            }
            
            else  if (f_edit_def->e_type == ID_UT_TEPOP_PICT)  {
               // id_create_tePop (form, index, savedPort);
               form->usedETypes |= ID_UT_TEPOP_PICT;
            }
         }
      } /* end of for */
      
      [MainLoop finalizeFormWindow:form];
      
      [newWin makeKeyAndOrderFront:NSApp/*appDelegate.firstFormHandler*/];
   }
   
   return (0);
}

#pragma mark -

int  attach_kd_kupdob (
 FORM_REC  *form,
 int        fldno,
 int        offset,
 int        mode
)
{
   short        index=fldno-1;

   if (mode==ID_ENTRY_FLAG)  {
   }
   else  if (mode==ID_EXIT_FLAG)  {
   }

   return (0);
}


int  attach_kd_12x_pop (
 FORM_REC  *form,
 int        fldno,
 int        offset,
 int        mode
)
{
   static char *ktoPopList[2] = { "120", "121" };
   short        index=fldno-1;
   
   // strcpy (ktoPopList[0], gGStr120);
   // strcpy (ktoPopList[1], gGStr121);

   if (mode==ID_ENTRY_FLAG)  {
      form->edit_def[index]->e_array = ktoPopList;
   }
   return (0);
}

int  attach_kd_22x_pop (
 FORM_REC  *form,
 int        fldno,
 int        offset,
 int        mode
)
{
   static char *ktoPopList[2] = { "220", "221" };
   short        index=fldno-1;
   
   // strcpy (ktoPopList[0], gGStr220);
   // strcpy (ktoPopList[1], gGStr221);
   
   if (mode==ID_ENTRY_FLAG)  {
      form->edit_def[index]->e_array = ktoPopList;
   }
   
   return (0);
}

/* ................................................. attach_pr_r1r2_pop ............. */

int  attach_pr_r1r2_pop (
 FORM_REC  *form,
 int        fldno,
 int        offset,
 int        mode
)
{
   static char *r12PopList[4] = { "NPO", "R-1", "R-2", "OPN" };
   short  index=fldno-1;
   
   if (mode==ID_ENTRY_FLAG)  {
      form->edit_def[index]->e_array = r12PopList;
      form->edit_def[index]->e_elems = 4;
   }
   
   return (0);
}

#pragma mark -

int  id_alertErr (const char *message, const char *const info)
{
   int       result;
   NSAlert  *alert = [[NSAlert alloc] init];
   
   alert.alertStyle = NSCriticalAlertStyle;
   alert.messageText = [NSString stringWithCString:message encoding:NSUTF8StringEncoding];
   alert.informativeText = [NSString stringWithCString:info encoding:NSUTF8StringEncoding];
   
   alert.icon = [NSImage imageNamed:@"Bouquet512"];
   
   result = (int)[alert runModal];
   
   [alert release];
   
   return (result);
}

NSString  *id_Result2Msg (int result)
{
   switch (result)  {
      case  NSAlertDefaultReturn:  return (@"Default");  
      case  NSAlertAlternateReturn:  return (@"Alternate");  
      case  NSAlertOtherReturn:  return (@"Other");  
   }
   
   return (@"No idea!");
}

