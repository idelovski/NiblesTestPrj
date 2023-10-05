//
//  MainLoop.m
//  NiblessTest
//
//  Created by me on 16.07.23.
//  Copyright 2023 Delovski d.o.o. All rights reserved.
//

#define _MAIN_LOOP_SRC_

#import  "MainLoop.h"

#import  "DTOverlayView.h"
#import  "GetNextEvent.h"
#import  "NiblessTestAppDelegate.h"
#import  "FirstForm.h"

#import  "Bouquet.h"

// LOCAL GLOBALS

static EDIT_item  default_edit_item = { 
   0,             0, 240, 2, 0, 0, teJustLeft, 0,
   NULL, NULL, NULL,
   NULL, NULL 
};

// GLOBALS

DTGlobalData     *dtGData = NULL;
FORM_REC         *dtMainForm = NULL;
FORM_REC         *dtDialogForm = NULL;
FORM_REC         *dtRenderedForm = NULL;

static int  pr_InspectMenu (short theMenuID);  // 129 is File menu
static int  pr_CreateMenu (NSMenu *menuBar, id target, short theMenuID);  // 129 is File menu
static int  pr_InsertSubMenu (NSMenuItem *parentMenuItem, id target, short theMenuID);

static int  id_InitStatusbarIcons (void);
static int  id_DrawStatusbarText (FORM_REC *form, short statPart, char *statusText);
static int  id_DrawTBPopUp (FORM_REC  *form);

// extern EventRecord  gGSavedEventRecord;

@implementation MainLoop

#pragma mark Menu

static FORM_REC  theMainForm;

+ (void)handleApplicationDidFinishLaunchingWithAppDelegate:(NiblessTestAppDelegate *)appDelegate
{
   id_InitDTool (0/*idApple*/, 0/*idFile*/, 0/*idEdit*/, NULL);
   
   appDelegate.window = [MainLoop openInitialWindowAsForm:&theMainForm];
   
   appDelegate.firstFormHandler = [[FirstForm alloc] initWithWindow:appDelegate.window];
   
   [appDelegate.firstFormHandler performSelector:@selector(runMainLoop) withObject:nil afterDelay:.1];
   
   [appDelegate.window makeKeyAndOrderFront:NSApp];
}

+ (NSWindow *)openInitialWindowAsForm:(FORM_REC *)form
{
   NSWindow  *aWindow;
	// Insert code here to initialize your application
   
   CGFloat  menuBarHeight = NSStatusBar.systemStatusBar.thickness;
   NSRect   availableFrame = [NSScreen mainScreen].visibleFrame;  // Seems to be area above the dock
   
   id_init_form (form);

   availableFrame.origin.y += menuBarHeight;
   availableFrame.size.height -= menuBarHeight;
      
   NSLog (@"Menu bar height: %.0f", menuBarHeight);
   NSLog (@"Screen Frame orig: %@", NSStringFromRect ([NSScreen mainScreen].frame));
   NSLog (@"Visible Frame orig: %@", NSStringFromRect (availableFrame));
   NSLog (@"Screen Frame normal: %@", NSStringFromRect (id_CocoaRect(nil, availableFrame)));
   NSLog (@"Back to orig Frame: %@", NSStringFromRect (id_CarbonRect(nil, id_CocoaRect(nil, availableFrame))));
   
   
   NSRect  winFrame = NSMakeRect (100, 64, 640, 390);
   
   aWindow = [[[NSWindow alloc] initWithContentRect:id_CocoaRect(nil, winFrame)
                                               styleMask:NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
                                                 backing:NSBackingStoreBuffered
                                                   defer:NO] autorelease];
   
   dtMainForm = form;
   
   form->my_window = aWindow;
   
   CGRect  viewFrame = { { 0, 0 }, { winFrame.size.width, winFrame.size.height } };
   // viewFrame.size = winFrame.size;

   NSView  *backView = [[DTBackView alloc] initWithFrame:viewFrame];
   // NSView  *foreView = [[DTOverlayView alloc] initWithFrame:viewFrame];  // Find a way to put it on top
   
   [aWindow setContentView:backView];
   // [backView addSubview:foreView positioned:NSWindowAbove relativeTo:nil];
   
   [backView release];
   // [foreView release];
   
   [aWindow setTitle:@"Bouquet"];
   
   [aWindow setBackgroundColor:[NSColor windowBackgroundColor]];
   // [aWindow makeKeyAndOrderFront:NSApp];
   
   // [aWindow setContentBorderThickness:24.0 forEdge:NSMinYEdge];  - WTF, ovo treba bit statusBar ali NOPE!
   
   return ([aWindow autorelease]);
}

+ (void)finalizeFormWindow:(FORM_REC *)form
{
   // TEMP HERE
   id_create_toolbar (form);
   if (form->toolBarHandle)
      id_DrawIconToolbar (form);
   // TEMP HERE ^
   
   NSRect   winFrame = form->my_window.frame;
   NSView  *winView = form->my_window.contentView;
   // Just an illustration - contentFrame but in screen coordinates:
   // NSRect   contentFrame = [form->my_window contentRectForFrameRect:[form->my_window frame]];
   
   CGRect  viewFrame = winView.bounds;  // { { 0, 0 }, { winFrame.size.width, winFrame.size.height } };
   // viewFrame.size = winFrame.size;

   NSView  *foreView = [[DTOverlayView alloc] initWithFrame:viewFrame];  // Put it on top
   
   [(NSView *)form->my_window.contentView addSubview:foreView positioned:NSWindowAbove relativeTo:nil];
   
   form->overlayView = foreView;
   
   [foreView release];

   if (form->update_func)
      (*form->update_func)(form, NULL, ID_END_OF_OPEN, 0);
}

+ (void)menuAction:(id)sender
{
   short  theMenu, theItem;
   
   
   NiblessTestAppDelegate  *appDelegate = (NiblessTestAppDelegate *)[NSApp delegate];
   NSDictionary            *menuDict = appDelegate.menuDict;

   // Rect  tmpRect;
   
   NSLog (@"%@", sender);
   
   NSMenu      *menuBar = [NSApp mainMenu];
   NSMenuItem  *menuItem = (NSMenuItem *)sender;
   NSMenu      *superMenu = [menuItem menu];
   NSMenuItem  *parentItem = [menuItem parentItem];
   
   NSInteger    menuIndex = [menuBar indexOfItem:parentItem];
   NSInteger    itemIndex = [superMenu indexOfItem:menuItem];
   
   NSNumber  *num = [menuDict valueForKey:superMenu.title];
   
   if (num)
      NSLog (@"Menu index: %d, itemIndex: %d", [num intValue], (int)itemIndex);
   else
      NSLog (@"Menu index: %d, itemIndex: %d", (int)menuIndex+128, (int)itemIndex);
   
   theMenu = HiWord ((UInt32)menuItem.tag);
   theItem = LoWord ((UInt32)menuItem.tag);
   
   NSLog (@"ALT MenuId: %hd, itemId: %hd", theMenu, theItem);
   
   if ((theMenu == Wind_MENU_ID) || (theMenu == Matpod_SMENU_ID))  {
      pr_OpenKupdob ();
   }
   else  if (theMenu == File_MENU_ID)  {
      FORM_REC  *form = id_FindForm (FrontWindow());
      
      if (form && (theItem == CLOSE_Command))
         [form->my_window performClose:menuItem];
   }
   else  if (theMenu == Edit_MENU_ID)  {
      FORM_REC  *form = id_FindForm (FrontWindow());
      
      if (form && form->TE_handle)  {
         NSText  *fieldEditor = form->TE_handle.currentEditor;
         
         if (theItem == undoCommand)  {
            if ([[fieldEditor undoManager] canUndo])
               [[fieldEditor undoManager] undo];
         }         
         if (theItem == copyCommand)
            [fieldEditor copy:menuItem];
         else  if (theItem == pasteCommand)
            [fieldEditor paste:menuItem];
         else  if (theItem == cutCommand)
            [fieldEditor cut:menuItem];
      }
   }
   else
      id_PostMenuEvent (theMenu, theItem);
} 

+ (void)buildMainMenu
{
   char   appName[256];
   FSRef  appParentFolderFSRef;

   NiblessTestAppDelegate  *appDelegate = (NiblessTestAppDelegate *)[NSApp delegate];
   NSMutableDictionary    *menuDict = appDelegate.menuDict;

   if (!id_GetApplicationExeFSRef(&appParentFolderFSRef))  {
      if (!id_ExtractFSRef(&appParentFolderFSRef, appName, nil/*&parentFSRef*/))
         NSLog (@"AppName: %s", appName);
   }

#ifdef _RES_FORK_
   char   rsrcName[256], pathStr[256];
   FSRef  rsrcFSRef, appRsrcFSRef;
   if (!id_GetMyApplicationResourcesFSRef(&rsrcFSRef))  {
      if (id_ExtractFSRef(&rsrcFSRef, rsrcName, nil))
         rsrcName[0] = '\0';
      if (FSRefMakePath(&rsrcFSRef, (UInt8 *)pathStr, 256))
         pathStr[0] = '\0';
      snprintf (pathStr+strlen(pathStr), 256-strlen(pathStr), "/%s.rsrc", appName);
      NSLog (@"Resource path: %s %s", pathStr, rsrcName);
      
      if (!FSPathMakeRef((const UInt8 *)pathStr, &appRsrcFSRef, NULL))  {
         ResFileRefNum  resRefNum;
         
         OSErr  err = FSOpenResourceFile (&appRsrcFSRef, 0, NULL, fsRdPerm, &resRefNum);
         
         if (!err)
            return ((short)resRefNum);
      }
   }
#endif   
   
   // **** Menu Bar **** //
   NSMenu      *menubar = [NSMenu new];
   NSMenuItem  *tmpMenuItem;
   
   [NSApp setMainMenu:menubar];
   
   // **** App Menu **** //
   NSMenuItem  *appMenuItem = [NSMenuItem new];
   NSMenu      *appMenu = [[NSMenu alloc] initWithTitle:[NSString stringWithFormat:@"%s", appName]];
   
   [menuDict setObject:[NSNumber numberWithInt:128] forKey:appMenu.title];
   
   // [appMenu setTag:128];
   
   NSString  *title = [NSString stringWithFormat:@"About %s", appName];         // About
   [appMenu addItemWithTitle:title action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];
   [appMenu addItem:[NSMenuItem separatorItem]];
   
   [appMenu addItemWithTitle:@"Preferences..." action:nil keyEquivalent:@","];  // Prefs
   
   [appMenu addItem:[NSMenuItem separatorItem]];
   
   NSMenu  *serviceMenu = [[NSMenu alloc] initWithTitle:@""];                   // Services
   tmpMenuItem = (NSMenuItem *)[appMenu addItemWithTitle:@"Services" action:nil keyEquivalent:@""];
   [tmpMenuItem setSubmenu:serviceMenu];
   
   [NSApp setServicesMenu:serviceMenu];
   [serviceMenu release];
   
   [appMenu addItem:[NSMenuItem separatorItem]];
   
   title = [NSString stringWithFormat:@"Hide %s", appName];         // About 
   [appMenu addItemWithTitle:title action:@selector(hide:) keyEquivalent:@"h"]; 
   
   tmpMenuItem = (NSMenuItem *)[appMenu addItemWithTitle:@"Hide Others" action:@selector(hideOtherApplications:) keyEquivalent:@"h"]; 
   [tmpMenuItem setKeyEquivalentModifierMask:(NSAlternateKeyMask|NSCommandKeyMask)]; 
   
   [appMenu addItemWithTitle:@"Show All" action:@selector(unhideAllApplications:) keyEquivalent:@""]; 
   
   [appMenu addItem:[NSMenuItem separatorItem]];
   
   tmpMenuItem = [appMenu addItemWithTitle: @"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
   [tmpMenuItem setTarget:NSApp];
   
   [appMenuItem setSubmenu:appMenu];
   [menubar addItem:appMenuItem];
   
   pr_CreateMenu (menubar, self, 129);
   pr_CreateMenu (menubar, self, 130);
   pr_CreateMenu (menubar, self, 131);
   pr_CreateMenu (menubar, self, 132);
   pr_CreateMenu (menubar, self, 133);
   
   // So I will have to make this a bit different as my main menu constants start from 128 (128=AppleMenu, 129=File, etc.)
   // And submenus start from 1. I'll need two arrays, menus & subMenus so I don't have to use all of these crazy constants
   
   tmpMenuItem = [self findMenuItem:130-128 withTag:MakeLong(8,130)];  // Osobnosti
   if (tmpMenuItem)
      pr_InsertSubMenu (tmpMenuItem, self, 12);
   
   tmpMenuItem = [self findMenuItem:130-128 withTag:MakeLong(11,130)];  // Hyper
   if (tmpMenuItem)
      pr_InsertSubMenu (tmpMenuItem, self, 14);

   tmpMenuItem = [self findMenuItem:130-128 withTag:MakeLong(13,130)];  // IBAN
   if (tmpMenuItem)
      pr_InsertSubMenu (tmpMenuItem, self, 13);

   tmpMenuItem = [self findMenuItem:133-128 withTag:MakeLong(3,133)];  // Matpod
   if (tmpMenuItem)
      pr_InsertSubMenu (tmpMenuItem, self, 1);
   tmpMenuItem = [self findMenuItem:133-128 withTag:MakeLong(4,133)];  // Skladno
   if (tmpMenuItem)
      pr_InsertSubMenu (tmpMenuItem, self, 2);
   tmpMenuItem = [self findMenuItem:133-128 withTag:MakeLong(6,133)];  // Robno
   if (tmpMenuItem)
      pr_InsertSubMenu (tmpMenuItem, self, 3);
   tmpMenuItem = [self findMenuItem:133-128 withTag:MakeLong(7,133)];  // Matno
   if (tmpMenuItem)
      pr_InsertSubMenu (tmpMenuItem, self, 4);

   tmpMenuItem = [self findMenuItem:133-128 withTag:MakeLong(9,133)];  // Ostalo
   if (tmpMenuItem)
      pr_InsertSubMenu (tmpMenuItem, self, 5);
   
#ifdef _NIJE_
   // **** File Menu **** //
   NSMenuItem  *fileMenuItem = [NSMenuItem new];
   NSMenu      *fileMenu = [[NSMenu alloc] initWithTitle:@"File"];
   
   tmpMenuItem = [fileMenu addItemWithTitle:@"New" action:@selector(menuAction:) keyEquivalent:@""];
   [tmpMenuItem setTarget:self];
   // [tmpMenuItem setEnabled:YES];
   [fileMenu addItemWithTitle:@"Open" action:@selector(menuAction:) keyEquivalent:@""];
   [fileMenu addItemWithTitle:@"Save" action:@selector(menuAction:) keyEquivalent:@""];
   [fileMenu addItem: [NSMenuItem separatorItem]];
   tmpMenuItem = [fileMenu addItemWithTitle: @"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
   [tmpMenuItem setTarget: NSApp];
   
   [fileMenuItem setSubmenu: fileMenu];
   [menubar addItem: fileMenuItem];
#endif  // _NIJE_
}

+ (NSMenuItem *)findMenuItem:(NSInteger)itemsMenuIndex withTag:(NSInteger)itemsTag
{
   NSMenu  *mainMenu = [NSApp mainMenu];
   NSMenu  *theMenu = [[mainMenu itemAtIndex:itemsMenuIndex] submenu]; // app menu=0, then file menu
   
   for (int i=0; i<[theMenu numberOfItems]; i++)  {
      NSMenuItem  *mi = [theMenu.itemArray objectAtIndex:i];
      // BOOL         hasSubmenu = [mi hasSubmenu];
      
      if (mi.tag == itemsTag)
         return (mi);
   }
   
   return (nil);
}

+ (BOOL)drawImage:(NSImage *)image
          inFrame:(CGRect)imgFrame
             form:(FORM_REC *)form
{
   NSRect  fromRect = { { 0, 0 }, .size = image.size };
   
   [image drawInRect:imgFrame fromRect:fromRect operation:NSCompositeCopy fraction:1. respectFlipped:YES hints:nil];
   
   return (YES);
}

+ (void)resizeControl:(NSControl *)aControl
               inForm:(FORM_REC *)form
           toNewRatio:(short)ratio
{
   // NSPopUpButton  *btn = (NSPopUpButton *)sender;
   // NSWindow       *win = aControl.window;
   CGRect  ctlRect = aControl.frame;
   short   oldRatio = form->scaleRatio;
   
   CGRect  origRect = CGRectMake (ctlRect.origin.x * 100 / oldRatio, ctlRect.origin.y * 100 / oldRatio, ctlRect.size.width * 100 / oldRatio, ctlRect.size.height * 100 / oldRatio);
   
   CGRect  newRect = CGRectMake (origRect.origin.x * ratio / 100, origRect.origin.y * ratio / 100, origRect.size.width * ratio / 100, origRect.size.height * ratio / 100);
   
   // win.frame = newRect;
   
   // newRect.origin.y -= newRect.size.height - ctlRect.size.height;
   
   aControl.frame = newRect;
}

@end

#pragma mark -

BOOL  id_MainLoop (FORM_REC *mainForm)
{
   short  index, theMenu, theItem;
   Point  myPt;
   Rect   tmpRect;
   BOOL   done = FALSE;
   
   EventRecord  evtRecord;
   FORM_REC    *form = NULL;

   DITL_item  *f_ditl_def;
   EDIT_item  *f_edit_def;

   do  {
      
      id_GetNextEvent (&evtRecord, 500.);

      // NSLog (@"One tick!...");
      
      if (evtRecord.what == mouseDown)  {
         
         form = id_FindForm ((NSWindow *)evtRecord.message);
         
         dtGData->lastEventTick = evtRecord.when;
         GetDateTime (&dtGData->lastEventDateTime);
         
         if (form && form->ditl_def)  {
            
            myPt = evtRecord.where;
            id_GlobalToLocal (form, &myPt);
            
            for (index=0; index<=form->last_fldno; index++)  {
               f_ditl_def = form->ditl_def[index];
               f_edit_def = form->edit_def[index];
               
               if ((f_ditl_def->i_type == editText) && form->TE_handle)  {
                  
                  id_itemsRect (form, index, &tmpRect);
                  if (PtInRect(myPt, &tmpRect))  {
                     NSLog (@"Hey, click inside an edit field!");
                     
                     if (form->cur_fldno == index)  {    /* If current */
                        TExClick (myPt, evtRecord.modifiers, &evtRecord, form->TE_handle);
                     }
                     else  {
                        // GetFontInfo (&fntInfo);
                        if (id_TE_change(form, index, NULL, NULL/*savedPort*/, FALSE, TRUE))
                           break;
                        else
                           TExClick (myPt, 0, &evtRecord, form->TE_handle);
                     }
                     
                     // id_TE_change (form, index, NULL, NULL/*savedPort*/, TRUE, FALSE);  // sel, mouse
                  }
               }
            }
         }
      }
      else  if (evtRecord.what == keyDown)  {
         UniChar  uch;
         
         form = id_FindForm (FrontWindow());
         
         id_CharToUniChar (evtRecord.message, &uch);
         
         NSLog (@"Key in keyDown: %C %hu", uch, (unsigned short)evtRecord.message);
         
         if ((form->TE_handle && form->ditl_def) && (form->pen_flags & ID_PEN_DOWN) && (evtRecord.message == '\t'))  {
            
            if (evtRecord.modifiers & shiftKey)
               index = id_find_prev_fld (form);
            else               
               index = id_find_next_fld (form);
            
            if (index != form->cur_fldno)
               id_TE_change (form, index, NULL, NULL/*savedPort*/, TRUE, FALSE);  // sel, mouse
            
            // retValue = form->cur_fldno+1;
         }
         else  if (evtRecord.message == kEscapeCharCode)
            [form->my_window performClose:NSApp];

      }
      else  if (evtRecord.what == activateEvt)  {
         // Well, this was an attempt but in vain!
         // If we're coming back from behind SelectWindow will not change anything for some reason so just put everything behind remarks
         NSWindow  *window = (NSWindow *)evtRecord.message;
         NSLog (@"ActivateEvt: %@ [%@] %d",
                evtRecord.modifiers ? @"Activate" : @"Deactivate",
                window.title,
                evtRecord.when
                );
         /* form = id_FindForm (window);
         if (evtRecord.modifiers && form->my_window != [NSApp keyWindow])  {
            if (!dtGData->appInBackground)
               SelectWindow (form->my_window);
         } */
      }
      else  if (id_IsMenuEvent(&evtRecord, 0, &theMenu, &theItem))  {
         NSLog (@"Yes, it was a menu event!");
         
         form = id_FindForm (FrontWindow());
         
         if (form && form->ditl_def)  {
            if (theMenu == File_MENU_ID && theItem == NEW_Command)
               id_pen_down (form, K_KUPDOB);
            else  if (theMenu == File_MENU_ID && theItem == OPEN_Command)
               id_pen_down (form, K_KUPDOB);
            else  if (theMenu == File_MENU_ID && theItem == SAVE_Command)
               id_pen_up (form);
         }
      }
      
      // if (evtRecord.what == keyDown && evtRecord.message == 'q')
      //   done = TRUE;
      
      // This is wrong as it only works with initial form, so I need a concept of top form...
      // Until then, use FrontWindow();
      
      if ((form=id_FindForm(FrontWindow())) == mainForm)  {
      
         if (evtRecord.what == keyDown && evtRecord.message == '\t')  {
            NSLog (@"Tab!");
            
            /*if (mainForm->leftField.currentEditor == form->my_window.firstResponder)  {
               NSLog (@"Left had Focus");
               [form->my_window makeFirstResponder:form->rightField];
               // [form->rightField becomeFirstResponder];
            }
            else  if (form->rightField.currentEditor == form->my_window.firstResponder)  {
               NSLog (@"Right has Focus");
               [form->my_window makeFirstResponder:form->bigField];
               // [form->leftField becomeFirstResponder];
            }
            else  if (form->bigField.currentEditor == form->my_window.firstResponder)  {
               NSLog (@"Big has Focus");
               [form->my_window makeFirstResponder:form->leftField];
               // [form->leftField becomeFirstResponder];
            }*/
            
            if (form->leftField.window == form->my_window)
               NSLog (@"My man!");
         }
      }
   
   } while (!done);

   return (YES);
}

#pragma mark - dTOOL

/* ................................................... id_InitDTool ................. */

int  id_InitDTool (   // rev. 13.04.05
 short  idApple,
 short  idFile,
 short  idEdit,
 int  (*errLogSaver) (char *, char *, char, char)
)
{
   FSRef  appParentFolderFSRef, parentFSRef, bundleParentFolderFSRef;
   char   fileName[256], pathStr[256];
   char   compName[128], userName[256];
   
   // NSMenu      *mainMenu = [NSApp mainMenu];
   // NSMenuItem  *subMenu = [mainMenu itemAtIndex:0];
   // MenuHandle  *menuHandle = (MenuHandle *)mainMenu;
   
   // NSLog (@"Menu title: %@", [((NSMenu *)menuHandle) title]);
   // NSLog (@"Menu title: %@", [((NSMenu *)subMenu) title]);
   
   // HFileParam
   
   if (!dtGData)
      if ((dtGData = (DTGlobalData*)NewPtr (sizeof(DTGlobalData))) == NULL)  ExitToShell ();
   
   id_SetBlockToZeros (dtGData, sizeof(DTGlobalData));
   
   if (!id_GetApplicationExeFSRef(&appParentFolderFSRef))  {
      if (FSRefMakePath(&appParentFolderFSRef, (UInt8 *)pathStr, 256))
         pathStr[0] = '\0';
      if (!id_ExtractFSRef(&appParentFolderFSRef, fileName, &parentFSRef))
         NSLog (@"Converted path: %s %s", pathStr, fileName);
   }
   
   if (!id_GetApplicationParentFSRef(&bundleParentFolderFSRef))  {
      if (FSRefMakePath(&bundleParentFolderFSRef, (UInt8 *)pathStr, 256))
         pathStr[0] = '\0';
      if (!id_ExtractFSRef(&bundleParentFolderFSRef, fileName, &parentFSRef))
         NSLog (@"Converted path: %s %s", pathStr, fileName);
      
      if (!id_SetDefaultDir(&bundleParentFolderFSRef))  {
         short   rCount, rID, rfRefNum = 0;
         ResType rType;
         Handle  rHandle;
         Str255  rName;
         
         snprintf (fileName, 256, "%s/%s", pathStr, "Appl_KnjigeNT.rsrc");
         rfRefNum = OpenResFile (fileName);
         
         if (rfRefNum > 0)  {
            rCount = Count1Resources ('DITL');

            rHandle = Get1IndResource ('DITL', 1);
            GetResInfo (rHandle, &rID, &rType, rName);
            // resSize = GetHandleSize (rHandle);
            
            if (rID > 0)  {
               FORM_REC  tmpForm;
               
               NSLog (@".... DITL%04hd.dil", rID);
               
               if (tmpForm.DITL_handle=GetResource('DITL', rID))  {
               
                  tmpForm.last_fldno = *((short *)(*tmpForm.DITL_handle));
                  NSLog (@".... last_fldno: %hd", tmpForm.last_fldno);
                  
                  if (!(tmpForm.ditl_def = (DITL_item **) id_malloc_array (tmpForm.last_fldno+1, sizeof (DITL_item))))  {
                     ReleaseResource (tmpForm.DITL_handle);
                  }
                  else  {
                     HLock (tmpForm.DITL_handle);
                     id_copy_DITL_info (tmpForm.ditl_def, tmpForm.DITL_handle);
                     HUnlock (tmpForm.DITL_handle);
                     NSLog (@".... WOW!");
                  }
               }
            }
            
            pr_InspectMenu (129);
            
            // errno = 0;
            
            ReleaseResource (rHandle);
         }
         
         CloseResFile (rfRefNum);
      }
   }
   
   TestVersion ();
   // pr_ListFonts ();
   pr_ListEncodings ();
   
   id_InitStatusbarIcons ();
   
   if (!id_InitComputerName (compName, 128))
      NSLog (@"Computer: %s", compName);
   if (!id_InitComputerUserName (userName, 128))
      NSLog (@"User: %s", userName);
   
   dtGData->appInBackground = FALSE;
   
   dtGData->modalFormsCount = 0;
   
   dtGData->statusBarHeight = 20;  // On Win98...
   dtGData->toolBarHeight   = kTB_ICN_HEIGHT;
   
   id_SetUpLayout (&dtGData->layStat, systemFont, 12, 0);
   id_SetUpLayout (&dtGData->layEdit, geneva, 9, bold);
   id_SetUpLayout (&dtGData->layComm, geneva, 9, 0);
   id_SetUpLayout (&dtGData->layList, systemFont, 12, 0);
   
   id_SetBlockToZeros (&dtGData->eventRecord[0], sizeof(EventRecord)*kEVENTS_STACK);
   id_SetBlockToZeros (dtGData->eventsUsed, kEVENTS_STACK);

#ifdef _ONE_DAY_
   short   applResRef, resErr;
   DWORD   maxLen = 255;
   char    dToolFName[256];
   HANDLE  hAccelerators;
   
   WNDCLASS     wndclass;
   
   if (!dtGData)  {
      wndclass.lpszClassName = TEXT("DTWndClass");
      wndclass.style         = CS_HREDRAW | CS_VREDRAW;
      wndclass.lpfnWndProc   = DTWndProc;
      wndclass.cbClsExtra    = 0;
      wndclass.cbWndExtra    = 0;
      wndclass.hInstance     = gGDThInstance;
      wndclass.hIcon         = LoadIcon (gGDThInstance, TEXT("AAPL_ICON"));
      wndclass.hCursor       = LoadCursor (NULL, IDC_ARROW);
      wndclass.hbrBackground = (HBRUSH) GetStockObject (WHITE_BRUSH);  // or use COLOR_WINDOW + 1 ?!!
      wndclass.lpszMenuName  = TEXT("MenuDTool");  // once it was param menuName
      //- wndclass.lpszMenuName  = TEXT("MENUHZMOKAM");
      
      if (!RegisterClass (&wndclass))  {
         MessageBox (NULL, TEXT ("Program requires Windows NT!"), TEXT("dTOOL Application"), MB_ICONERROR) ;
         return (0);
      }
      
      wndclass.lpszClassName = TEXT("DTDlgClass");
      wndclass.hIcon         = NULL;  // Dialogs need no icon!  // LoadIcon (hInstance, TEXT("AAPL_ICON"));
      wndclass.lpszMenuName  = NULL;  // Dialogs...
      
      if (!RegisterClass (&wndclass))  {
         MessageBox (NULL, TEXT ("Program requires Windows NT!"), TEXT("dTOOL Application"), MB_ICONERROR) ;
         return (0);
      }
      
      id_InitSysRelatedInfo ();
      
      if ((dtGData = (DTGlobalData*)NewPtr (sizeof(DTGlobalData))) == NULL)  ExitToShell ();
      
      hAccelerators = LoadAccelerators (gGDThInstance, TEXT("MenuDTool"));  // once it was param menuName
      //- hAccelerators = LoadAccelerators (gGDThInstance, TEXT("MENUHZMOKAM"));  // once it was param menuName
      
      dtGData->hInstance     = gGDThInstance;
      dtGData->hAccelerators = hAccelerators;
      
#ifdef _OVO_MOZDA_NI_NA_MACU_NE_TREBA_    
      if (!Get1Resource('DITL', 256))  {
         applResRef = CurResFile ();
         strcpy (dToolFName, "Macintosh HD:dTOOL ? PDV:dTOOL_All.rsrc");
         CtoPstr (dToolFName);
         resErr = OpenResFile ((StringPtr)dToolFName);
         /*UseResFile (applResRef);*/
      }
#endif
      dtGData->unDoFlag = ID_UNDO_OFF;
      
#ifdef _NIJE_
      dtGData->mbi.mhApple = mhApple;
      dtGData->mbi.mhFile  = mhFile;
      dtGData->mbi.mhEdit  = mhEdit;   // Only this is needed!
      dtGData->mbi.mhWindows = NULL;
#endif
      
      dtGData->mbi.idApple = idApple;
      dtGData->mbi.idFile  = idFile;   // Only this used in lib!
      dtGData->mbi.idEdit  = idEdit;
      dtGData->mbi.idWindows = 0;
      
      dtGData->mbi.cmdMenuIdx = 0;     // Win version
      
      dtGData->mbi.cmdOpen    = 0;
      dtGData->mbi.cmdFind    = 0;
      dtGData->mbi.cmdAddRow  = 0;
      dtGData->mbi.cmdDelRow  = 0;
      
      dtGData->mbi.startOfAppend = kIDM_Start4Append; // there was startOfAppend param
      
      dtGData->mbi.prgMenuBar_  = NULL;
      dtGData->mbi.prgSubMenus_ = NULL;
      dtGData->commDlgForm    = NULL;  // WinShit! form holding a comm dialog
      dtGData->commDlgHwnd    = NULL;  // WinShit! hwnd holding a comm dialog
      
      dtGData->mBarDisabled   = FALSE;
      dtGData->appInBackground = FALSE;
      dtGData->popUpTracking   = FALSE;
      
      dtGData->unSelStart = dtGData->unSelEnd = 0;
      
      dtGData->tabStyle = ID_TS_ENTER_TAB; // On Win is this, on Mac is ID_TS_DEFAULT
      
      /* Scrap */
      
      dtGData->scrapCount = 0;
      dtGData->scrapTaken  = FALSE;   /* Only for StartUp */
      dtGData->scrapToGive = FALSE;
      
      dtGData->grabText = NULL;
      dtGData->grabCnt = dtGData->grabMax = 0;
      
      dtGData->theInput = NULL;
      
      dtGData->postedMenu = 0;    // to post a menu event
      dtGData->postedItem = 0;
      
      dtGData->appSignature = 0L;
      dtGData->osTypesTable = NULL;
      
      dtGData->lastEventTick = TickCount ();
      
#ifdef _MAYBE_TO_KILL_IT_
      
      id_SetUpLayout (&dtGData->layStat, 0, 0, 0);
      id_SetUpLayout (&dtGData->layEdit, geneva, 9, bold);
      id_SetUpLayout (&dtGData->layComm, geneva, 9, 0);
      id_SetUpLayout (&dtGData->layList, systemFont, 12, 0);
#endif
      
      dtGData->dateStart = 0;
      dtGData->dateEnd   = 0;
      
      dtGData->fbAccessProc   = NULL;
      dtGData->errLogSaveProc = errLogSaver;
      dtGData->errLogActive   = FALSE;
      
      dtGData->quitNow  = FALSE;
      dtGData->uninstallNow  = FALSE;
      dtGData->openFile = FALSE;
      dtGData->inportFile = FALSE;
      
      dtGData->deltaPerLine = dtGData->accumDelta = 0;
      dtGData->statusBarHeight = 20;  // On Win98...
      dtGData->toolBarHeight   = 28;    // On Win98...
      
      dtGData->menuFontAveCharWidth = 8;  // just any number, set in id_InitWinFonts() 
      
      SetPt (&dtGData->mousePos, 0, 0);
      
      id_SetBlockToZeros (&dtGData->eventRecord[0], sizeof(EventRecord)*kEVENTS_STACK);
      id_SetBlockToZeros (dtGData->eventsUsed, kEVENTS_STACK);
      
      // QD stuff
      
      dtGData->solidPen = GetStockObject (BLACK_PEN);       // don't destroy it
      dtGData->whitePen = GetStockObject (WHITE_PEN);       // don't destroy it
      
      if (id_RunningOnWindowsNT())
         dtGData->dotPen = CreatePen (PS_DOT, 1, RGB(0,0,0));  // dotted black pen, destroy it at quit!
      // dtGData->dotPen = CreatePen (PS_ALTERNATE, 1, RGB(0,0,0));  // dotted black pen, destroy it at quit!
      else
         dtGData->dotPen = CreatePen (PS_DOT, 1, RGB(0,0,0));  // dotted black pen, destroy it at quit!
      //dtGData->dotPen = CreatePen (PS_SOLID, 1, RGB(198,198,224));  // dotted black pen, destroy it at quit!
      
      dtGData->dashPen = CreatePen (PS_DASHDOT, 1, RGB(0,0,0));  // dashed black pen, destroy it at quit!
      
      dtGData->redPen    = CreatePen (PS_SOLID, 1, RGB(255,0,0));      // solid red pen, destroy it at quit!
      dtGData->greenPen  = CreatePen (PS_SOLID, 1, RGB(0,255,0));      // solid green pen, destroy it at quit!
      dtGData->bluePen   = CreatePen (PS_SOLID, 1, RGB(148,147,255));  // solid blue pen, destroy it at quit!
      dtGData->yellowPen = CreatePen (PS_SOLID, 1, RGB(148,147,0));    // solid yellow pen, destroy it at quit!
      // dtGData->whitePen = CreatePen (PS_SOLID, 1, RGB(255,255,255));  // solid white pen, !destroy it at quit!
      
      dtGData->liteShdPen = CreatePen (PS_SOLID, 1, GetSysColor(COLOR_BTNHIGHLIGHT));  // light shadow, destroy it at quit!
      dtGData->darkShdPen = CreatePen (PS_SOLID, 1, RGB(0x60, 0x60, 0x60));  // dark shadow, destroy it at quit!
      
      dtGData->menuSetupHandler = NULL;
      
      dtGData->installFlag = FALSE;
      
      strcpy (dtGData->appPath, "");
      strcpy (dtGData->appName, "");
      
      dtGData->fuse_vRefNumStartPrograms = dtGData->fuse_vRefNumAppData = 
      dtGData->fuse_vRefNumProgramFiles = dtGData->fuse_vRefNumNotUsed  = 0;
      
      id_InitStandardGDI ();
      id_InitWinFonts ();
      id_InitThemeXP ();
      id_SetUpCursors ();
      
      id_GetApplicationName (NULL);
      
      GetDateTime (&dtGData->lastEventDateTime);
   }
   
   maxLen = 255;
   if (!GetComputerName (dtGComputerName, &maxLen))
      dtGComputerName[0] = 0;
   maxLen = 255;
   if (!GetUserName (dtGUserName, &maxLen))
      dtGUserName[0] = 0;
   
   id_ResetSavedMWS ();
#ifdef _NOT_YET_IN_WIN_
   id_InitSBTZ ();
#endif
   
   id_LoadLibMySQLDll ();
   id_LoadLibXml2Dll ();
#endif  // _ONE_DAY_
   
   return (0);
}

void  id_SysBeep (short numb)
{
   NSBeep ();
}

/* ................................................... id_init_form ................. */

FORM_REC  *id_init_form (FORM_REC *form)
{
   id_SetBlockToZeros (form, sizeof (FORM_REC));
   
   form->scaleRatio = 100;

   form->pen_flags = ID_PEN_DOWN;

   form->pathsArray = CFArrayCreateMutable (NULL, 0, &kCFTypeArrayCallBacks);
   form->pdfsArray = CFArrayCreateMutable (NULL, 0, &kCFTypeArrayCallBacks);
   
   form->currentFont = [NSFont systemFontOfSize:9.];
   
   form->cur_fldno = form->status_fldno = form->aDefItem = -1;      /* Initialy */
   
   return (form);
}

/* ................................................... id_init_form ................. */

int  id_release_form (FORM_REC *form)
{
   short  index;
   // First check for elements and release each...
   
   if (form->pathsArray)  {
      CFIndex  count = CFArrayGetCount (form->pathsArray);
      
      for (CFIndex i=0; i<count; i++)
         CGPathRelease (CFArrayGetValueAtIndex (form->pathsArray, i));

      CFArrayRemoveAllValues (form->pathsArray);
      CFRelease (form->pathsArray);
   }      
   
   if (form->pdfsArray)
      CFRelease (form->pdfsArray);  // Nothing here that needs special release f()
   
   for (index=0; index<=form->last_fldno; index++)  {
      if (form->ditl_def[index]->i_handle)
         [(NSControl *)form->ditl_def[index]->i_handle release];
   }

   if (form->ditl_def)
      id_free_array ((char **)form->ditl_def);
   if (form->edit_def)
      DisposePtr ((Ptr)form->edit_def);
   
   id_SetBlockToZeros (form, sizeof (FORM_REC));

   // id_init_form (<#FORM_REC *form#>);  -- HM, in the old world I call init at close so here I must be carefull as I allocate stuff in init -> therefore...allocations will happen in id_open_form()
   
   [form->my_window release];
   
   form->my_window = nil;
   
   return (0);
}

/* ................................................... id_FindForm .................. */

FORM_REC  *id_FindForm (NSWindow *nsWindow)
{
#ifdef _NOT_YET_
   WindowPtr  wPtr = (WindowPtr)nsWindow;  // [NSWindow keyWindow]
   FLHandle  theFLH = id_FindWindowInFList (wPtr);
   FORM_REC *formPtr;
   
   if (theFLH)
      formPtr = (*theFLH)->theForm;
   else
      return (NULL);
   
   return (formPtr);
#endif
   
   // NSLog (@"id_FindForm: %@ %d", nsWindow.title, (int)nsWindow.windowNumber);

   if (dtDialogForm && dtDialogForm->my_window == nsWindow)
      return (dtDialogForm);
   if (dtRenderedForm && dtRenderedForm->my_window == nsWindow)
      return (dtRenderedForm);

   // if (dtMainForm && dtMainForm->my_window == nsWindow)
   //    NSLog (@"We have ourseves a window!");
   
   return (dtMainForm);
}

// - (NSWindow *)windowWithWindowNumber:(NSInteger)windowNum;
// - (NSWindow *)mainWindow;
// - (NSWindow *)keyWindow;


NSWindow  *FrontWindow (void)
{
   static NSWindow  *savedFrontWindow = NULL;
   
   NSWindow  *frontWindow = [NSApp mainWindow];
   
   if (!frontWindow)
      frontWindow = [NSApp keyWindow];
   if (!frontWindow)
      frontWindow = savedFrontWindow;
   
   return (savedFrontWindow = frontWindow);
}

void  SelectWindow (NSWindow *win)
{
   NSWindow  *frontWindow = [NSApp mainWindow];
   
   if (!frontWindow)
      frontWindow = [NSApp keyWindow];
   
   if (win != frontWindow)
      [win makeKeyAndOrderFront:NSApp]; // There is - (void)orderWindow:(NSWindowOrderingMode)place relativeTo:(NSInteger)otherWin;
}

// ATM this does not work properly as the Carbon f() as I can't find out what is the my window at the bottom
// -orderWindow:relativeTo: on zero puts my window behind all other apps and I don't need that
// Therefore, I need my own array of windows that is ordered the way they ar on the screen
// Add window on create, remove on close. Plus, as it goes to the front, remove it from array and add so it is the last one

void  SendBehind (NSWindow *ourWin, NSWindow *otherWin)
{
   NSArray  *allWindows = [NSApp windows];
   
   NSWindow  *firstWindow = [allWindows objectAtIndex:0];
   NSWindow  *lastWindow  = allWindows.lastObject;
   
   NSLog (@"Before - Main: %@, Key: %@", [NSApp mainWindow].title, [NSApp keyWindow].title);
   
   id_printWindowsOrder ();
   
   if (allWindows.count > 1)  {
      
      if (!otherWin)
         otherWin = lastWindow;
      
      if (ourWin != otherWin)
         [ourWin orderWindow:NSWindowBelow relativeTo:otherWin.windowNumber];
      NSLog (@"After - Main: %@, Key: %@", [NSApp mainWindow].title, [NSApp keyWindow].title);
      id_printWindowsOrder ();
      if (otherWin)
         [otherWin makeKeyAndOrderFront:NSApp];
   }
}

void  id_printWindowsOrder (void)
{
   NSArray  *allWindows = [NSApp windows];
   
   if (allWindows.count > 1)  {
      for (int i=0; i< allWindows.count; i++)
         NSLog (@"WindowsOrder - Window %d: %@", i, ((NSWindow *)[allWindows objectAtIndex:i]).title);
   }
}

/* ......................................................... id_ExtractFSRef ........ */

int  id_ExtractFSRef (FSRef *srcFSref, char *fileName, FSRef *parentFSRef)
{
   short         maxLen = 255, retVal = -1;
   HFSUniStr255  hfsFileName;
   CFStringRef   cfFileName;
   OSStatus      result;

   result = FSGetCatalogInfo (srcFSref, kFSCatInfoNone, NULL, &hfsFileName, NULL, parentFSRef);
   
   if (!result)  {
      cfFileName = CFStringCreateWithCharacters (NULL, hfsFileName.unicode, hfsFileName.length);
      
      if (cfFileName)  {
         NSLog (@"File path: %@", (NSString *)cfFileName);
         id_CFString2Mac (cfFileName, fileName, &maxLen);

         CFRelease (cfFileName);

         retVal = 0;
      }
   }
   else
      return (result);

   return (retVal);
}

/* ......................................................... id_GetParentFSRef ...... */

OSErr id_GetParentFSRef (const FSRef *fileFSRef, FSRef *parentFSRef)
{
   OSErr osErr = FSGetCatalogInfo (fileFSRef, kFSCatInfoNone, NULL, NULL, NULL, parentFSRef);
   
   return (osErr);
}

/* ......................................................... id_GetFilesFSRef ....... */

OSStatus  id_GetFilesFSRef (const FSRef *parentFSRef, char *fileName, FSRef *fsRef)
{
   OSStatus      result = coreFoundationUnknownErr;
   CFStringRef   fileNameRef;
   UniCharCount  srcLength;
   UniChar       fNameUStr[256];

   // fileNameRef = CFStringCreateWithCString (NULL, fileName, kTextEncodingISOLatin2);  // or kTextEncodingMacRoman
   
   id_Mac2CFString (fileName, &fileNameRef, strlen(fileName));
         
   if (fileNameRef)  {
      srcLength = (UniCharCount) CFStringGetLength (fileNameRef);
      CFStringGetCharacters (fileNameRef, CFRangeMake(0, srcLength), &fNameUStr[0]);
      
      result = FSMakeFSRefUnicode (parentFSRef, srcLength, fNameUStr, kTextEncodingUnicodeDefault, fsRef);

      CFRelease (fileNameRef);
   }
   
   return (result);
}

int  id_GetApplicationParentFSRef (FSRef *appParentFolderFSRef)  // out, bundle folder
{
   short         retVal = -1;
   CFBundleRef   appBundleRef;
   CFURLRef      appURL;
   FSRef         appFSRef;

   if (appBundleRef = CFBundleGetMainBundle())  {  // App's Bundle
      if (appURL = CFBundleCopyBundleURL(appBundleRef))  {
         if (CFURLGetFSRef(appURL, &appFSRef))  {
            if (!id_GetParentFSRef(&appFSRef, appParentFolderFSRef))
               retVal = 0;
         }
         CFRelease (appURL);
      }
   }
      
   return (retVal);
}

int  id_GetApplicationExeFSRef (FSRef *appParentFolderFSRef)  // out, exe folder
{
   short         retVal = -1;
   CFBundleRef   appBundleRef;
   CFURLRef      appURL;

   if (appBundleRef = CFBundleGetMainBundle())  {  // App's Bundle
      if (appURL = CFBundleCopyExecutableURL(appBundleRef))  {
         if (CFURLGetFSRef(appURL, appParentFolderFSRef))
            retVal = 0;
         CFRelease (appURL);
      }
   }
   
   // eventualno, onaj trik za napravit i fsspec iz ovog!
   
   return (retVal);
}

int  id_GetMyApplicationResourcesFSRef (FSRef *rsrcFolderFSRef)  // put them into dTOOL_INT.C, add these fsRefs to dtGlobals!
{
   short         retVal = -1;
   CFBundleRef   appBundleRef;
   CFURLRef      appURL;

   if (appBundleRef = CFBundleGetMainBundle())  {  // App's Bundle
      if (appURL = CFBundleCopyResourcesDirectoryURL(appBundleRef))  {  // there's CFBundleCopyBundleURL()
         if (CFURLGetFSRef(appURL, rsrcFolderFSRef))
            retVal = 0;
         CFRelease (appURL);
      }
   }
   
   // eventualno, onaj trik za napravit i fsspec iz ovog!
   
   return (retVal);
}

#pragma mark -

int  id_GetDefaultDir (FSRef *fsRef) // out
{
   short  retVal = -1;
   char   cwd[256];
   
   if (getcwd(cwd, 256))  {
      if (!FSPathMakeRef((const UInt8 *)cwd, fsRef, NULL))
         retVal = 0;
   }

   return (retVal);
}

int  id_SetDefaultDir (FSRef *fsRef)  // in
{
   short               err, retVal = -1;
   char                tmpStr[256];
   
   if (!FSRefMakePath(fsRef, (UInt8 *)tmpStr, 256))  {
      err = chdir (tmpStr);
      retVal = 0;
   }
   else
      err = -1;
   
   return (retVal);
}

short  OpenResFile (char *resFileName)  // c string
{
   short  /*vRefNum,*/ resRefNum = -1;
   FSRef  fsRef;
   // char   tmpStr[256];
   
   // if (!id_GetDefaultDir(&fsRef))
   if (!FSPathMakeRef((const UInt8 *)resFileName, &fsRef, NULL))
      resRefNum = FSOpenResFile (&fsRef, fsRdPerm);
   
   // To open a resource in data fork:
   // err = FSOpenResourceFile (&fsRef, 0, NULL, fsRdPerm, &resRefNum);
   
   return (resRefNum);
}

int  id_OpenInternalResFile (void)
{
   char   rsrcName[256], pathStr[256];
   char   appName[256];
   FSRef  appParentFolderFSRef;
   FSRef  rsrcFSRef, appRsrcFSRef;
   
   if (!id_GetApplicationExeFSRef(&appParentFolderFSRef))  {
      if (!id_ExtractFSRef(&appParentFolderFSRef, appName, nil/*&parentFSRef*/))
         NSLog (@"AppName: %s", appName);
   
      if (!id_GetMyApplicationResourcesFSRef(&rsrcFSRef))  {
         if (id_ExtractFSRef(&rsrcFSRef, rsrcName, nil))
            rsrcName[0] = '\0';
         if (FSRefMakePath(&rsrcFSRef, (UInt8 *)pathStr, 256))
            pathStr[0] = '\0';
         snprintf (pathStr+strlen(pathStr), 256-strlen(pathStr), "/%s.rsrc", appName);
         NSLog (@"Resource path: %s %s", pathStr, rsrcName);
         
         if (!FSPathMakeRef((const UInt8 *)pathStr, &appRsrcFSRef, NULL))  {
            ResFileRefNum  resRefNum;
            
            OSErr  err = FSOpenResourceFile (&appRsrcFSRef, 0, NULL, fsRdPerm, &resRefNum);
            
            if (!err)
               return ((short)resRefNum);
         }
      }
   }
   
   return (-1);
}

int  id_SetInitialDefaultDir (FSRef *appFolderFSRef) // out, applications folder inside the bundle
{
   short               retVal = -1;
   ProcessSerialNumber procSerNum = { 0, kCurrentProcess };
   ProcessInfoRec      procInfo;
   // FSSpec              appFSSpec;
   // WDPBRec             wpb;
   
   id_SetBlockToZeros (&procInfo, sizeof(ProcessInfoRec));
   procInfo.processInfoLength = sizeof (ProcessInfoRec);
   procInfo.processAppRef = appFolderFSRef;

   if (!GetProcessInformation(&procSerNum, &procInfo))  {
      retVal = 0;
      
      // Carbon tu postavi taj dir as current! -> id_SetDefaultDir (FSRef *fsRef)

      // zar nema sad neka fora sa GetVol za napravit i fsspec iz ovog!
   }

   return (retVal);
}

OSStatus  id_FSDeleteFile (FSRef *parentFSRef, char *fileName)  // fileName may be NULL
{
   OSStatus      result;
   FSRef         fsRefToDelete;
   
   if (fileName)  {
      result = id_GetFilesFSRef (parentFSRef, fileName, &fsRefToDelete);
      
      if (!result)
         result = FSDeleteObject (&fsRefToDelete);
   }
   else
      // parent is actually the file that should be deleted!
      result = FSDeleteObject (parentFSRef);
   
   return (result);
}

OSStatus  id_FSRenameFile (FSRef *theFileRef, char *newFileName)
{
   OSStatus      osErr = paramErr;
   CFStringRef   fileNameRef;
   UniCharCount  srcLength;
   UniChar       fNameUStr[256];
 
   // fileNameRef = CFStringCreateWithCString (NULL, newFileName, kTextEncodingISOLatin2);  // or kTextEncodingMacRoman
   
   id_Mac2CFString (newFileName, &fileNameRef, strlen(newFileName));

   if (fileNameRef)  {
      srcLength = (UniCharCount) CFStringGetLength (fileNameRef);
      CFStringGetCharacters (fileNameRef, CFRangeMake(0, srcLength), &fNameUStr[0]);

      osErr = FSRenameUnicode (theFileRef, srcLength, fNameUStr, kTextEncodingUnicodeDefault, NULL);  // or kTextEncodingUnknown

      CFRelease (fileNameRef);
   }
      
   return (osErr);
}

int  id_GetDesktopDir (FSRef *desktopFSRef) // out, Desktop folder
{
   OSStatus  osStatus = FSFindFolder (kOnSystemDisk, kDesktopFolderType, kDontCreateFolder, desktopFSRef);
   
   return (osStatus ? -1 : 0);
}

int  id_GetDocumentsDir (FSRef *desktopFSRef) // out, Desktop folder
{
   OSStatus  osStatus = FSFindFolder (kOnSystemDisk, kDocumentsFolderType, kDontCreateFolder, desktopFSRef);

   return (osStatus ? -1 : 0);
}

int  id_GetApplicationDataDir (FSRef *appDataFSRef) // out, appData folder, there is id_GetAppDataVolume()
{
   OSStatus  osStatus = FSFindFolder (kOnSystemDisk, kPreferencesFolderType, kDontCreateFolder, appDataFSRef);
   
   return (osStatus ? -1 : 0);
}

/* ......................................................... id_FileExists .......... */

Boolean  id_FileExists (char *filePath)
{
   char          posixPath[256];
   struct  stat  sBuffer;
   
   NOT_YET  // id_Mac2UTF8String (filePath, posixPath, 255);

   if (!stat(filePath/*posixPath*/, &sBuffer))  {
      // if (sBuffer.st_mode & S_IFDIR)
      return (TRUE);
   }
   
   return (FALSE);
}

/* ......................................................... id_PathIsFolder ........ */

Boolean  id_PathIsFolder (char *filePath)
{
   struct  stat  sBuffer;
   
   if (!stat(filePath, &sBuffer))  {
      if (sBuffer.st_mode & S_IFDIR)
         return (TRUE);
   }
   
   return (FALSE);
}

/* ......................................................... id_BreakFullPath ....... */

int  id_BreakFullPath (
 char  *fullPath,     // in
 char  *driveLetter,  // out, no op on Mac
 char  *purePath,     // out, contains drive, optional
 char  *fileName,     // out, with or without extension, YES, without if lasta param is not NULL
 char  *fileExtension // out, optional
)
{
   char        *dotPtr, *lbsPtr;
   char   separatorChar = '/';

#ifdef _NOT_YET_   
   if (id_pathIsSqlPath(fullPath))  {
      if (purePath)
         strNCpy (purePath, fullPath, 255);
      if (fileName)
         id_sqlPathToSqlDBName (fullPath, fileName, 127);
      if (fileExtension)
         *fileExtension = '\0';
      return (0);
   }
#endif
   
   lbsPtr = strrchr (fullPath, separatorChar);    // Last backSlash
   
   if (lbsPtr)  {
      *lbsPtr = '\0';

      if (purePath)
         strNCpy (purePath, fullPath, 256-1);
   }
   else  {
      if (purePath)
         purePath[0] = '\0';
      lbsPtr = fullPath;
   }

   if (lbsPtr)  {
      if (lbsPtr != fullPath)
         *lbsPtr++ = separatorChar;      // put it back
      strNCpy (fileName, lbsPtr, 256-1);
      if (fileExtension)  {
         if (dotPtr = strrchr(fileName, '.'))  {
            *dotPtr++ = '\0';
            strNCpy (fileExtension, dotPtr, 3);    // More ???
         }
         else
            fileExtension[0] = '\0';
      }
   }
   else  {
      fileName[0] = '\0';
      if (fileExtension)
         fileExtension[0] = '\0';
   }
   
   return (0);
}

/* ......................................................... id_ConcatPath .......... */

int  id_ConcatPath (
 char  *fullPath,     // in/out
 char  *morePath      // in, ending or file name
)
{
   return (id_CoreConcatPath(fullPath, morePath, FALSE));
}

/* ......................................................... id_ConcatPath .......... */

int  id_CoreConcatPath (
 char  *fullPath,     // in/out
 char  *morePath,     // in, ending or file name
 short  webFlag       // because of Win or MacOS9
)
{
   char   separatorChar = '/';
   char  *startPtr;
   short  len;
   
   if ((len = strlen(fullPath)) + strlen(morePath) >= MAX_PATH-1)  // 256 or PATH_MAX of 1024 - /usr/include/sys/syslimits.h
      return (-1);
   
   if (len)  {
      startPtr = &fullPath[len-1];  // lastChar
      if (*startPtr++ != separatorChar)
         *startPtr++ = separatorChar;
   }
   else
      startPtr = fullPath;          // first
   
   if (morePath[0] == separatorChar)
      morePath++;                   // skip it!
   
   strcpy (startPtr, morePath);
   
   return (0);
}

int  id_NavGetFile (NSArray *allowedTypes, char *fileName, FSRef *parentFSRef, Boolean *aliasFlag)
{
   int           returnCode = 0;
   NSOpenPanel  *panel = [[NSOpenPanel alloc] init];

   CFStringRef  cfStringAction = id_CreateCFString ("Otvori");
   CFStringRef  cfStringTitle = id_CreateCFString ("Otvori datoteku");
   // CFStringRef  cfStringFile = id_CreateCFString ("No Name");
   CFStringRef  cfStringMessage = id_CreateCFString ("Izaberite jednu datoteku sa popisa");
   
   if (aliasFlag)
      *aliasFlag = FALSE;
   
   panel.prompt = (NSString *)cfStringAction;
   panel.title  = (NSString *)cfStringTitle;  // Is this used?
   panel.message = (NSString *)cfStringMessage;
   
   // panel.nameFieldLabel = @"nameFieldLabel"; -> only save
   // panel.nameFieldStringValue = @"nameFieldStringValue"; -> not used for open panel

   // This eisted in Carbon
   // CFStringRef  cfStringClient = id_CreateCFString ("Bouquet");
   // CFStringRef  cfStringCancel = id_CreateCFString ("Odustani");
   
   panel.allowedFileTypes = allowedTypes;

   panel.directoryURL = nil;
   panel.allowsOtherFileTypes = NO;
   panel.canCreateDirectories = YES;

   [panel setExtensionHidden:NO];    // Property is not defined on 10.6, only this method
   
   panel.treatsFilePackagesAsDirectories = NO;
   
   panel.canChooseFiles = YES;
   panel.resolvesAliases = NO;  // YES;
   panel.allowsMultipleSelection = NO;

   returnCode = (int)[panel runModal];
   
   CFRelease (cfStringTitle);
   CFRelease (cfStringAction);
   // CFRelease (cfStringFile);
   CFRelease (cfStringMessage);
   
   // So, here we play with different ways of getting parent folder's fsRef and the file name. All methods should get the same result
   
   if (returnCode == NSFileHandlingPanelOKButton)  {  // NSModalResponseOK, alternative is NSModalResponseCancel
      char      fullPath[PATH_MAX];
      CFURLRef  urlRef = CFURLCreateCopyDeletingLastPathComponent (NULL, (CFURLRef)panel.URL);
      FSRef     fsRef;
      Boolean   aliasFileFlag, folderFlag;
      
      CFURLGetFSRef (urlRef, parentFSRef);  // or use id_GetParentFSRef (const FSRef *fileFSRef, FSRef *parentFSRef);
      
      CFRelease (urlRef);
      
      if (FSRefMakePath(parentFSRef, (UInt8 *)fullPath, PATH_MAX))
         fullPath[0] = '\0';
      NSLog (@"Filepath with FSRefMakePath(): %s", fullPath);
      if (!FSIsAliasFile(parentFSRef, &aliasFileFlag, &folderFlag))
         NSLog (@"Parent - Alias: %@;  Folder: %@", aliasFileFlag ? @"Yes" :  @"NO", folderFlag ? @"Yes" :  @"NO");
      
      CFURLGetFSRef ((CFURLRef)panel.URL, &fsRef);
      
      id_ExtractFSRef (&fsRef, fileName, parentFSRef);
      NSLog (@"FileName with id_ExtractFSRef(): %s", fileName);
      
      if (!FSIsAliasFile(&fsRef, &aliasFileFlag, &folderFlag))  {
         NSLog (@"File - Alias: %@;  Folder: %@", aliasFileFlag ? @"Yes" :  @"NO", folderFlag ? @"Yes" :  @"NO");
         if (aliasFlag)
            *aliasFlag = aliasFileFlag;
      }

      if (CFURLGetFileSystemRepresentation((CFURLRef)panel.URL, TRUE, (UInt8 *)fullPath, PATH_MAX))  {
         NSLog (@"Filepath with CFURLGetFileSystemRepresentation(): %s", fullPath);
         id_BreakFullPath (fullPath, NULL, NULL, fileName, NULL);
         
         return (0);
      }
   }
      
   return (-1);
}

/* ......................................................... id_CreateAliasToPath ... */

// cTargetFileOrFolderPath - original, file that will be target of our alias
// cParentFolderPath - place where we put our alias
// cFileName - alias file name

int  id_CreateAliasToPath (char *cTargetFileOrFolderPath, char *cParentFolderPath, char *cFileName, OSType fileType)
{
   Boolean        isFolder = FALSE;
   FSRef          targetRef, parentRef, aliasRef;
   CFURLRef       cfTargetUrl = NULL, cfParentUrl = NULL;
   CFStringRef    cfFileName = NULL;
   HFSUniStr255   aliasName;
   AliasHandle    aliasHandle = NULL;
   ResFileRefNum  fileReference = -1;
   FSCatalogInfo  catalogInfo;
   FileInfo      *theFileInfo = NULL;
   CFStringRef    cfParentFolderPath = NULL;
   CFStringRef    cfTargetFolderPath = NULL;
   CFStringRef    cfeParentFolderPath = NULL;
   CFStringRef    cfeTargetFolderPath = NULL;
   
   // Create a resource file for the alias.
   // CFURLGetFSRef ((CFURLRef)[NSURL fileURLWithPath:parentFolder], &parentRef);
   // There is id_CreateURLForFile() but I'm not sure it works with spec characters
   
   id_Mac2CFString (cParentFolderPath, &cfParentFolderPath, strlen(cParentFolderPath));
   cfeParentFolderPath = CFURLCreateStringByAddingPercentEscapes (kCFAllocatorDefault, cfParentFolderPath, NULL, NULL, kCFStringEncodingUTF8);
   cfParentUrl = CFURLCreateWithString (kCFAllocatorDefault, cfeParentFolderPath, NULL);
   
   if (!fileType)  {
      if (id_FileExists(cTargetFileOrFolderPath) && id_PathIsFolder(cTargetFileOrFolderPath))
         fileType = kContainerFolderAliasType;
   }
   
   if (cfParentUrl)  {
      CFURLGetFSRef (cfParentUrl, &parentRef);
   
      id_Mac2CFString (cFileName, &cfFileName, strlen(cFileName));
      FSGetHFSUniStrFromString (cfFileName, &aliasName);
      
      FSCreateResFile (&parentRef, aliasName.length, aliasName.unicode, 0, NULL, &aliasRef, NULL);
   }
   
   // Construct alias data to write to resource fork.
   
   // CFURLGetFSRef ((CFURLRef)[NSURL fileURLWithPath:destFolder], &targetRef);
   id_Mac2CFString (cTargetFileOrFolderPath, &cfTargetFolderPath, strlen(cTargetFileOrFolderPath));
   cfeTargetFolderPath = CFURLCreateStringByAddingPercentEscapes (kCFAllocatorDefault, cfTargetFolderPath, NULL, NULL, kCFStringEncodingUTF8);
   cfTargetUrl = CFURLCreateWithString (kCFAllocatorDefault, cfeTargetFolderPath, NULL);

   if (cfTargetUrl)  {
      CFURLGetFSRef (cfTargetUrl, &targetRef);
   
      FSNewAlias (NULL, &targetRef, &aliasHandle);
   
      // Add the alias data to the resource fork and close it.
      fileReference = FSOpenResFile (&aliasRef, fsRdWrPerm);
   }
   
   if (fileReference != -1)  {
      UseResFile (fileReference);
      AddResource ((Handle)aliasHandle, 'alis', 0, NULL);
      CloseResFile (fileReference);
   
      // Update finder info.
      FSGetCatalogInfo (&aliasRef, kFSCatInfoFinderInfo, &catalogInfo, NULL, NULL, NULL);
   
      theFileInfo = (FileInfo*)(&catalogInfo.finderInfo);
   
      theFileInfo->finderFlags |= kIsAlias;        // Set the alias bit.
      theFileInfo->finderFlags &= ~kHasBeenInited; // Clear the inited bit to tell Finder to recheck the file.
      theFileInfo->fileType = fileType;            // kContainerFolderAliasType -> folders
   
      FSSetCatalogInfo (&aliasRef, kFSCatInfoFinderInfo, &catalogInfo);
   }
   
   if (aliasHandle)
      DisposeHandle ((Handle)aliasHandle);
   
   if (cfParentUrl)
      CFRelease (cfParentUrl);
   if (cfTargetUrl)
      CFRelease (cfTargetUrl);
   
   if (cfFileName)
      CFRelease (cfFileName);
   if (cfTargetFolderPath)
      CFRelease (cfTargetFolderPath);
   if (cfParentFolderPath)
      CFRelease (cfParentFolderPath);
   if (cfeTargetFolderPath)
      CFRelease (cfeTargetFolderPath);
   if (cfeParentFolderPath)
      CFRelease (cfeParentFolderPath);
   
   return (0);
}

#pragma mark strings

int  id_UniCharToUpper (UniChar *uch)
{
   OSErr               err = noErr;
   UniChar             uniArray[8];
   CFMutableStringRef  cfStr;
   CFLocaleRef         localeRef = CFLocaleCopyCurrent ();
   
   uniArray[0] = *uch;
   uniArray[1] = 0;
   
   cfStr = CFStringCreateMutableWithExternalCharactersNoCopy (NULL, &uniArray[0], 1, 8, kCFAllocatorNull);
   
   CFStringUppercase (cfStr, localeRef);
   
   *uch = CFStringGetCharacterAtIndex (cfStr, 0);
   
   CFRelease (cfStr);
   CFRelease (localeRef);

   return (err);
}

/* .......................................................... id_UniCharToUpper ..... */

// txn version NEW!

int  id_UniCharToChar (UniChar uch, char *ch)
{
   OSErr               err = noErr;
   short               maxLen = 1;
   char                charArray[8];
   UniChar             uniArray[8];
   CFMutableStringRef  cfStr;
   
   uniArray[0] = uch;
   uniArray[1] = 0;
   
   cfStr = CFStringCreateMutableWithExternalCharactersNoCopy (NULL, &uniArray[0], 1, 8, kCFAllocatorNull);
   
   id_CFString2Mac (cfStr, charArray, &maxLen);
      
   CFRelease (cfStr);
   
   if (maxLen)
      *ch = charArray[0];
   else
      *ch = '\0';

   return (err);
}

int  id_CharToUniChar (char ch, UniChar *uch)
{
   OSErr        err = noErr;
   char         charArray[8];
   // UniChar      uniArray[8];
   CFStringRef  cfStr;
   
   charArray[0] = ch;
   charArray[1] = 0;
   
   id_Mac2CFString (charArray, &cfStr, 1);
   
   *uch = CFStringGetCharacterAtIndex (cfStr, 0);

   CFRelease (cfStr);
   
   return (err);
}

/* ................................................... strNCpy ..................... */

char *strNCpy (char *s1, const char *s2, long n)
{
   char  *tar = s1;
   
   while (n-- && *s2)
      *s1++ = *s2++;
   *s1 = '\0';
   
   return (tar);
}

/* ................................................... stricmp ..................... */

int  stricmp (char *s1, char *s2)
{
   for ( ; toupper(*s1) == toupper(*s2); s1++, s2++)
      if (!*s1) break;

   return (toupper(*s1) - toupper(*s2));
}

/* ................................................... strnicmp .................... */

int  strnicmp (char *s1, char *s2, short n)  // see id_StrniCmpCro
{
   if (n <= 0) return ( 0 );
   for ( ; --n && (toupper(*s1) == toupper(*s2)); s1++, s2++)
      if (!*s1) break;
		
   return (toupper(*s1) - toupper(*s2));
}

/* ----------------------------------------------------------- id_isCroAlpha --------- */

int  id_isCroAlpha (char ch, short spaceIsAlpha)
{
   char  croCharacters[12] = { 0xC8, 0xC6, 0xD0, 0xA9, 0xAE,  0xE8, 0xE6, 0xF0, 0xB9, 0xBE,  '\0' };
   
   if (isalpha(ch) || strchr(croCharacters, ch) || (spaceIsAlpha && ch == ' '))  // "ËÊπæ»∆–©Æ"
      return (TRUE);
   
   return (FALSE);
}

/* ................................................... id_ConvertTextTo1250 ........ */

// Watch it! This thing can enlarge the string by few characters...

void  id_ConvertTextTo1250 (
 char  *sText,
 short *len,
 short  expandNewLines
)
{
   long  retLen = (short)*len;
   
   if (retLen < 0)
      NOT_YET  // id_note_emsg ("id_ConvertTextTo1250 - Duljina teksta!");
      NSLog (@"id_ConvertTextTo1250 - Duljina teksta!");
   
   id_ConvertTextTo1250L (sText, &retLen, expandNewLines);
   
   *len = retLen;
}

/* ................................................... id_ConvertTextTo1250L ....... */

void  id_ConvertTextTo1250L (
 char  *sText,
 long  *len,
 short  expandNewLines
)
{
   long  retLen = *len;
   
   while (*sText && *len)  {
      switch ((unsigned char)*sText)  {
            
         //    Mac             Win
            
         case 0xC4:  *sText = 0xFB;  break;  // 'ƒ' - 'ƒ'

         case 0xC8:  *sText = 0xC8;  break;  // 'CC' - '»'
         case 0xC6:  *sText = 0xC6;  break;  // 'CH' - '∆'
         case 0xD0:  *sText = 0xD0;  break;  // 'DJ' - '–'
         case 0xA9:  *sText = 0x8A;  break;  // 'SH' - '©'
         case 0xAE:  *sText = 0x8E;  break;  // 'ZH' - 'Æ'
            
         case 0xE8:  *sText = 0xE8;  break;  // 'cc' - 'Ë'
         case 0xE6:  *sText = 0xE6;  break;  // 'ch' - 'Ê'
         case 0xF0:  *sText = 0xF0;  break;  // 'dj' - ''
         case 0xB9:  *sText = 0x9A;  break;  // 'sh' - 'π'
         case 0xBE:  *sText = 0x9E;  break;  // 'zh' - 'æ'
            
         case 0xD2:  *sText = 0x93;  break;  // '“' - '//'
         case 0xD3:  *sText = 0x94;  break;  // '”' - '//'
         case 0xA5:  *sText = 0x95;  break;  // '•' - '*'
            
         case 0xB7:  *sText = 0xE4;  break;  // '∑' - 'E'
            
         case 0x80:  *sText = 0xC4;  break;  // 'Ä' - ''
         case 0xFA:  *sText = 0xCB;  break;  // 'Ë' - ''
         case 0x85:  *sText = 0xD6;  break;  // 'Ö' - ''
         case 0x86:  *sText = 0xDC;  break;  // 'Ü' - ''
         case 0x8A:  *sText = 0xE4;  break;  // 'ä' - ''
         case 0x91:  *sText = 0xEB;  break;  // 'ë' - ''
         case 0x9A:  *sText = 0xF6;  break;  // 'ö' - ''
         case 0x9F:  *sText = 0xFC;  break;  // 'ü' - ''

         case 0x8E:  *sText = 0xE9;  break;  // 'é' - ''
         case 0x8D:  *sText = 0xE7;  break;  // 'ç' - ''
         case 0x83:  *sText = 0xC9;  break;  // 'É' - ''
         case 0x82:  *sText = 0xC7;  break;  // 'Ç' - ''
         case 0x8F:  *sText = 0xB7;  break;  // '·' - ''

         case 0xE0:  *sText = 0x96;  break;  // '-' - '–'  // NDash
            
         case '\r':
            if (expandNewLines)  {
               if (*(sText+1) != '\n')  {
                  BlockMove (sText+1, sText+2, *len);
                  *(++sText) = '\n';
                  retLen++;
               }
            }
            break;
      }
      sText++;
      (*len)--;
   }
   
   *len = retLen;
}

/* ................................................... id_Convert1250ToText ........ */

// Watch it! This thing can shorten the string by few characters...

void  id_Convert1250ToText (
 char   *sText,
 short  *len,
 short   expandNewLines
)
{
   short  retLen = *len;
   
   while (*sText && *len)  {
      switch ((unsigned char)*sText)  {
      
         //    Win             Mac

         case 0xFB:  *sText = 0xC4;  break;  // 'ƒ' - 'ƒ'

         case 0xC8:  *sText = 0xC8;  break;  // 'CC'
         case 0xC6:  *sText = 0xC6;  break;  // 'CH'
         case 0xD0:  *sText = 0xD0;  break;  // 'DJ'
         case 0x8A:  *sText = 0xA9;  break;  // 'SH'
         case 0x8E:  *sText = 0xAE;  break;  // 'ZH'
         
         case 0xE8:  *sText = 0xE8;  break;  // 'cc'
         case 0xE6:  *sText = 0xE6;  break;  // 'ch'
         case 0xF0:  *sText = 0xF0;  break;  // 'dj'
         case 0x9A:  *sText = 0xB9;  break;  // 'sh'
         case 0x9E:  *sText = 0xBE;  break;  // 'zh'

         case 0x93:  *sText = 0xD2;  break;  // '“' - '//'
         case 0x94:  *sText = 0xD3;  break;  // '”' - '//'
         case 0x95:  *sText = 0xA5;  break;  // '•'

         case 0xC4:  *sText = 0x80;  break;  // 'Ä' - ''
         case 0xCB:  *sText = 0xFA;  break;  // 'Ë' - ''
         case 0xD6:  *sText = 0x85;  break;  // 'Ö' - ''
         case 0xDC:  *sText = 0x86;  break;  // 'Ü' - ''
         case 0xE4:  *sText = 0x8A;  break;  // 'ä' - ''
         case 0xEB:  *sText = 0x91;  break;  // 'ë' - ''
         case 0xF6:  *sText = 0x9A;  break;  // 'ö' - ''
         case 0xFC:  *sText = 0x9F;  break;  // 'ü' - ''

         case 0xE9:  *sText = 0x8E;  break;  // 'é' - ''
         case 0xE7:  *sText = 0x8D;  break;  // 'ç' - ''
         case 0xC9:  *sText = 0x83;  break;  // 'É' - ''
         case 0xC7:  *sText = 0x82;  break;  // 'Ç' - ''
         case 0xB7:  *sText = 0x8F;  break;  // '·' - ''

         case 0x96:  *sText = 0xE0;  break;  // '-' - '–'  // NDash

         case '\r':
            if (expandNewLines)  {
               if (*(sText+1) == '\n')  {
                  BlockMove (sText+2, sText+1, (*len)-1);
                  retLen--;
                  (*len)--;
               }
            }
            break;
      }
      sText++;
      (*len)--;
   }

   *len = retLen;
}

/* .......................................................... id_String2Mac ......... */

// May shrink string by 1
  // it will null-terminate dstStr !!!

// int  con_printf (const char *fmt, ...);
  
char *id_CFString2Mac (const CFStringRef srcStr, char *dstStr, short *strLen)
{
   // char   *chPtr, testStr[256];
   short   maxLen = *strLen;
   CFIndex usedBufLen;
   CFIndex len = CFStringGetLength (srcStr);
   
   CFStringRef  tmpStr = NULL;
   
   if (!len)  {
      dstStr[0] = '\0';
      *strLen = 0;
      
      return (dstStr);
   }
   
   // tmpStr = id_TestReplacementCharacters (srcStr, FALSE);
   
   CFStringGetBytes (tmpStr ? tmpStr : srcStr, CFRangeMake(0, len), kTextEncodingMacCroatian/*kTextEncodingWindowsLatin2*/, '?', FALSE, (UInt8 *) dstStr, maxLen, &usedBufLen);
   
   if (tmpStr)
      CFRelease (tmpStr);

   dstStr[*strLen = usedBufLen] = '\0';
   
   /*if (usedBufLen == 6)
      con_printf ("%hX %hX %hX %hX %hX %hX \n",
                  (short)(unsigned char)dstStr[0], (short)(unsigned char)dstStr[1], (short)(unsigned char)dstStr[2],
                  (short)(unsigned char)dstStr[3], (short)(unsigned char)dstStr[4], (short)(unsigned char)dstStr[5]);*/
    
   // id_Convert1250ToText (dstStr, strLen, FALSE);  // kill resize, last param

   return (dstStr);
}

CFStringRef  id_Mac2CFString (const char *srcStr, CFStringRef *dstStr, long strLen)
{
   static char *errmsg = "Bad name!";
   
   char         tmpStr[512];
   char        *chPtr = tmpStr;
   long         usedLen = strLen;
   
   if (strLen >= 512)
      chPtr = malloc (strLen+4);
   
   strNCpy (chPtr, srcStr, usedLen);
   
   // id_ConvertTextTo1250L (chPtr, &usedLen, FALSE);  // kill resize, last param
   
   // *dstStr = CFStringCreateWithBytes (NULL, (const UInt8 *) chPtr, usedLen, kTextEncodingWindowsLatin2/*kTextEncodingISOLatin2*/, FALSE);  // or kTextEncodingMacRoman
   *dstStr = CFStringCreateWithBytes (NULL, (const UInt8 *) chPtr, usedLen, kTextEncodingMacCroatian/*kTextEncodingISOLatin2*/, FALSE);  // or kTextEncodingMacRoman
   
   if (!(*dstStr))
      *dstStr = CFStringCreateWithBytes (NULL, (const UInt8 *) errmsg, strlen(errmsg), kTextEncodingWindowsLatin2/*kTextEncodingISOLatin2*/, FALSE);  // or kTextEncodingMacRoman

   if (chPtr != tmpStr)
      free (chPtr);
   
   /*if (*dstStr)  {
      CFStringRef  tmpStr = id_TestReplacementCharacters (*dstStr, TRUE);
      
      if (tmpStr)  {
         CFRelease (*dstStr);
         *dstStr = tmpStr;
      }
   }*/
   
   return (*dstStr);  // needs CFRelease()
}

/* .......................................................... id_CreateCFString ..... */

// later, call CFRelease (cfString);

CFStringRef  id_CreateCFString (const char *srcStr)
{
   short        usedLen = strlen(srcStr);
   CFStringRef  cfString = NULL;
   
   id_Mac2CFString (srcStr, &cfString, usedLen);
   
   return (cfString);
}

// -----------------------

int  id_InitComputerName (char *compName, short buffSize)
{
   short        retVal = -1;
   CFStringRef  cfString = CSCopyMachineName ();
   
   if (cfString)  {
      id_CFString2Mac (cfString, compName, &buffSize);
      // if (CFStringGetCString (cfString, compName, buffSize, kTextEncodingISOLatin2))
      if (compName[0])
         retVal = 0;
      CFRelease (cfString);
   }
   return (retVal);
}

int  id_InitComputerUserName (char *userName, short buffSize)
{
   int          retVal = -1;
   CFStringRef  cfString = CSCopyUserName (FALSE);  // useShortName
   
   if (cfString)  {
      id_CFString2Mac (cfString, userName, &buffSize);
      // if (CFStringGetCString (cfString, userName, buffSize, kTextEncodingISOLatin2))
      if (userName[0])
         retVal = 0;
      CFRelease (cfString);
   }
   return (retVal);
}

/*
void  pr_ListFonts (void)
{
   NSFontManager  *fontManager = [NSFontManager sharedFontManager];
   
   NSArray  *fontFamilyNames = [fontManager availableFontFamilies];
   
   for (NSString *familyName in fontFamilyNames)  {
      // NSArray  *fontNames = [fontManager availableMembersOfFontFamily:familyName];
      
      NSLog (@"Font Family: %@", familyName);
      // NSLog (@"Font Names: %@", fontNames);
      // NSLog (@"\n");
   }  
   
   NSLog (@"Font TitleBar: %@", [NSFont titleBarFontOfSize:9].fontName);
   NSLog (@"Font Menu: %@", [NSFont menuFontOfSize:9].fontName);
   NSLog (@"Font MenuBar: %@", [NSFont menuBarFontOfSize:9].fontName);
   NSLog (@"Font Message: %@", [NSFont messageFontOfSize:9].fontName);
   NSLog (@"Font Palette: %@", [NSFont paletteFontOfSize:9].fontName);
   NSLog (@"Font ToolTips: %@", [NSFont toolTipsFontOfSize:9].fontName);
   NSLog (@"Font Control: %@", [NSFont controlContentFontOfSize:9].fontName);
}*/

void TestVersion (void)
{
   OSErr   err;
   SInt32  response;

   EventRecord  evt;
   
   NSLog (@"Sizeof long: %ld;  Sizeof int: %ld; Sizeof SInt32: %ld;  Sizeof longlong: %ld;  Sizeof evt->message: %ld\n",
          sizeof(long), sizeof(int), sizeof(SInt32), sizeof(long long), sizeof(evt.message));
   
   err = Gestalt (gestaltSystemVersion, &response);
   
   if (err == noErr) 
      NSLog (@"Gestalt: %d - %x\n", response, response);
}

void  pr_ListEncodings (void)
{
   const NSStringEncoding  *availableStringEncodings = [NSString availableStringEncodings];
   
   // There is kCFStringEncodingMacCroatian & kTextEncodingMacCroatian / both 36
   
   for (int i=0; availableStringEncodings[i]; i++)  {
      NSString  *encName = [NSString localizedNameOfStringEncoding:availableStringEncodings[i]];
      NSRange    range = [encName rangeOfString:@"Croat"];
      if (range.location != NSNotFound)
         NSLog (@"Encoding: %u %@", (unsigned int)availableStringEncodings[i], encName);
   }
}

/* .......................................................... TExSetText ............ */

int  TExSetText (NSTextField *theCtl, char *theText, short txLen)
{
   OSErr        err = noErr;
   CFStringRef  cfString;
   
   if (!theCtl)
      return (paramErr);
      
   id_Mac2CFString (theText, &cfString, txLen);
   
   [theCtl setStringValue:(NSString *)cfString];

   CFRelease (cfString);
   
   return (err);
}

/* .......................................................... TExGetText ............ */

// maxLen is in & out

int  TExGetText (NSTextField *theCtl, char *theText, short *maxLen)  // maxLen is in & out
{
   OSErr        err = noErr;
   Size         actualSize;
   CFStringRef  tmpCFStr;
   
   if (!theCtl)
      return (paramErr);
   
   tmpCFStr = (CFStringRef)[theCtl stringValue];
   
   actualSize = ((NSString *)tmpCFStr).length;
      
   *maxLen = *maxLen > actualSize ? actualSize : *maxLen;
   
   id_CFString2Mac (tmpCFStr, theText, maxLen);  // changes maxLen to actual len
 
   return (err);
}

/* .......................................................... TExGetTextLen ......... */

int  TExGetTextLen (NSTextField *theCtl)
{
   if (!theCtl)
      return (0);
   
   return ((int)[[theCtl stringValue] length]);
}

/* ................................................... TExMeasureText ............... */

// This measures text with fixed font. Now we somehow need to send font decription here

int  TExMeasureText (char *cStr, long len, short *txtWidth, short *txtHeight)
{
   CFStringRef  cfString = NULL;
   CGSize       resultSize;
   
   if (txtWidth)
      *txtWidth = 0;
   if (txtHeight)
      *txtHeight = 0;
   
   id_Mac2CFString (cStr, &cfString, len);
   
   NSMutableParagraphStyle  *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
   textStyle.lineBreakMode = NSLineBreakByWordWrapping;
   textStyle.alignment = NSLeftTextAlignment;  // NSTextAlignmentLeft;

   NSFont   *textFont = [NSFont labelFontOfSize:9];
   NSColor  *theColor = [NSColor blackColor];
   
   NSMutableDictionary  *attrs = [NSMutableDictionary dictionaryWithCapacity:3];
   
   [attrs setObject:textStyle forKey:NSParagraphStyleAttributeName];
   [attrs setObject:textFont forKey:NSFontAttributeName];
   [attrs setObject:theColor forKey:NSForegroundColorAttributeName];
   
   resultSize = [(NSString *)cfString sizeWithAttributes:attrs];
   
   CFRelease (cfString);
   
   if (txtWidth)
      *txtWidth = resultSize.width;
   if (txtHeight)
      *txtHeight = resultSize.height;
   
   return (resultSize.width < 1. ? -1 : 0);
}

void   TExTextBox (char *str, long len, Rect *txtRect, short teJust, short teWrap, short eraseBackground)
{
   CFStringRef  cfStr;
   
   CGRect    strRect = id_Rect2CGRect (txtRect);
   NSFont   *textFont = [NSFont messageFontOfSize:10];
   NSColor  *theColor = [NSColor blackColor];
   
   if (eraseBackground)  {
      // NSLog (@"TExTextBox: %@", NSStringFromRect(strRect));

      NSBezierPath  *textPath = [NSBezierPath bezierPathWithRect:CGRectInset(strRect, -1, 0)];
      [[NSColor whiteColor] setFill];
      [textPath fill];
   }
   
   id_Mac2CFString (str, &cfStr, len);
   
   NSMutableParagraphStyle  *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
   
   textStyle.lineBreakMode = NSLineBreakByWordWrapping;
   textStyle.alignment = TExAlignment (teJust);  // NSTextAlignmentLeft;
   
   NSMutableDictionary  *attrs = [NSMutableDictionary dictionaryWithCapacity:3];
   
   [attrs setObject:textStyle forKey:NSParagraphStyleAttributeName];
   [attrs setObject:textFont forKey:NSFontAttributeName];
   [attrs setObject:theColor forKey:NSForegroundColorAttributeName];
   
   
   [(NSString *)cfStr drawInRect:strRect withAttributes:attrs];
   
   [textStyle release];
   
   CFRelease (cfStr);
}

/* .......................................................... TExSetAlignment ....... */

NSTextAlignment  TExAlignment (short teJust)
{
   NSTextAlignment  justificationToSet;
   
   switch (teJust)  {
      case  teJustRight:
         justificationToSet = NSRightTextAlignment;
         break;
      case  teJustCenter:
         justificationToSet = NSCenterTextAlignment;
         break;
      case  teJustLeft:
      // there are kTXNFullJust & kTXNForceFullJust but...
      default:
         justificationToSet = NSLeftTextAlignment;
         break;
   }

   return (justificationToSet);
}

/* .......................................................... TExSetAlignment ....... */

int  TExSetAlignment (NSTextField *theCtl, short teJust)
{
   NSTextAlignment  justificationToSet = TExAlignment (teJust);
   
   if (!theCtl)
      return (paramErr);
   
   [theCtl setAlignment:justificationToSet];
   
   return (theCtl.alignment == justificationToSet ? 0 :  -1);
}

/* .......................................................... TExSetSelection ....... */

// txn version

int  TExSetSelection (NSTextField *theCtl, short selStart, short selEnd)
{
   OSErr    err = noErr;
   NSRange  selRange = NSMakeRange (selStart, selEnd-selStart);

   if (!theCtl)
      return (paramErr);
   
   NSText  *fieldEditor = theCtl.currentEditor;
   
   [fieldEditor setSelectedRange:selRange];
      
   // if (!err)
   //    TXNShowSelection ((TXNObject)theCtl, FALSE);  // false for show end of selection
   
   return (err);
}

/* .......................................................... TExGetSelection ....... */

// txn version

int  TExGetSelection (NSTextField *theCtl, short *selStart, short *selEnd)
{
   OSErr  err = noErr;

   if (!theCtl)
      return (paramErr);
      
   NSText  *fieldEditor = theCtl.currentEditor;
   NSRange  selRange = [fieldEditor selectedRange];
       
   if (selRange.location != NSNotFound)  {
      *selStart = selRange.location;
      *selEnd   = selRange.location + selRange.length;
   }
   else
      *selStart = *selEnd = 0;
   
   return (err);
}

/* ................................................... id_TEIdle .................... */

// txn version

int  TExIdle (
 WindowPtr     windowPtr,
 NSTextField  *editInput
)
{
   NOT_YET // TXNIdle ((TXNObject)editInput);
   
   return (0);
}

/* ................................................... TExActivate .................. */

// txn version

int  TExActivate (
 NSWindow     *aWindow,
 NSTextField  *editInput
)
{
   NOT_YET // TXNFocus ((TXNObject)editInput, TRUE);
   [aWindow makeFirstResponder:editInput];
   
   return (0);
}

/* ................................................... TExDeactivate ................ */

// txn version

int  TExDeactivate (
 NSWindow     *aWindow,
 NSTextField  *editInput
)
{
   NOT_YET // TXNFocus ((TXNObject)editInput, FALSE);
   
   // [editInput resignFirstResponder];  -> do not call directly
   [aWindow makeFirstResponder:nil];
   
   return (0);
}

/* ................................................... TExUpdate .................... */

// txn version

int  TExUpdate (NSTextField  *editInput, Rect *fldRect)
{
   NOT_YET // TXNDrawObject ((TXNObject)editInput, NULL, kTXNDrawItemTextAndSelectionMask);
   
   return (0);
}

/* ................................................... id_TEClick ................... */

// txn version

int  TExClick (
 Point         myPt,
 UInt16        evtModifiers,
 EventRecord  *evtPtr,
 NSTextField  *editInput
)
{
   // old osx version:
   
   // TXNClick ((TXNObject)editInput, evtPtr);
   
   if (dtGData->texEvent)  {
      [editInput mouseDown:dtGData->texEvent];
      
      [dtGData->texEvent release];
      dtGData->texEvent = nil;
   }
   
   return (0);
}/* ................................................... id_put_TE_str ................ */

int  id_put_TE_str (
 FORM_REC    *form,
 short        index
)
{
   short  selStart, selEnd, txtSize, i;
   char   tmpStr[256];
   // char  *tmpBullets = tmpStr;
   char  *txtPtr = id_field_text_buffer (form, index+1);
   
   TExGetSelection ((NSTextField *)form->ditl_def[index]->i_handle, &selStart, &selEnd);
   
   txtSize = id_field_text_length (form, index+1);
      
   if (txtSize && (form->edit_def[index]->e_fld_edits & ID_FE_BULLETS) && !id_get_pen(form, ID_PEN_DOWN))  {
      for (i=0; i<txtSize; i++)
         tmpStr[i] = '.';  // '•';
      txtPtr = tmpStr;
   }      

   TExSetText ((NSTextField *)form->ditl_def[index]->i_handle, txtPtr, txtSize);

   if (id_get_pen(form, ID_PEN_DOWN) && form->cur_fldno == index)  {
      if (selStart > txtSize)
         selStart = txtSize;
      if (selEnd > txtSize)
         selEnd = txtSize;
      TExSetSelection ((NSTextField *)form->ditl_def[index]->i_handle, selStart, selEnd);
   }
   else
      TExSetSelection ((NSTextField *)form->ditl_def[index]->i_handle, 0, 0);
      
   return (0);     
}

/* ................................................... id_get_TE_str ................ */

int  id_get_TE_str (
 FORM_REC    *form,
 short        index
)
{
   short  len = 240;
   short  neededLen = TExGetTextLen ((NSTextField *)form->ditl_def[index]->i_handle);
   char  *txtBuffPtr = form->ditl_def[index]->i_data.d_text;
   
   if (form->edit_def[index]->e_longText)  {
      DisposePtr (form->edit_def[index]->e_longText);
      form->edit_def[index]->e_longText = NULL;
   }
   
   if ((neededLen > 240) && (neededLen > form->edit_def[index]->e_maxlen))
      neededLen = form->edit_def[index]->e_maxlen;
   
   if (neededLen <= 240)  {
      TExGetText ((NSTextField *)form->ditl_def[index]->i_handle, txtBuffPtr, &len);
      form->ditl_def[index]->i_data_size = len;
   }
   else  {
      txtBuffPtr = form->edit_def[index]->e_longText = NewPtr ((len = neededLen)+1);

      TExGetText ((NSTextField *)form->ditl_def[index]->i_handle, txtBuffPtr, &len);
      BlockMoveData (txtBuffPtr, form->ditl_def[index]->i_data.d_text, 240);
      form->ditl_def[index]->i_data_size = 255;
   }
   
   return (len);
}

/* ----------------------------------------------------- id_TextWidth ---------------- */

int  id_TextWidth (FORM_REC *form, char *txtPtr, short startOffset, short len)
{
   short  retVal;
   short  result, txtWidth, txtHeight;
   char   tmpStr[256], *buffPtr = NULL;
   
   if (len > 255)  {
      if (!(buffPtr = NewPtr(len+1)))
         len = 255;  // fuck it!
   }
   
   if (!buffPtr)  {
      buffPtr = tmpStr;
   }
   strNCpy (buffPtr, txtPtr+startOffset, len);
   
   result = TExMeasureText (buffPtr, len, &txtWidth, &txtHeight);
      
   retVal = txtWidth + /*(txtWidth/16) +*/ 1;
   
   if (buffPtr != tmpStr)
      DisposePtr (buffPtr);
   
   return (retVal);
}

/* ------------------------------------------------------- id_check_chr_edit_char ---- */

// Used before field change

int  id_check_chr_edit_char (
 FORM_REC  *form,
 short      index,
 char       ch
)
{
   EDIT_item  *f_edit_def = form->edit_def ? form->edit_def[index] : NULL;
   long        fldEditFlags;
   short       selStart, selEnd;
   short       maxLen = form->edit_def ? form->edit_def[index]->e_maxlen : 0;
   
   if (!f_edit_def)
      return (0);
   
   fldEditFlags = f_edit_def->e_fld_edits;
   
   switch (ch)  {
      case  kLeftArrowCharCode:
      case  kRightArrowCharCode:
      case  kUpArrowCharCode:
      case  kDownArrowCharCode:
         // even protected fields
         return (0);
      case  kBackspaceCharCode:
      case  kDeleteCharCode:
         form->pen_flags |= ID_PEN_DIRTY;
         return (0);
   }

   if (((f_edit_def->e_fld_edits & ID_FE_PROTECT) && (ch != 27)) ||
       (ch == 0x7F))  // Manual shit iz Bonce 10.01.03
      return (-1);
      
   if (ch == '\r')  {
      if (!id_isHighField(form, index+1))
         return (-1);
   }
   else  if ((ch == kBackspaceCharCode) || (ch == kDeleteCharCode))  {
      form->pen_flags |= ID_PEN_DIRTY;
      NOT_YET //  id_UDEnable (form, index+1);
      return (0);
   }
   else  if (iscntrl(ch))
      return (0);
   
   if ((fldEditFlags & ID_FE_LETTERS) && (fldEditFlags & ID_FE_DIGITS))  {
      if (!isdigit(ch) && !id_isCroAlpha(ch, TRUE))
         return (-1);
   }
   else  {
      if (fldEditFlags & ID_FE_DIGITS)
         if (!isdigit(ch))
            return (-1);
      if (fldEditFlags & ID_FE_LETTERS)
         if (!id_isCroAlpha (ch, TRUE))
            return (-1);
   }
   if (fldEditFlags & ID_FE_NUMERIC)  {
#ifdef _NIJE_IFCW_
      if (strchr("+=", ch) && (form->w_procID != plainDBox) && (fldEditFlags & (ID_FE_CURRENCY | ID_FE_QUANT)))
         *ifcFlag = TRUE;
      else
#endif  //  _NIJE_IFCW_
      if (!strchr("0123456789-.+", ch))  {   // Plus izvaen 25.01.03
         if (fldEditFlags & (ID_FE_CURRENCY | ID_FE_QUANT))  {
            if ((ch != ',') && (ch != '%'))  {
               if (dtGData->fDblEditCheckProc || form->edit_check_func)  {
                  short  txLen = TExGetTextLen ((NSTextField *)form->ditl_def[index]->i_handle);
                  
                  TExGetSelection ((NSTextField *)form->ditl_def[index]->i_handle, &selStart, &selEnd);
                  
                  // Maybe, maybe, maybe we need to set the original savedPort here,
                  // but we're not expected to draw anything in there anyway...
                  if (form->edit_check_func && (*form->edit_check_func)(form, index+1, txLen, selStart, selEnd, ch))
                     return (-1);
                  else  if (dtGData->fDblEditCheckProc && (*dtGData->fDblEditCheckProc)(form, index+1, txLen, selStart, selEnd, ch))
                     return (-1);
               }
               else
                  return (-1);
            }
         }
         else
            return (-1);
      }
   }
   
   if ((fldEditFlags & ID_FE_DATE) || (fldEditFlags & ID_FE_DATE_MMYY))
      if (!strchr("0123456789.,/+-DdJjGgSsPpMmZz", ch))
         return (-1);
   if (fldEditFlags & ID_FE_TIME)
      if (!strchr("0123456789.,/+-:;", ch))
         return (-1);
   if (f_edit_def->e_regular)
      if (!strchr(f_edit_def->e_regular, ch))   /* --- Regular expression --- */
         return (-1);

   return (0);
}

/* ------------------------------------------------------- id_check_chr_edit_size ---- */

// Used after field change

int  id_check_chr_edit_size (
 FORM_REC  *form,
 short      index,
 short      newSize
)
{
   short       maxLen;
   EDIT_item  *f_edit_def = form->edit_def ? form->edit_def[index] : NULL;
   // short       selStart, selEnd;

   if (!f_edit_def)
      return (0);

   maxLen = form->edit_def[index]->e_maxlen;
   
   if (f_edit_def->e_fld_edits & ID_FE_EXTRA_LEN)  {
      if (f_edit_def->e_precision)
         maxLen = f_edit_def->e_precision;
   }

   if (newSize >= maxLen)  {
      // TExGetSelection ((NSTextField *)form->ditl_def[index]->i_handle, &selStart, &selEnd);
      // if (selStart == selEnd)
      return (-1);
   }
      
   form->pen_flags |= (ID_PEN_DIRTY);
   NOT_YET// id_UDEnable (form, index+1);
         
   return (0);
}

/* ................................................... id_TE_change ................. */

// txn version

int  id_TE_change (
 FORM_REC  *form,
 short      index,
 FontInfo  *fntInfo,  // NOT USED ON OS X
 WindowPtr  savedPort,
 short      sel,
 short      mouseFlag
)
{
   short  txLen, retValue = 0;
   short  atOpen   = FALSE;
   Rect   tmpRect;
   
   if (form->TE_handle)  {
      id_get_TE_str (form, form->cur_fldno);
      if (retValue=id_check_exit(form, form->cur_fldno, savedPort))
         return (retValue);
      else
        TExDeactivate (form->my_window, (NSTextField *)form->TE_handle);
   }
   else
      atOpen = TRUE;
      
   if ((form->ditl_def[index]->i_type & editText))  {

      dtGData->theInput = (NSTextField *)form->ditl_def[index]->i_handle;
      form->TE_handle = (NSTextField *)form->ditl_def[index]->i_handle;
      
      form->cur_fldno = index;

      id_put_TE_str (form, index);
      if (!atOpen)
         id_check_entry (form, index, savedPort);

      id_itemsRect (form, index, &tmpRect);
      
      txLen = id_field_text_length (form, index+1);
      if (sel)
         TExSetSelection ((NSTextField *)form->TE_handle, 0, txLen);
      else  if (!mouseFlag)
         TExSetSelection ((NSTextField *)form->TE_handle, txLen, txLen);

      TExActivate (form->my_window, (NSTextField *)form->TE_handle);                   /* Make it active */
      TExUpdate ((NSTextField *)form->TE_handle, &tmpRect);
      if (!atOpen)
         id_post_TE_change (form, index);
   }
   else
      return (-1);
   
   return (retValue);
}

void  id_post_TE_change (
 FORM_REC  *form,
 short      index
)
{
   char  shortText[32];
   
   if (id_field_text_length(form, index+1))
      sprintf (shortText, "%hd", (short)id_field_text_length(form, index+1));
   else
      shortText[0] = '\0';
   id_SetStatusbarText (form, 1, shortText);
}

/* .......................................................... id_gofield ............ */

int  id_gofield (
 FORM_REC  *form,
 short      fldno, 
 short      sel
)
{
   short      retVal = 0, index = fldno-1;
   WindowPtr  savedPort;
         
   if (id_inpossible_item(form, index))  {
      return (-1);
   }
   
   id_GetPort (form, &savedPort);
   id_SetPort (form, (WindowPtr)form->my_window);
   
   if ((form->ditl_def[index]->i_type & editText))
      retVal = id_TE_change (form, index, NULL, savedPort, sel, FALSE);
   
   id_SetPort (form, savedPort);
   
   return (retVal);
}

#pragma mark -

int  id_find_next_fld (
 FORM_REC  *form
)
{
   short       i, index, level = 0;
   Rect        tmpRect;
   DITL_item  *f_ditl_def;
   EDIT_item  *f_edit_def;
   
   index = form->cur_fldno;
   
   f_ditl_def = form->ditl_def[index];
   f_edit_def = form->edit_def[index];
   
   if (f_edit_def->e_next_field && (f_edit_def->e_next_field <= form->last_fldno+1))  {
      id_base_fldno (form, index+1, &level);
      if (form->sfPage)  {
         // See if we need to move to the next level
         if ((f_edit_def->e_next_field == form->sfStart) && (index+1 - level == form->sfEnd))
            if (level+1 < form->sfPage)
               return (f_edit_def->e_next_field-1+level+1);
      }
      return (f_edit_def->e_next_field-1+level);
   }
   
   if (f_edit_def->e_type & ID_UT_ARRAY)  {                // TextEdit Arrays
      tmpRect = f_ditl_def->i_rect;                        // Must be naked rect!
      
      if (form->sfPage)  {
         i = index + form->sfPage;
         f_ditl_def = form->ditl_def[i];
         f_edit_def = form->edit_def[i];
         if ((f_ditl_def->i_type == editText) && (f_edit_def->e_type & ID_UT_ARRAY))
            return (i);
         else  {
            level = (index - (form->sfStart - 1)) % form->sfPage + 1;
            if (level < form->sfPage)  {
               i = form->sfStart - 1 + level;
               f_ditl_def = form->ditl_def[i];
               f_edit_def = form->edit_def[i];
               if ((f_ditl_def->i_type == editText) && (f_edit_def->e_type & ID_UT_ARRAY))
                  return (i);
            }
         }
            
      }
      
      for (i=form->cur_fldno+1; i<=form->last_fldno; i++)  {
         f_ditl_def = form->ditl_def[i];
         f_edit_def = form->edit_def[i];
         if ((f_ditl_def->i_type == editText) && (f_edit_def->e_type & ID_UT_ARRAY) && !(f_edit_def->e_fld_edits & ID_FE_ANY_SKIP))
            if ((f_ditl_def->i_rect.top == tmpRect.top)/* && (f_ditl_def->i_rect.bottom == tmp_rect.bottom)*/)
               return (i);
      }

      if (form->cur_fldno < form->last_fldno)  {      /* Za zadnji stupac -> poËetak sljedeÊeg reda */
         index = form->cur_fldno+1;
         f_ditl_def = form->ditl_def[index];
         f_edit_def = form->edit_def[index];
         if ((f_ditl_def->i_type == editText) && (f_edit_def->e_type & ID_UT_ARRAY) /*&& !(f_edit_def->e_fld_edits & ID_FE_ANY_SKIP)*/)  {
            // 09.12.2015 - ugaπena ova skip provjera, nije vaæno dal je tekuÊe polje skip nego iduÊe
            // short  prevFld = 0;
            // short  baseFldno = id_base_fldno (form, form->cur_fldno+1, &level);
            
            tmpRect = f_ditl_def->i_rect;

            for (i=0; i<form->cur_fldno; i++)  {
               f_ditl_def = form->ditl_def[i];
               f_edit_def = form->edit_def[i];
               if ((f_ditl_def->i_type == editText) && (f_edit_def->e_type & ID_UT_ARRAY) && !(f_edit_def->e_fld_edits & ID_FE_ANY_SKIP))  {
                  if ((f_ditl_def->i_rect.top == tmpRect.top) /*&& (f_ditl_def->i_rect.bottom == tmp_rect.bottom)*/)
                     return (i);
#ifdef _NIJE_
                  else  if (!prevFld && (f_edit_def->e_next_field == form->cur_fldno+1))
                     prevFld = i+1;
#endif
               }
            }
            
            // Now try with the upper fild when paired (two lines of fields, like in joppd)
#ifdef _NIJE_
            tmpRect = form->ditl_def[prevFld-1+level]->i_rect;
            
            for (i=0; i<form->cur_fldno; i++)  {
               f_ditl_def = form->ditl_def[i];
               f_edit_def = form->edit_def[i];
               if ((f_ditl_def->i_type == editText) && (f_edit_def->e_type & ID_UT_ARRAY) && !(f_edit_def->e_fld_edits & ID_FE_ANY_SKIP))  {
                  if ((f_ditl_def->i_rect.top == tmpRect.top) /*&& (f_ditl_def->i_rect.bottom == tmp_rect.bottom)*/)
                     return (i);
               }
            }
#endif
         }
      }
   }

   for (i=form->cur_fldno+1; i<=form->last_fldno; i++)  {   /* Standard TextEdit */
      if (form->ditl_def[i]->i_type == editText &&
          !(form->edit_def[i]->e_fld_edits & ID_FE_ANY_SKIP))
         return (i);
   }
   
   for (i=0; i<=form->last_fldno; i++)  {
      if (form->ditl_def[i]->i_type == editText &&
          !(form->edit_def[i]->e_fld_edits & ID_FE_ANY_SKIP))
         return (i);
   }

   return (form->cur_fldno);
}

/* ----------------------------------------------------------- id_find_prev_fld ------ */

int  id_find_prev_fld (
 FORM_REC   *form
)
{
   short  i, nowGet, savedCurFldno, lastGet;
   
   savedCurFldno = lastGet = form->cur_fldno;
   
   /*
   for (i=form->cur_fldno-1; i>=0; i--)  {
      if (form->ditl_def[i]->i_type == editText)
         return (i);
   }
   */
   
   for (i=0; i<=form->last_fldno; i++)  {
      if ((form->ditl_def[i]->i_type != editText) || (form->edit_def[i]->e_fld_edits & ID_FE_ANY_SKIP))
         continue;
      lastGet = i;
      form->cur_fldno = i;
      nowGet = id_find_next_fld (form);
      if (nowGet == savedCurFldno)  {
         form->cur_fldno = savedCurFldno;
         return (lastGet);
      }
   }
   form->cur_fldno = savedCurFldno;

   for (i=form->last_fldno; i>=form->cur_fldno; i--)  {
      if (form->ditl_def[i]->i_type == editText && !(form->edit_def[i]->e_fld_edits & ID_FE_ANY_SKIP))
         return (i);
   }

   return (form->cur_fldno);
}

#pragma mark Fonts

/* ----------------------------------------------------- GetFontNum ------------------ */

int  GetFontNum (char *fontName, short *fontNum)
{
   static NSArray  *fontFamilyNames = nil;  // One day to dtGData
   
   *fontNum = 0;
   
   if (!stricmp(fontName, "NewYork"))
      *fontNum = newYork;
   else  if (!stricmp(fontName, "Geneva"))
      *fontNum = geneva;
   else  if (!stricmp(fontName, "Monaco"))
      *fontNum = monaco;
   else  if (!stricmp(fontName, "Times"))
      *fontNum = times;
   else  if (!stricmp(fontName, "Helvetica"))
      *fontNum = helvetica;
   else  if (!stricmp(fontName, "Courier"))
      *fontNum = courier;
   else  {
      if (!fontFamilyNames)  {
         NSFontManager  *fontManager = [NSFontManager sharedFontManager];
         
         fontFamilyNames = [fontManager availableFontFamilies];
      }
      if (fontFamilyNames && fontFamilyNames.count)  {
         for (int i=0; i<fontFamilyNames.count; i++)  {  
            NSString  *ffName = [fontFamilyNames objectAtIndex:i];
            
            if (!stricmp(fontName, (char *)[ffName UTF8String]))
                *fontNum = i+100;
         }
      }
   }
   
   if (!(*fontNum))
      return (-1);

   return (0);
}

int  GetFontName (short fontNum, char *fontName, short maxLen)
{
   static NSArray  *fontFamilyNames = nil;  // One day to dtGData
   
   *fontName = '\0';
   
   switch (fontNum)  {
      case  0:  strNCpy (fontName, "Lucida Grande", maxLen);  break;
      case  newYork:  strNCpy (fontName, "NewYork", maxLen);  break;
      case  geneva:  strNCpy (fontName, "Geneva", maxLen);  break;
      case  monaco:  strNCpy (fontName, "Monaco", maxLen);  break;
      case  times:  strNCpy (fontName, "Times", maxLen);  break;
      case  helvetica:  strNCpy (fontName, "Helvetica", maxLen);  break;
      case  courier:  strNCpy (fontName, "Courier", maxLen);  break;
      default:
         if (fontNum >= 100)  {
            if (!fontFamilyNames)  {
               NSFontManager  *fontManager = [NSFontManager sharedFontManager];
               
               fontFamilyNames = [fontManager availableFontFamilies];
            }
         }
         if (fontFamilyNames && fontFamilyNames.count)  {
            fontNum -= 100;
            if (fontNum >= 0 && fontNum<fontFamilyNames.count)  {  
               NSString  *ffName = [fontFamilyNames objectAtIndex:fontNum];
               
               strNCpy (fontName, (char *)[ffName UTF8String], maxLen);  break;
            }
         }
         break;
   }   
   
   if (!(*fontName))
      return (-1);

   return (0);
}

/* ----------------------------------------------------- id_SetFont ------------------ */

NSFont  *id_GetFont (short txtFont, short txtSize, short txtFace)
{
   char  fontName[256];
   
   if (!GetFontName(txtFont, fontName, 255))  {
      CFStringRef  cfStr;
      NSFont      *font = nil;

      id_Mac2CFString (fontName, &cfStr, strlen(fontName));

      font = [NSFont fontWithName:(NSString *)cfStr size:txtSize];
      
      CFRelease (cfStr);
      
      if (font)  {
         if (txtFace != normal)  {
            NSFontTraitMask  mask = 0;
            
            if (txtFace & italic)
               mask |= NSItalicFontMask;
            if (txtFace & bold)
               mask |= NSBoldFontMask;
            if (txtFace & condense)
               mask |= NSCondensedFontMask;
            
            font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:mask];
         }
         
         return (font);
      }
   }
   
   return (nil);
}

/* ----------------------------------------------------- id_SetFont ------------------ */

int  id_SetFont (FORM_REC *form, short index, short txtFont, short txtSize, short txtFace)
{
   NSFont  *font = id_GetFont (txtFont, txtSize, txtFace);
      
   if (font)  {
      if ((index >= 0) && (index <= form->last_fldno) && form->ditl_def[index]->i_handle)  {
         NSControl  *theCtl = (NSControl *)form->ditl_def[index]->i_handle;
         
         theCtl.font = font;
      }
      else
         form->currentFont = font;
   }
   
   return (0);
}

int  id_GetScaledFontSize (FORM_REC *form, short oSize)
{
   if (form)  switch (form->scaleRatio)  {
      case  100:
      case  110:
         return (oSize ? oSize : 12);
      default:
         if (oSize)
            return (oSize + (form->scaleRatio - 110) / 10);
         else  if (form->scaleRatio == 120)
            return (13);
         else  if (form->scaleRatio > 120)
            return (14);
   }
   
   return (oSize);
}

void  id_SetUpLayout (
 ID_LAYOUT  *theLayout,
 short       oFont,
 short       oSize,
 short       oFace
)
{
   theLayout->oFont = oFont;
   theLayout->oSize = oSize;
   theLayout->oFace = oFace;
}

/* ----------------------------------------------------------- id_SetLayout ---------- */

void  id_SetLayout (
 FORM_REC   *form,
 short       index,
 ID_LAYOUT  *theLayout
)
{
   NSFont  *font = id_GetFont (theLayout->oFont,
                               form ? id_GetScaledFontSize(form, theLayout->oSize) : theLayout->oSize,
                               theLayout->oFace);
   
   if ((index >= 0) && (index <= form->last_fldno) && form->ditl_def[index]->i_handle)  {
      NSControl  *theCtl = (NSControl *)form->ditl_def[index]->i_handle;
      
      theCtl.font = font;
   }
}

/* ----------------------------------------------------------- id_set_edit_layout ---- */

void  id_set_edit_layout (FORM_REC *form, short index)  // Used only down there
{
   id_SetLayout (form, index, &dtGData->layEdit);
}

void  id_my_edit_layout (
 FORM_REC  *form,
 short      index
)
{
   if ((index >= 0) && (index <= form->last_fldno) && form->edit_def[index]->e_fld_layout)  {
      id_SetLayout (form, index, form->edit_def[index]->e_fld_layout);
   }
   else  if (form->edit_layout)  {
      id_SetLayout (form, index, form->edit_layout);
   }
   else
      id_set_edit_layout (form, index);
}

void  id_set_stat_layout (FORM_REC *form, short index)
{
   id_SetLayout (form, index, &dtGData->layStat);
}
 
void  id_my_stat_layout (
 FORM_REC  *form,
 short      index
)
{
   if ((index >= 0) && (index <= form->last_fldno) && form->edit_def[index]->e_fld_layout)  {
      id_SetLayout (form, index, form->edit_def[index]->e_fld_layout);
   }
   else  if (form->stat_layout)  {
      id_SetLayout (form, index, form->stat_layout);
   }
   else
      id_set_stat_layout (form, index);
}

void id_set_comment_layout (FORM_REC *form)
{
   id_SetLayout (form, -1, &dtGData->layComm);
}

void  id_set_list_layout (FORM_REC *form, short index)
{
   id_SetLayout (form, index, &dtGData->layList);
}

void  id_my_list_layout (
 FORM_REC  *form,
 short      index
)
{
   if ((index >= 0) && (index <= form->last_fldno) && form->edit_def[index]->e_fld_layout)  {
      id_SetLayout (form, index, form->edit_def[index]->e_fld_layout);
   }
   else  if (form->list_layout)  {
      id_SetLayout (form, index, form->list_layout);
   }
   else
      id_set_list_layout (form, index);
}

void  id_my_popUp_layout (
 FORM_REC  *form,
 short      index
)
{
   if ((index >= 0) && (index <= form->last_fldno) && form->edit_def[index]->e_fld_layout)  {
      id_SetLayout (form, index, form->edit_def[index]->e_fld_layout);
   }
   else  if (form->popUp_layout)  {
      id_SetLayout (form, index, form->popUp_layout);
   }
   else
      id_SetFont (form, index, geneva, form ? id_GetScaledFontSize(form, 12) : 12, normal);
}

void  id_set_system_layout (FORM_REC *form, short index)
{
   id_SetFont (form, index, geneva, form ? id_GetScaledFontSize(form, 12) : 12, normal);
}

/* ----------------------------------------------------------- id_pen_down ---------- */

void  id_pen_down (
 FORM_REC  *form,
 short      fldno
)
{
   short   index;

   id_set_pen (form, ID_PEN_DOWN, TRUE);
   if (fldno > 0)  {
      id_gofield (form, fldno, 0);
      NOT_YET // id_UDSet (form, fldno);
   }
   
   for (index=0; index<form->last_fldno+1; index++)  {          /* Mind Icons */
      if ((form->ditl_def[index]->i_type & 127) == userItem)  {
         if (form->edit_def[index]->e_type == ID_UT_ICON_ITEM)  {
            if (form->edit_def[index]->e_fld_edits & ID_FE_UP_ONLY)  {
               id_disable_field (form, index+1);
               id_redraw_field (form, index+1);
            }
         }
         else  if (form->edit_def[index]->e_type & ID_UT_TEPOP)  {
            if (form->edit_def[index]->e_fld_edits & ID_FE_DOWN_ONLY)  {
               id_enable_field (form, index+1);
               id_redraw_field (form, index+1);
            }
         }
      }
      else
         if (form->ditl_def[index]->i_type & ctrlItem)  {
            if (form->edit_def[index]->e_fld_edits & ID_FE_UP_ONLY)
               id_disable_field (form, index+1);
            else  if (form->edit_def[index]->e_fld_edits & ID_FE_DOWN_ONLY)
               id_enable_field (form, index+1);
         }
   }

   if (form->update_func)
      (*form->update_func)(form, NULL, ID_PEN_DOWN_UPDATE, 0);
}

/* ----------------------------------------------------------- id_pen_up ------------ */

// Pen up should go through all edit fields and remove editability and focus/first responder, pen down should restore it

void  id_pen_up (
 FORM_REC  *form
)
{
   short  index;
   short  selStart, selEnd;
   Rect   tmpRect;

   NSTextField  *tmpTEH;
   WindowPtr     savedPort;

   id_set_pen (form, ID_PEN_DOWN | ID_PEN_DIRTY /*| ID_PEN_FLDIRT*/, FALSE);
   NOT_YET // id_UDDisable ();
   
   if (form->TE_handle && ((index=form->cur_fldno) >= 0))  {
      id_GetPort (form, &savedPort);
      id_SetPort (form, (WindowPtr)form->my_window);
      tmpTEH = form->TE_handle;
      TExGetSelection (tmpTEH, &selStart, &selEnd);
      if ((selEnd >= id_field_text_length(form, index+1)) || (selStart > selEnd))
         TExSetSelection (tmpTEH, 0, 0);

      TExDeactivate (form->my_window, (NSTextField *)tmpTEH);
      id_itemsRect (form, index, &tmpRect);
      TExUpdate (tmpTEH, &tmpRect);
      id_SetPort (form, savedPort);
      
      id_SetStatusbarText (form, 1, "");
   }
   
   for (index=0; index<form->last_fldno+1; index++)  {
      if ((form->ditl_def[index]->i_type & 127) == userItem)  {
         /*if (form->edit_def[index]->e_type == ID_UT_ICON_ITEM)*/
            if (form->edit_def[index]->e_fld_edits & ID_FE_DOWN_ONLY)  {
               id_disable_field (form, index+1);
               id_redraw_field (form, index+1);
            }
            else if (form->edit_def[index]->e_fld_edits & ID_FE_UP_ONLY)  {
               id_enable_field (form, index+1);
               id_redraw_field (form, index+1);
            }
      }
      else
         if (form->ditl_def[index]->i_type & ctrlItem)  {
            if (form->edit_def[index]->e_fld_edits & ID_FE_DOWN_ONLY)
               id_disable_field (form, index+1);
            else  if (form->edit_def[index]->e_fld_edits & ID_FE_UP_ONLY)
               id_enable_field (form, index+1);
         }
   }
   
   id_SetCursor (form, 0);
   
   if (form->update_func)
      (*form->update_func)(form, NULL, ID_PEN_UP_UPDATE, 0);
}

/* ----------------------------------------------------------- id_get_pen ----------- */

int  id_get_pen (
 FORM_REC  *form,
 short      chk_flag
)
{
   return (form->pen_flags & chk_flag);
}

/* ----------------------------------------------------------- id_set_pen ----------- */

int  id_set_pen (
 FORM_REC  *form,
 short      my_flag,
 short      state
)
{
   if (state)
      return (form->pen_flags |= my_flag);
   else
      return (form->pen_flags &= (~my_flag));
}

#pragma mark -

// Needed only for windows as all views are flipped

CGRect  id_CocoaRect (NSWindow *window, CGRect nmlRect)
{
   NSView  *contentView = window ? [window contentView] : nil;
   CGRect   contentRect = window ? contentView.bounds : [[NSScreen mainScreen] frame];
   CGRect   cocoaRect = nmlRect;
   
   if (window && !contentView)  // If we're too early in the process
      contentRect = [window contentRectForFrameRect:window.frame];
   
   if (!window || ![contentView isFlipped])
      cocoaRect.origin.y = contentRect.size.height - (nmlRect.origin.y + nmlRect.size.height);
   
   return (cocoaRect);
}

CGRect  id_CarbonRect (NSWindow *window, CGRect cocoaRect)
{
   NSView  *contentView = window ? [window contentView] : nil;
   CGRect   contentRect = window ? contentView.bounds : [[NSScreen mainScreen] frame];
   CGRect   nmlRect = cocoaRect;
   
   if (window && !contentView)  // If we're too early in the process
      contentRect = [window contentRectForFrameRect:window.frame];

   if (!window || ![contentView isFlipped])
      nmlRect.origin.y = contentRect.size.height - nmlRect.size.height - cocoaRect.origin.y;
   
   return (nmlRect);
}

#pragma mark Printing

int  idp_OpenPrintSession (ID_PR_DATA *prd)
{
   OSStatus   status = noErr;
   // short      len = 255;
   
   CGContextRef  cgCtx = NULL;
   
   if (!prd->printSession)
      status = PMCreateSession (&prd->printSession);
   
   if (!status)  {
      prd->pageFormat = prd->pageFormatPortrait;
      
      status = PMSessionGetCGGraphicsContext (prd->printSession, &cgCtx);
      
      if (cgCtx)
         NSLog (@"Ha ha, context!");
   }
   
   return (status);
}

/* .........................................................idp_ClosePrintSession..... */

int  idp_ClosePrintSession (ID_PR_DATA *prd)
{
   // if (prd->pageFormat)  {
   //    PMRelease (prd->pageFormat);  -> KEEP IT!
   //    prd->pageFormat = NULL;
   // }
   
   if (prd->printSettings)  {
      PMRelease (prd->printSettings);
      prd->printSettings = NULL;
   }
   
   /*if (oldPrinterId[0] && id_prData->posPrinterID[0] && (cur_print_job.mode & IDP_PJ_POS_PRINTER))  {
    char  tmpPrinterId[64];
    
    if (idp_ChangePrinter (oldPrinterId, tmpPrinterId, 63))
    con_printf ("Failed to change from %s to %s", oldPrinterId, tmpPrinterId);
    else
    con_printf ("Back to %s", oldPrinterId);
    }
    
    oldPrinterId[0] = '\0';*/
   
   if (prd->printSession)  {
      PMRelease (prd->printSession);
      prd->printSession = NULL;
   }
   
   return (noErr);
}

#pragma mark Resources

/* ----------------------------------------------------------- id_copy_DITL_info ----- */

void id_copy_DITL_info (                             /* -- Copies from DITL Resource -- */
 DITL_item  **ditl_def,
 Handle       ditl_handle
)
{
   short          last_item, i;
   char          *cur_ditl = *ditl_handle; 
    
   last_item = *((short *)cur_ditl);
    
   for (i=0,cur_ditl+=2; i<=last_item; i++)  {
#ifdef _DTOOL_COCOA_
      char  *tarPtr = (char *)ditl_def[i];
      ditl_def[i]->i_handle = NULL;
      BlockMove (cur_ditl+4, tarPtr+8, sizeof (DITL_rsrc_item)-4);
#else
      BlockMove (cur_ditl, ditl_def[i], sizeof (DITL_item));
#endif
      cur_ditl += (14 + ditl_def[i]->i_data_size+ditl_def[i]->i_data_size%2);  // OK
   }
}

// Original function when skipOthers is FALSE
// Needed skipOthers as TRUE when appending more items, like for AfterView

void id_attach_EDIT_info (                     /*- Just attaching the pointers -*/
 FORM_REC    *form,
 EDIT_item   *edit_array,
 short        last_fldno,
 short        skipOthers
)
{
   short        i;
   EDIT_item  **edit_def = form->edit_def;
   
   for (i=0; i<=last_fldno; i++)  {
      if (edit_array && (edit_array->e_fldno-1 == i))  {
         edit_def[i] = edit_array;
         edit_array++;
      }
      else  if (!skipOthers)
         edit_def[i] = &default_edit_item/*NULL*/;
   }
   if (edit_def && edit_array && edit_array->e_fldno)
      id_SysBeep (10);
}

static int  pr_InspectMenu (short theMenuID)  // 129 is File menu
{
   Handle      mh = (Handle)GetResource ('MENU', theMenuID); 
   MENU_rsrc  *mr = NULL;
   char        tmpStr[256], *chPtr;
   short       dataSize = 0;
   
   if (mh)  {
      HLock (mh);
      mr = (MENU_rsrc *)*mh;
      
      dataSize = mr->i_title_size;
      BlockMove (mr->i_title, tmpStr, dataSize);
      tmpStr[dataSize] = '\0';
      
      // NSLog (@"Menu title: %s\n", tmpStr);
      
      for (chPtr=mr->i_title+dataSize+1, dataSize=*(chPtr-1); dataSize; chPtr += dataSize+1+3+1,dataSize=*(chPtr-1))  {
         BlockMove (chPtr, tmpStr, dataSize);
         tmpStr[dataSize] = '\0';
         // NSLog (@"Item title: %s (%c)\n", tmpStr, *(chPtr + dataSize+1) ? *(chPtr + dataSize+1) : ' ');
      }
      
      HUnlock (mh);
      return (0);
   }
   
   return (-1);
}

static int  pr_CreateMenu (NSMenu *menuBar, id target, short theMenuID)  // 129 is File menu
{
   char    tmpStr[256], *chPtr;
   short   i, dataSize = 0;
   Handle  mh = (Handle)GetResource ('MENU', theMenuID);

   CFStringRef  cfStr;
   NSString    *commandChar = nil;
   NSMenuItem  *theMenuItem = [NSMenuItem new], *tmpMenuItem;
   NSMenu      *theMenu = nil;  // [[NSMenu alloc] initWithTitle:@"File"];
   MENU_rsrc   *mr = NULL;
   
   NiblessTestAppDelegate  *appDelegate = (NiblessTestAppDelegate *)[NSApp delegate];
   NSMutableDictionary    *menuDict = appDelegate.menuDict;
   
   if (!mh)  {
      id_OpenInternalResFile ();
      mh = (Handle)GetResource ('MENU', theMenuID);
   }
   
   if (mh)  {
      HLock (mh);
      mr = (MENU_rsrc *)*mh;
      
      dataSize = mr->i_title_size;
      BlockMove (mr->i_title, tmpStr, dataSize);
      tmpStr[dataSize] = '\0';
      
      // NSLog (@"Menu title: %s\n", tmpStr);
      
      id_Mac2CFString (tmpStr, &cfStr, strlen(tmpStr));
      
      theMenu = [[NSMenu alloc] initWithTitle:(NSString *)cfStr];
      
      // theMenu.tag = theMenuID;
      
      [menuDict setObject:[NSNumber numberWithInt:theMenuID] forKey:theMenu.title];
      
      CFRelease (cfStr);
      
      for (i=1,chPtr=mr->i_title+dataSize+1, dataSize=*(chPtr-1); dataSize; chPtr += dataSize+1+3+1,dataSize=*(chPtr-1),i++)  {
         BlockMove (chPtr, tmpStr, dataSize);
         tmpStr[dataSize] = '\0';
         // NSLog (@"Item title: %s (%c)\n", tmpStr, *(chPtr + dataSize+1) ? *(chPtr + dataSize+1) : ' ');

         if (!strcmp(tmpStr, "-"))
            [theMenu addItem:[NSMenuItem separatorItem]];
         else  {
            id_Mac2CFString (tmpStr, &cfStr, strlen(tmpStr));
            if (*(chPtr + dataSize+1))
               commandChar = [NSString stringWithFormat:@"%c", tolower(*(chPtr + dataSize+1))];
            else
               commandChar = @"";
            
            tmpMenuItem = [theMenu addItemWithTitle:(NSString *)cfStr action:@selector(menuAction:) keyEquivalent:commandChar];
            [tmpMenuItem setTarget:target];
            [tmpMenuItem setEnabled:YES];
            [tmpMenuItem setTag:MakeLong(i,theMenuID)];
            
            CFRelease (cfStr);
         }
      }
      
      HUnlock (mh);

      [theMenuItem setSubmenu:theMenu];
      [menuBar addItem:theMenuItem];
      
      [theMenu release];

      return (0);
   }
   
   return (-1);
}

static int  pr_InsertSubMenu (NSMenuItem *parentMenuItem, id target, short theMenuID)
{
   char    tmpStr[256], *chPtr;
   short   i, dataSize = 0;
   Handle  mh = (Handle)GetResource ('MENU', theMenuID); 

   CFStringRef  cfStr;
   NSString    *commandChar = nil;
   // NSMenuItem  *theMenuItem = [NSMenuItem new];
   NSMenuItem  *tmpMenuItem = nil;
   NSMenu      *theMenu = nil;  // [[NSMenu alloc] initWithTitle:@"File"];
   MENU_rsrc   *mr = NULL;
   
   NiblessTestAppDelegate  *appDelegate = (NiblessTestAppDelegate *)[NSApp delegate];
   NSMutableDictionary    *menuDict = appDelegate.menuDict;

   if (mh)  {
      HLock (mh);
      mr = (MENU_rsrc *)*mh;
      
      dataSize = mr->i_title_size;
      BlockMove (mr->i_title, tmpStr, dataSize);
      tmpStr[dataSize] = '\0';
      
      // NSLog (@"Menu title: %s\n", tmpStr);
      
      // id_Mac2CFString (tmpStr, &cfStr, strlen(tmpStr));
      
      theMenu = [[NSMenu alloc] initWithTitle:parentMenuItem.title/*(NSString *)cfStr*/];
      
      [menuDict setObject:[NSNumber numberWithInt:theMenuID] forKey:theMenu.title];
      
      // CFRelease (cfStr);
      
      for (i=1,chPtr=mr->i_title+dataSize+1, dataSize=*(chPtr-1); dataSize; chPtr += dataSize+1+3+1,dataSize=*(chPtr-1),i++)  {
         BlockMove (chPtr, tmpStr, dataSize);
         tmpStr[dataSize] = '\0';
         // NSLog (@"Item title: %s (%c)\n", tmpStr, *(chPtr + dataSize+1) ? *(chPtr + dataSize+1) : ' ');

         if (!strcmp(tmpStr, "-"))
            [theMenu addItem:[NSMenuItem separatorItem]];
         else  {
            id_Mac2CFString (tmpStr, &cfStr, strlen(tmpStr));
         
            if (*(chPtr + dataSize+1))
               commandChar = [NSString stringWithFormat:@"%c", tolower(*(chPtr + dataSize+1))];
            else
               commandChar = @"";

            tmpMenuItem = [theMenu addItemWithTitle:(NSString *)cfStr action:@selector(menuAction:) keyEquivalent:commandChar];
            [tmpMenuItem setTarget:target];
            [tmpMenuItem setEnabled:YES];
            [tmpMenuItem setTag:MakeLong(i,theMenuID)];

         
            CFRelease (cfStr);
         }
      }
      
      HUnlock (mh);

      [parentMenuItem setSubmenu:theMenu];
      // [parentMenuItem addItem:theMenuItem];
      
      [theMenu release];

      return (0);
   }
   
   return (-1);
}

#pragma mark Alloc

#define  maxSize  0xAFFFFFF0

void *id_calloc (size_t count, size_t size)
{
   if (size > maxSize)
      return (NULL);
   if (size & 1)
      ++size;
   size *= count;
   if (size > maxSize)
      return (NULL);
   return (NewPtr(size));
}

char  **id_malloc_array (
 size_t  n,
 size_t  sz
)
{
   char  **aPtr, *elemPtr;
   short   i;
   
   if (!(aPtr = (char **) NewPtr (n*sizeof(elemPtr))))
      return (NULL);
   
   // if you set up elements on your own, beware of id_free_array()
   
   if (sz)  {
      if (!(elemPtr = (char *)id_calloc(n,sz)))  {
         DisposePtr ((Ptr)aPtr);
         return (NULL);
      }
      
      for (i=0; i<n; i++)  {
         aPtr[i] = elemPtr;
         elemPtr += sz;
      }
   }
   
   id_clear_array (aPtr, n, sz);

   return (aPtr);
}

/* .................................................... id_clear_array .............. */

void  id_clear_array (
 char   **aPtr,
 size_t   n,
 size_t   sz
)
{
   size_t  i;
   
   if (sz)
      id_SetBlockToZeros (aPtr[0], n * sz);
   else  {
      for (i=0; i<n; i++)  {
         aPtr[i] = NULL;
      }
   }
}

/* .................................................... id_free_array ............... */

void id_free_array (
 char **aPtr
)
{
   if (aPtr)  {
      if (aPtr[0])
         DisposePtr (aPtr[0]);
      DisposePtr ((char *)aPtr);
   }
}

#pragma mark Dates

static char  *id_text_date_fmt2 (unsigned short dateShort, char *txtBuff);

static CFTimeZoneRef  gGSystemTimeZone = NULL;  // CFTimeZoneCopySystem(void);

/* .......................................................... GetStartOfTimeDate .... */

void  GetStartOfTimeDate (CFGregorianDate *gregDate)
{
   // unsigned long  totalSecs;
   // DateTimeRec    dtRec;
   
   if (!gGSystemTimeZone)
      gGSystemTimeZone = CFTimeZoneCopySystem ();
   
   gregDate->year = 1904;
   gregDate->month = 1;
   gregDate->day   = 1;
   gregDate->hour = 0;
   gregDate->minute = 0;
   gregDate->second = 0;
}

/* .......................................................... GetStartOfTime ........ */

CFTimeInterval  GetStartOfTime (void)
{
   // unsigned long  totalSecs;
   // DateTimeRec    dtRec;
   
   CFGregorianDate  gregDate;
   
   GetStartOfTimeDate (&gregDate);
   
   CFTimeInterval  startOfTimeInterval = CFGregorianDateGetAbsoluteTime (gregDate, gGSystemTimeZone);
   
   return (startOfTimeInterval);
}

/* .......................................................... SecondsToDate ......... */

void  SecondsToDate (unsigned long secs, DateTimeRec *dtRec)
{
   CFGregorianUnits  gUnits;
   
   if (!gGSystemTimeZone)
      gGSystemTimeZone = CFTimeZoneCopySystem ();

   id_SetBlockToZeros (&gUnits, sizeof(CFGregorianUnits));
   
   gUnits.days = id_secs2Short (secs);
   
   CFTimeInterval   startOfTimeInterval = GetStartOfTime ();  // kCFAbsoluteTimeIntervalSince1904;
   CFAbsoluteTime   theTimeInterval = CFAbsoluteTimeAddGregorianUnits (startOfTimeInterval, gGSystemTimeZone, gUnits);
   
   CFGregorianDate  gDate = CFAbsoluteTimeGetGregorianDate(theTimeInterval, gGSystemTimeZone);
   
   dtRec->year = gDate.year;
   dtRec->month = gDate.month;
   dtRec->day = gDate.day;
   dtRec->hour = gDate.hour;
   dtRec->minute = gDate.minute;
   dtRec->second = gDate.second;
   dtRec->dayOfWeek = CFAbsoluteTimeGetDayOfWeek (theTimeInterval, gGSystemTimeZone);
}

/* .......................................................... DateToSeconds ......... */

void  DateToSeconds (const DateTimeRec *dtRec, unsigned long *secs)
{
   // unsigned long  totalSecs;
   // DateTimeRec    dtRec;
   
   CFGregorianDate  gDate;
   
   if (!gGSystemTimeZone)
      gGSystemTimeZone = CFTimeZoneCopySystem ();

   gDate.year = dtRec->year;
   gDate.month = dtRec->month;
   gDate.day = dtRec->day;
   gDate.hour = dtRec->hour;
   gDate.minute = dtRec->minute;
   gDate.second = dtRec->second;
   
   CFTimeInterval   startOfTimeInterval = GetStartOfTime ();  // kCFAbsoluteTimeIntervalSince1904;
   // CFAbsoluteTime   nowTimeInterval = CFAbsoluteTimeGetCurrent ();
   
   // CFGregorianDate  startOfTimeDate =  CFAbsoluteTimeGetGregorianDate (startOfTimeInterval, gGSystemTimeZone);
   CFTimeInterval  theTimeInterval = CFGregorianDateGetAbsoluteTime (gDate, gGSystemTimeZone);
   
   CFGregorianUnits  diff = CFAbsoluteTimeGetDifferenceAsGregorianUnits (theTimeInterval, startOfTimeInterval, gGSystemTimeZone, kCFGregorianUnitsSeconds);
   
   *secs = diff.seconds;
}

void  GetTime (DateTimeRec *dtRec)
{
   CFAbsoluteTime   nowTimeInterval = CFAbsoluteTimeGetCurrent ();
   CFGregorianDate  gDate =  CFAbsoluteTimeGetGregorianDate (nowTimeInterval, gGSystemTimeZone);
      
   dtRec->year = gDate.year;
   dtRec->month = gDate.month;
   dtRec->day = gDate.day;
   dtRec->hour = gDate.hour;
   dtRec->minute = gDate.minute;
   dtRec->second = gDate.second;
   dtRec->dayOfWeek = CFAbsoluteTimeGetDayOfWeek (nowTimeInterval, gGSystemTimeZone);
}

void  GetDateTime (unsigned long *secs)
{
   DateTimeRec  dtRec;
   
   GetTime (&dtRec);
   DateToSeconds (&dtRec, secs);
}

#pragma mark -

/* .......................................................... id_secs2Short ......... */

unsigned short id_secs2Short (
 unsigned long totalSecs
)
{
   return (totalSecs/(60*60*24UL) + 1UL);
}

unsigned short  id_sys_date (void)
{
   unsigned long  totalSecs;
   
#ifdef _NIJE_  
   CFAbsoluteTime   startOfTimeInterval = GetStartOfTime ();  // kCFAbsoluteTimeIntervalSince1904;
   CFAbsoluteTime   nowTimeInterval = CFAbsoluteTimeGetCurrent ();
   
   // CFGregorianDate  startOfTimeDate =  CFAbsoluteTimeGetGregorianDate (startOfTimeInterval, gGSystemTimeZone);
   // CFGregorianDate  nowTimeDate =  CFAbsoluteTimeGetGregorianDate (nowTimeInterval, gGSystemTimeZone);
   
   CFGregorianUnits  diff = CFAbsoluteTimeGetDifferenceAsGregorianUnits (nowTimeInterval, startOfTimeInterval, gGSystemTimeZone, kCFGregorianUnitsSeconds);
   
   totalSecs = diff.seconds;
   
   /*CFGregorianDate  gregDate;
   
   CFAbsoluteTime  absTime = CFGregorianDateGetAbsoluteTime (gregDate, NULL);*/
#endif
#ifdef kMaxMonths  
   DateTimeRec    dtRec;
   GetTime (&dtRec);
   dtRec.hour = dtRec.minute = dtRec.second = 0;
   DateToSeconds (&dtRec, &totalSecs);
   
   // return (totalSecs/(60*60*24UL) + 1UL);
#endif
   return (id_secs2Short(totalSecs));
}

unsigned long id_short2Secs (unsigned short dateShort)
{
   unsigned long  totalSecs;
   
   if (!dateShort)  {
      return (0L);
   }
   
   totalSecs = (dateShort - 1UL) * (60*60*24UL);
   
   // Better than Mac version, God knows why I did there what I did!?
   
   return (totalSecs);
}

/* .......................................................... id_date2short ......... */

unsigned short id_date2Short (
 char           *dateText,
 unsigned short *dateShort
)
{
   unsigned long  totalSecs;
   DateTimeRec    dtRec;
#ifdef _NIJE_
   short          d, m, y;
   CFTimeInterval   startOfTimeInterval = GetStartOfTime ();  // kCFAbsoluteTimeIntervalSince1904;
   DateTimeRec    dtRec;
   
   CFGregorianDate  gDate;

   if (!dateText[0])
      return (*dateShort = 0);
      
   id_SetBlockToZeros (&gDate, sizeof(CFGregorianDate));

   if (strlen(dateText) == 8)
      sscanf (dateText, "%02hd%02hd%04hd", &d, &m, &y);
   else  {
      sscanf (dateText, "%02hd%02hd%02hd", &d, &m, &y);

      if (y > kPivotDate)
         y += 1900;
      else
         y += 2000;
   }
   gDate.day = d;  gDate.month = m;  gDate.year = y;
   gDate.hour = gDate.minute = 0;  gDate.second = 0;
#endif
   if (!dateText[0])
      return (*dateShort = 0);
   
   if (strlen(dateText) == 8)
      sscanf (dateText, "%02hd%02hd%04hd", &dtRec.day, &dtRec.month, &dtRec.year);
   else  {
      sscanf (dateText, "%02hd%02hd%02hd", &dtRec.day, &dtRec.month, &dtRec.year);
      
      if (dtRec.year > kPivotDate)
         dtRec.year += 1900;
      else
         dtRec.year += 2000;
   }
   dtRec.hour = dtRec.minute = dtRec.second = 0;
   
   DateToSeconds (&dtRec, &totalSecs);
   
#ifdef _NIJE_
   CFAbsoluteTime  theTime = CFGregorianDateGetAbsoluteTime (gDate, gGSystemTimeZone);

   CFGregorianUnits  diff = CFAbsoluteTimeGetDifferenceAsGregorianUnits (theTime, startOfTimeInterval, gGSystemTimeZone, kCFGregorianUnitsSeconds);
   
   totalSecs = diff.seconds;
#endif
      
   // return (*dateShort = totalSecs/(60*60*24UL) + 1UL);
   return (*dateShort = id_secs2Short(totalSecs));
}

/* .......................................................... id_short2DateEx ....... */

char  *id_Short2DateEx (
 unsigned short   dateShort,
 char            *dateText,
 Boolean          year4Digit
)
{
   short          y2k;
   DateTimeRec    dtRec;
   
   if (!dateShort)  {
      dateText[0] = '\0';
      return (dateText);
   }
   
   SecondsToDate (id_short2Secs(dateShort), &dtRec);

   if (year4Digit)
      sprintf (dateText, "%02hd%02hd%04hd", dtRec.day, dtRec.month, dtRec.year);
   else  {
      y2k = dtRec.year-1900;
      
      if (y2k >= 100)
         sprintf (dateText, "%02hd%02hd%02hd", dtRec.day, dtRec.month, (short)(dtRec.year-2000));
      else
         sprintf (dateText, "%02hd%02hd%02hd", dtRec.day, dtRec.month, (short)(dtRec.year-1900));
   }
   
   return (dateText);
}

/* .......................................................... id_short2Date ......... */

char  *id_Short2Date (
 unsigned short   dateShort,
 char            *dateText
)
{
   return (id_Short2DateEx(dateShort, dateText, FALSE));
}

/* .......................................................... id_form_date .......... */

char  *id_form_date (
 unsigned short  dateShort,
 short           fmt
)
{
   static char    fdt1[32], fdt2[32], fdt3[32], fdt4[32];
   static short   idx = 0;
   // short          y2k;
   char           dTxt[16], *fdt;
   
   if (!dateShort)  return ("");
   
   switch (++idx)  {
      case  1:  fdt = fdt1;  break;
      case  2:  fdt = fdt2;  break;
      case  3:  fdt = fdt3;  break;
      default:
         fdt = fdt4;
         idx = 0;
         break;
   }
   
   id_Short2Date (dateShort, dTxt);
      
   switch (fmt)  {
      case  _DDMMYY:
         sprintf (fdt, "%2.2s%2.2s%2.2s", dTxt, dTxt+2, dTxt+4);  break;
      case  _DD_MM_YY:
         sprintf (fdt, "%2.2s.%2.2s.%2.2s", dTxt, dTxt+2, dTxt+4);  break;
      case  _DD_MM_YY_:
         sprintf (fdt, "%2.2s.%2.2s.%2.2s.", dTxt, dTxt+2, dTxt+4);  break;
      case  _DD_MM:
         sprintf (fdt, "%2.2s.%2.2s", dTxt, dTxt+2);  break;
      case  _DD_MM_:
         sprintf (fdt, "%2.2s.%2.2s.", dTxt, dTxt+2);  break;
      case  _MM_YY:
         sprintf (fdt, "%2.2s/%2.2s", dTxt+2, dTxt+4);  break;
      case  _MMYY:
         sprintf (fdt, "%2.2s%2.2s", dTxt+2, dTxt+4);  break;
      case  _MM:
         sprintf (fdt, "%2.2s", dTxt+2);  break;
      case  _YY:
         sprintf (fdt, "%2.2s", dTxt+4);  break;
      case  _YYYY:
         id_Short2DateEx (dateShort, dTxt, TRUE);
         // y2k = atoi (dTxt+4);
         // sprintf (fdt, "%s%2.2s", y2k > kPivotDate ? "19" : "20", dTxt+4);
         sprintf (fdt, "%4.4s", dTxt+4);
         break;
      case  _DD:
         sprintf (fdt, "%2.2s", dTxt);  break;
      case  _DD_MM_YYYY:
         id_Short2DateEx (dateShort, dTxt, TRUE);
         // y2k = atoi (dTxt+4);
         // sprintf (fdt, "%2.2s.%2.2s.%s%2.2s", dTxt, dTxt+2, y2k > kPivotDate ? "19" : "20", dTxt+4);
         sprintf (fdt, "%2.2s.%2.2s.%4.4s", dTxt, dTxt+2, dTxt+4);
         break;
      case  _DDMMYYYY:
         id_Short2DateEx (dateShort, dTxt, TRUE);
         // y2k = atoi (dTxt+4);
         // sprintf (fdt, "%2.2s%2.2s%s%2.2s", dTxt, dTxt+2, y2k > kPivotDate ? "19" : "20", dTxt+4);
         sprintf (fdt, "%2.2s%2.2s%4.4s", dTxt, dTxt+2, dTxt+4);
         break;
      case  _DD_MM_YYYY_:
         id_Short2DateEx (dateShort, dTxt, TRUE);
         // y2k = atoi (dTxt+4);
         // sprintf (fdt, "%2.2s.%2.2s.%s%2.2s.", dTxt, dTxt+2, y2k > kPivotDate ? "19" : "20", dTxt+4);
         sprintf (fdt, "%2.2s.%2.2s.%4.4s.", dTxt, dTxt+2, dTxt+4);
         break;
      case  _DDsMMsYYYY:
         id_Short2DateEx (dateShort, dTxt, TRUE);
         // y2k = atoi (dTxt+4);
         // sprintf (fdt, "%2.2s/%2.2s/%s%2.2s", dTxt, dTxt+2, y2k > kPivotDate ? "19" : "20", dTxt+4);
         sprintf (fdt, "%2.2s/%2.2s/%4.4s", dTxt, dTxt+2, dTxt+4);
         break;
      case  _YYYYMMDD:
         id_Short2DateEx (dateShort, dTxt, TRUE);
         // y2k = atoi (dTxt+4);
         sprintf (fdt, "%4.4s%2.2s%2.2s", dTxt+4, dTxt+2, dTxt);
         break;
      case  _YYYY_MM_DD:
         id_Short2DateEx (dateShort, dTxt, TRUE);
         // y2k = atoi (dTxt+4);
         // sprintf (fdt, "%s%2.2s.%2.2s.%2.2s", y2k > kPivotDate ? "19" : "20", dTxt+4, dTxt+2, dTxt);
         sprintf (fdt, "%4.4s.%2.2s.%2.2s", dTxt+4, dTxt+2, dTxt);
         break;
      case  _TEXT_DATE:
         id_text_date_fmt2 (dateShort, fdt);
         // id_secs2IUString (id_short2Secs(dateShort), 2, fdt);
         break;
      default:
         strcpy (fdt, "");
   }
   
#ifdef _DTOOL_MAC_9_
   if (gGInCodeRes)
      return (pr_Static2Stack(fdt));
#endif
  
   return (fdt);
}

/* .......................................................... id_short2DayOfWeek .... */

int  id_short2DayOfWeek (unsigned short dateShort)  // 0=mon, 1=tue, ...
{
   short          dowBySun;
   DateTimeRec    dtRec;
   
   if (!dateShort)
      return (0);
   
   SecondsToDate (id_short2Secs(dateShort), &dtRec);
   
   dowBySun = dtRec.dayOfWeek;   // 1=sun,2=mon,...
    
   if (dowBySun == 1)
      return (6);
   
   return (dowBySun - 2);
}

/* .......................................................... id_short2Year ......... */

int  id_short2Year (unsigned short dateShort)  // full year, like 2008, 2009,...
{
   short   /*day, mon,*/ yr;
   char    dTxt[16];

   sprintf (dTxt, "%s", id_form_date(dateShort, _YYYY));

   sscanf (dTxt, "%04hd", &yr);

   return (yr);
}

/* .......................................................... id_short2Month ........ */

int  id_short2Month (unsigned short dateShort)  // 1,2,...12, 0 is err
{
   short   day, mon, yr;
   char    dTxt[16];
   
   if (!dateShort)  return (0);

   id_Short2Date (dateShort, dTxt);

   sscanf (dTxt, "%02hd%02hd%02hd", &day, &mon, &yr);

   return (mon);
}

static char *monNames[12] = { "Siječanj", "Veljača", "Ožujak", "Travanj", "Svibanj", "Lipanj",
                              "Srpanj", "Kolovoz", "Rujan", "Listopad", "Studeni", "Prosinac" };
// static char *monNamesCro[3] = { "Sijecanj", "Veljaca", "Ozujak" };

static char *dayNames[7] = { "Ponedjeljak", "Utorak", "Srijeda", "Četvrtak", "Petak", "Subota", "Nedjelja" };

char  *id_get_day_name (unsigned short dateShort)
{
   char  *dayOfWeek = dayNames[id_short2DayOfWeek(dateShort)];
   
   return (dayOfWeek);
}

char  *id_get_month_name (unsigned short dateShort)
{
   short  mon = id_short2Month (dateShort);

   // see id_short2Month()

   if (mon >= 1 && mon <= 12)  {
      return (monNames[mon-1]);
   }
   
   return ("");
}

char  *id_monthName (unsigned short idxMonth)  // one based
{
   if (idxMonth >= 1 && idxMonth <= kMaxMonths)  {
      return (monNames[idxMonth-1]);
   }
   
   return ("");
}

static char  *id_text_date_fmt2 (unsigned short dateShort, char *txtBuff)
{
   // short          y2k;
   char          *dayOfWeek = dayNames[id_short2DayOfWeek(dateShort)];
   char          *monthName = id_get_month_name (dateShort);
   // DateTimeRec    dtRec;
   
   if (!dateShort)  {
      txtBuff[0] = '\0';
      return (txtBuff);
   }
   
   // SecondsToDate (id_short2Secs(dateShort), &dtRec);
   
   CFGregorianUnits  gUnits;
   
   id_SetBlockToZeros (&gUnits, sizeof(CFGregorianUnits));
   
   gUnits.days = dateShort;
   
   CFTimeInterval   startOfTimeInterval = GetStartOfTime ();  // kCFAbsoluteTimeIntervalSince1904;
   CFAbsoluteTime   theTimeInterval = CFAbsoluteTimeAddGregorianUnits (startOfTimeInterval, gGSystemTimeZone, gUnits);
   
   CFGregorianDate  gDate = CFAbsoluteTimeGetGregorianDate (theTimeInterval, gGSystemTimeZone);
   
   sprintf (txtBuff, "%.3s, %02hd. %.3s, %hd.", dayOfWeek, (short)gDate.day, monthName, (short)gDate.year);
   
   return (txtBuff);
}

#pragma mark Graphics

#if __MAC_OS_X_VERSION_MAX_ALLOWED > 1090

void  SetRect (Rect *rect, short l, short t, short r, short b)
{ 
   rect->left = l; 
   rect->top = t; 
   rect->right = r; 
   rect->bottom = b; 
} 

void  OffsetRect (Rect *rect, short h, short v)
{
   rect->left += h; 
   rect->top += v; 
   rect->right += h; 
   rect->bottom += v; 
}

void  InsetRect (Rect *rect, short h, short v)
{ 
   rect->left += h; 
   rect->top += v; 
   rect->right -= h; 
   rect->bottom -= v; 
} 

void  UnionRect (Rect *rect1, Rect *rect2, Rect *targetRect)
{
   targetRect->left = MIN (rect1->left, rect2->left);
   targetRect->top  = MIN (rect1->top, rect2->top);
   targetRect->right  = MAX (rect1->right, rect2->right);
   targetRect->bottom  = MAX (rect1->bottom, rect2->bottom);
}

void  SetPt (Point *pt, short h, short v)
{
   pt->v = v;
   pt->h = h;
}

Boolean  PtInRect (Point pt, const Rect *r)
{
   if (pt.h < r->left)  return (FALSE);
   if (pt.h >= r->right)  return (FALSE);

   if (pt.v < r->top)  return (FALSE);
   if (pt.v >= r->bottom)  return (FALSE);
   
   return (TRUE);
}

#endif

CGRect  id_Rect2CGRect (Rect *rect)
{
   return (CGRectMake(rect->left, rect->top, rect->right-rect->left, rect->bottom-rect->top));
} 

Rect  *id_CGRect2Rect (CGRect cgRect, Rect *rect)
{
   rect->left = cgRect.origin.x;
   rect->top  = cgRect.origin.y;

   rect->right   = cgRect.origin.x + cgRect.size.width;
   rect->bottom  = cgRect.origin.y + cgRect.size.height;

   return (rect);
} 

/* .......................................................... id_GetClientRect ...... */

void  id_GetClientRect (FORM_REC *form, Rect *rect)
{
   if (!form->my_window)
      return;
   
   NSRect   winFrame = form->my_window.frame;
   NSView  *winView = form->my_window.contentView;
   // Just an illustration - contentFrame but in screen coordinates:
   // NSRect   contentFrame = [form->my_window contentRectForFrameRect:[form->my_window frame]];
   
   CGRect  viewFrame = winView.bounds;  // { { 0, 0 }, { winFrame.size.width, winFrame.size.height } };

   // GetWindowRect (form->my_window, rect);  // on Mac, client is the same as window rect
   
   id_CGRect2Rect (viewFrame, rect);
   
   /*SetRect (rect,
            viewFrame.origin.x, viewFrame.origin.y,
            viewFrame.origin.x + viewFrame.size.width, viewFrame.origin.y + viewFrame.size.height);*/
   
   if (form->w_procID == documentProc)  {
      rect->top += dtGData->toolBarHeight;
      rect->bottom -= kSBAR_HEIGHT /*dtGData->statusBarHeight*/;
   }
}

CGColorRef  QD_DarkGray (void)
{
   return ([NSColor darkGrayColor].toCGColor);
}

CGColorRef  QD_LightGray (void)
{
   return ([NSColor lightGrayColor].toCGColor);
}

CGColorRef  QD_Gray (void)
{
   return ([NSColor grayColor].toCGColor);
}

CGColorRef  QD_Black (void)
{
   return ([NSColor blackColor].toCGColor);
}

CGColorRef  QD_White (void)
{
   return ([NSColor whiteColor].toCGColor);
}

static short  lastCursSet = 0;

int  id_GetCursor (void)
{
   return (lastCursSet);
}

void id_SetCursor (
 FORM_REC  *form,
 short      cursID
)
{
   if (cursID == lastCursSet)
      return;
#ifdef _NOT_YET_
   switch (cursID)  {
      case  0:
         SetCursor (QD_Arrow());
         break;
      case  iBeamCursor:
         if (!form)  {
            SetCursor (QD_Arrow());
            cursID = 0;
         }
         else  if (form->pen_flags & ID_PEN_DOWN)
            SetCursor (&editCursor);
         else
            return;
         break;
      case  watchCursor:
         SetCursor (&waitCursor);
         break;
      default:
         return;
   }
#endif   
   lastCursSet = cursID;
}

#pragma mark Fields

/* ----------------------------------------------------------- id_get_form_rect ------ */

void  id_get_form_rect (  // in local/client coordinates
 Rect       *rect,
 FORM_REC   *form,
 short       clientFlag  // used on both Mac & Win
)
{
   Rect  bounds;
   
   if (clientFlag)
      id_GetClientRect (form, rect);
   else  {
      // (*rect) = form->my_window->portRect;
      GetWindowRect ((WindowPtr)form->my_window, &bounds);
      id_WinRect2FormRect (form, &bounds, rect);
   }
}

/* ----------------------------------------------------------- id_get_fld_rect ------ */

int  id_get_fld_rect (
 FORM_REC   *form,
 short       fldno,
 Rect       *fldRect
)
{
   short  index = fldno-1;
   
   return (id_itemsRect(form, index, fldRect));
}

/* ----------------------------------------------------------- id_isHighField ------- */

Boolean  id_isHighField (
 FORM_REC   *form,
 short       fldno
)
{
   short  index = fldno-1;
   Rect   fldRect;
   
   // checks if field is multiline

   if (id_inpossible_item (form, index))  {
      return (FALSE);
   }

   fldRect = form->ditl_def[index]->i_rect;  // Need original rect!
   
   if (fldRect.bottom - fldRect.top > 20)
      return (TRUE);
     
   return (FALSE);
}

/* .......................................................... id_inpossible_item .... */

int  id_inpossible_item (/*form, index*/
 FORM_REC  *form,
 short      index
)
{
   char  tmpStr[256];
   
   // if (index == 82 - 1)
   //    con_printf ("FIELD 82!");
   
   if (!(form->my_window) || index<0 || index>form->last_fldno)  {
      // sprintf (tmpStr, "%s %hd", form->my_window ? "Field" : "Form window is NULL", index+1);  // ] Field 0
      // id_LogFileLineWithForm (form, tmpStr);
      return (-1);
   }
   return (0);
}

/* .......................................................... id_move_field ......... */

int  id_move_field (
 FORM_REC  *form,
 short      fldno,
 short      dh, 
 short      dv
)
{
   short      index = fldno-1;
   Rect       tmpRect, savedRect, ctlRect;
   WindowPtr  savedPort;
   
   if (id_inpossible_item (form, index))  return (-1);
      
   id_GetPort (form, &savedPort);
   id_SetPort (form, (WindowPtr)form->my_window);

   id_itemsRect (form, index, &savedRect);
   id_itemsRect (form, index, &tmpRect);
   
   InsetRect (&tmpRect, -3, -3);

   // EraseRect (&tmpRect);    /* Briπi staro uveÊano mjesto */
   
   id_InvalWinRect (form, &tmpRect);

   OffsetRect (&form->ditl_def[index]->i_rect, dh, dv);  // Move original!

   id_itemsRect (form, index, &tmpRect);
   
   if ((form->ditl_def[index]->i_type & ctrlItem) ||
       (form->edit_def[index]->e_type == ID_UT_SCROLL_BAR))  {
      id_adjust_button_rect (form, index, &tmpRect);
      /*dh = tmpRect.left - savedRect.left;
      dv = tmpRect.top  - savedRect.top;

      GetControlBounds ((ControlHandle)form->ditl_def[index]->i_handle, &ctlRect);
      OffsetRect (&ctlRect, dh, dv);
      SetControlBounds ((ControlHandle)form->ditl_def[index]->i_handle, &ctlRect);*/
   }   
   else  if ((form->ditl_def[index]->i_type & editText))  {
      id_adjust_edit_rect (form, index, &tmpRect);
      /*dh = tmpRect.left - savedRect.left;
      dv = tmpRect.top  - savedRect.top;

      TXNGetViewRect ((TXNObject)form->ditl_def[index]->i_handle, &ctlRect);
      OffsetRect (&ctlRect, dh, dv);
      TXNSetFrameBounds ((TXNObject)form->ditl_def[index]->i_handle,
								 ctlRect.top, ctlRect.left, ctlRect.bottom, ctlRect.right,
								 form->txnFrameID[index]);*/
   }   
   else  if ((form->ditl_def[index]->i_type & statText))  {
      id_adjust_stat_rect (form, index, &tmpRect);
   }   
   else  if ((form->ditl_def[index]->i_type & 127) == userItem)  {
      if ((form->edit_def[index]->e_type == ID_UT_POP_UP) /*&& !form->edit_def[index]->e_regular*/)  {
         
         id_adjust_popUp_rect (form, index, &tmpRect);

         // id_resetPopUpSize (form, index, &tmpRect);
      }
   }

   if (form->ditl_def[index]->i_handle)  {
      NSControl  *control = (NSControl *)form->ditl_def[index]->i_handle;
      
      [control setFrame:id_Rect2CGRect(&tmpRect)];
   }
   
   InsetRect (&tmpRect, -3, -3);
   id_InvalWinRect (form, &tmpRect);
 
   id_SetPort (form, savedPort);

   return (0);
}

Rect  *GetWindowRect (WindowPtr winPtr, Rect *rect)  // my own shit!
{
   NSWindow  *win = (NSWindow *)winPtr;
   
   NSRect  winFrame = win.frame;
   NSRect  contentFrame = [win contentRectForFrameRect:winFrame];  // Here we get content frame in bottom-left coordinates
   NSRect  carbonRect = id_CarbonRect (nil, contentFrame);         // Now they are converted to top-left coordinates
   
   // GetPortBounds (GetWindowPort(win), rect);
      
   return (id_CGRect2Rect(carbonRect, rect));                      // Finally, Rect
}

/* .......................................................... id_FormRect2WinRect ... */

void  id_FormRect2WinRectEx (FORM_REC *form, Rect *formRect, Rect *winRect, short scaleratio)
{
   // seems like:
   // - on Mac we define window with inner rect
   // - on Win we define window with outer rect

   long  rHeight, rWidth;  // must not be short
   
   BlockMove (formRect, winRect, sizeof(Rect));
   
   if (scaleratio != 100)  {
      rWidth  = RectWidth (winRect);
      rHeight = RectHeight (winRect);

      SetRect (winRect, winRect->left,
                        winRect->top,
                        winRect->left + rWidth * scaleratio / 100,
                        winRect->top + rHeight * scaleratio / 100);
   }

   if (form->w_procID == documentProc)  {// used even before form->toolBarHandle created!
      winRect->bottom += dtGData->toolBarHeight;
      winRect->bottom += dtGData->statusBarHeight;
   }
}

/* .......................................................... id_FormRect2WinRect ... */

void  id_FormRect2WinRect (FORM_REC *form, Rect *formRect, Rect *winRect)
{
   id_FormRect2WinRectEx (form, formRect, winRect, form->scaleRatio);
}

/* .......................................................... id_WinRect2FormRect ... */

void  id_WinRect2FormRectEx (FORM_REC *form, Rect *winRect, Rect *formRect, short scaleRatio)
{
   // seems like:
   // - on Mac we define window with inner rect
   // - on Win we define window with outer rect
   
   long  rHeight, rWidth;

   BlockMove (winRect, formRect, sizeof(Rect));
   
   if (form->w_procID == documentProc)  {  // used even before form->toolBarHandle created!
      formRect->bottom -= dtGData->toolBarHeight;
      formRect->bottom -= dtGData->statusBarHeight;
   }

   if (scaleRatio != 100)  {
      rWidth  = RectWidth (formRect);
      rHeight = RectHeight (formRect);

      SetRect (formRect, formRect->left,
                         formRect->top,
                         formRect->left + rWidth*100 / scaleRatio,
                         formRect->top + rHeight*100 / scaleRatio);
   }
}

/* .......................................................... id_WinRect2FormRect ... */

void  id_WinRect2FormRect (FORM_REC *form, Rect *winRect, Rect *formRect)
{
   id_WinRect2FormRectEx (form, winRect, formRect, form->scaleRatio);
}

/* .......................................................... id_MulDivRect ......... */

void  id_MulDivRect (Rect *theRect, int mul, int div)
{
   short  rHeight = RectHeight (theRect);
   short  rWidth  = RectWidth (theRect);
   
   theRect->left = MulDiv (theRect->left, mul, div);
   theRect->top  = MulDiv (theRect->top,  mul, div);

   theRect->right  = theRect->left + MulDiv (rWidth, mul, div);
   theRect->bottom = theRect->top  + MulDiv (rHeight,  mul, div);
}

/* .......................................................... id_Copy2MacRect ....... */

// form may be NULL

void  id_CopyMac2Rect (FORM_REC *form, Rect *dstRect, MacRect *srcRect)
{
   // int  leftOffset, topOffset, rightOffset, bottomOffset;

   dstRect->left   = srcRect->left;
   dstRect->top    = srcRect->top;
   dstRect->right  = srcRect->right;
   dstRect->bottom = srcRect->bottom;
   
   if (form)
      OffsetRect (dstRect, -form->hOrigin, -form->vOrigin);
   
   if (form && form->scaleRatio != 100)  {
      // id_CoreClientOffsets (form, &leftOffset, &topOffset, &rightOffset, &bottomOffset);

      // OffsetRect (dstRect, -leftOffset, -topOffset);
      id_MulDivRect (dstRect, form->scaleRatio, 100);
      // OffsetRect (dstRect, leftOffset, topOffset);
   }

   if (form && (form->w_procID == documentProc))
      OffsetRect (dstRect, 0, dtGData->toolBarHeight);
}

/* ........................................................ id_AdjustScaledRight ... */

int  id_AdjustScaledRight (FORM_REC *form, short index, Rect *fldRect)
{
   short   i, normalDistance, scaledDistance;
   Rect    testRect;
   
   // try i=index+1...

   for (i=0; i<=form->last_fldno; i++)  {
      if ((i==index) || !(form->ditl_def[i]->i_type & editText))
         continue;
      if ((form->ditl_def[i]->i_rect.top    != form->ditl_def[index]->i_rect.top) &&
          (form->ditl_def[i]->i_rect.right  != form->ditl_def[index]->i_rect.right) &&
          (form->ditl_def[i]->i_rect.bottom != form->ditl_def[index]->i_rect.bottom))
         continue;

      id_CopyMac2Rect (form, &testRect, &form->ditl_def[i]->i_rect);
      // Ak su inace skupa, a skaled nisu...
      // Rijesavamo 3, 4, 5 i 6 pixels cases
      normalDistance = form->ditl_def[i]->i_rect.left - form->ditl_def[index]->i_rect.right;
      if (normalDistance > 0)  {
         scaledDistance = testRect.left - fldRect->right;
         if (scaledDistance != normalDistance)  {
            switch (normalDistance)  {
               case  3:
               case  4:
               case  5:
               case  6:
                  return (testRect.left - normalDistance);
            }
         }
      }
      if (form->edit_def[index]->e_type & ID_UT_ARRAY)  continue;
      
      if ((index - i > 0) && (index - i < 12))  {
         if (form->ditl_def[i]->i_rect.right == form->ditl_def[index]->i_rect.right)
            return (testRect.right);
      }
   }
   return (fldRect->right);
}

int  id_AdjustScaledBottom (FORM_REC *form, short index, Rect *fldRect)
{
   short   i, normalDistance, scaledDistance;
   Rect    testRect;
   
   // try i=index+1...

   for (i=0; i<=form->last_fldno; i++)  {
      if ((i==index) || !(form->ditl_def[i]->i_type & editText))
         continue;
      if ((form->ditl_def[i]->i_rect.top    != form->ditl_def[index]->i_rect.top) &&
          (form->ditl_def[i]->i_rect.right  != form->ditl_def[index]->i_rect.right) &&
          (form->ditl_def[i]->i_rect.bottom != form->ditl_def[index]->i_rect.bottom))
         continue;

      id_CopyMac2Rect (form, &testRect, &form->ditl_def[i]->i_rect);
      // Ak su inace skupa, a skaled nisu...
      // Rijesavamo 3, 4, 5 i 6 pixels casove
      normalDistance = form->ditl_def[i]->i_rect.top - form->ditl_def[index]->i_rect.bottom;
      if (normalDistance > 0)  {
         scaledDistance = testRect.top - fldRect->bottom;
         if (scaledDistance != normalDistance)  {
            switch (normalDistance)  {
               case  3:
               case  4:
               case  5:
               case  6:
                  return (testRect.top - normalDistance);
            }
         }
      }
#ifdef _NIJE_
      if (form->edit_def[index]->e_type & ID_UT_ARRAY)  continue;
      
      if ((index - i > 0) && (index - i < 12))  {
         if (form->ditl_def[i]->i_rect.bottom == form->ditl_def[index]->i_rect.bottom)
            return (testRect.bottom);
      }
#endif
   }
   return (fldRect->bottom);
}

/* ................................................... id_AdjustScaledPictBottom ... */

int  id_AdjustScaledPictBottom (FORM_REC *form, short index, Rect *fldRect)
{
   // short   i, normalDistance, scaledDistance;
   Rect    testRect;
   
   if ((index < form->last_fldno) &&
       ((form->ditl_def[index+1]->i_type & 127) == userItem) &&
       (form->edit_def[index+1]->e_type == ID_UT_PICTURE))  {
      // Ako je nas bottom jednak sljedecem top...
      if (form->ditl_def[index]->i_rect.bottom == form->ditl_def[index+1]->i_rect.top)  {
         id_CopyMac2Rect (form, &testRect, &form->ditl_def[index+1]->i_rect);
         
         if (fldRect->bottom < testRect.top)
            return (testRect.top);
      }
   }

   return (fldRect->bottom);
}

/* ....................................................... id_itemsRect ............. */

int id_itemsRect (FORM_REC *form, short index, Rect *fldRect)
{
   short  scalePercent = 0;
   
   if (id_inpossible_item(form, index))  {
      SetRect (fldRect, 0, 0, 0, 0);
      return (-1);
   }

   // *fldRect = form->ditl_def[index]->i_rect;
   
   id_CopyMac2Rect (form, fldRect, &form->ditl_def[index]->i_rect);
   
   if (form->edit_def[index]->e_fld_edits & ID_FE_VCENTER)  {
      scalePercent = form->scaleRatio - 100;
      if (scalePercent > 0)
         OffsetRect (fldRect, -(scalePercent/10), 1+scalePercent/20);
   }

   return (0);
}

/* ....................................................... id_controlsRect .......... */

// temp function, non needed in ditl world

int id_controlsRect (FORM_REC *form, NSControl *field, Rect *fldRect)
{
   // short  scalePercent = 0;
   
   /*if (id_inpossible_item(form, index))  {
      SetRect (fldRect, 0, 0, 0, 0);
      return (-1);
   }*/
   
   id_CGRect2Rect (field.frame, fldRect);
   
   // SetRect (fldRect,
   //          field.frame.origin.x, field.frame.origin.y,
   //          field.frame.origin.x + field.frame.size.width, field.frame.origin.y + field.frame.size.height);
   
   // id_CopyMac2Rect (form, fldRect, &form->ditl_def[index]->i_rect);

#ifdef _NIJE_
   if (form->edit_def[index]->e_fld_edits & ID_FE_VCENTER)  {
      scalePercent = form->scaleRatio - 100;
      if (scalePercent > 0)
         OffsetRect (fldRect, -(scalePercent/10), 1+scalePercent/20);
   }
#endif
   
   return (0);
}

int  id_frame_fields (
 FORM_REC   *form,
 NSControl  *fldno_1,
 NSControl  *fldno_2,
 short       distance,
 CGColorRef  frPatPtr
)
{
   WindowPtr   savedPort;
   Rect        frameBounds, fldRect1, fldRect2;
         
   // if (id_inpossible_item (form, index_1) || id_inpossible_item (form, index_2))
   //    return (-1);
   
   id_controlsRect (form, fldno_1, &fldRect1);
   id_controlsRect (form, fldno_2, &fldRect2);
   
   SetRect (&frameBounds, fldRect1.left,  fldRect1.top,     /* LT */
                          fldRect2.right, fldRect2.bottom); /* RB */
   
   InsetRect (&frameBounds, -distance-1.5, -distance-1.5);

   /*PenPat (frPatPtr);
   FrameRect (&frameBounds);
   PenPat (QD_Black());*/
   
   // CGRect  frameRect = CGRectMake (frameBounds.left, frameBounds.top, frameBounds.right - frameBounds.left, frameBounds.bottom - frameBounds.top);
   CGRect  frameRect = id_Rect2CGRect (&frameBounds);
   
   CGMutablePathRef  path = CGPathCreateMutable ();
   
	CGPathAddRect (path, NULL, frameRect);
   
   CFArrayAppendValue (form->pathsArray, path);
   
   CGPathRelease (path);
   
   // PDF
   
   CFMutableDataRef  pdfData = NULL;
   // CGRect            pdfFrame = { { 0, 0 }, { form->my_window.frame.size.width, form->my_window.frame.size.height } };
   CGRect        pdfFrame = { { 0, 0 }, .size = form->my_window.frame.size };
   CGContextRef  pdfCtx = id_createPDFContext (pdfFrame, &pdfData);
   
   CGPDFContextBeginPage (pdfCtx, NULL);
   
   CGContextSetStrokeColorWithColor (pdfCtx, [NSColor redColor].toCGColor);
   
   CGContextStrokeRectWithWidth (pdfCtx, frameRect, 3.);
   
   CGPDFContextEndPage (pdfCtx);
   CGPDFContextClose (pdfCtx);
   
   // NSLog (@"CFGetRetainCount:pdfData 1: [%d]", CFGetRetainCount(pdfData));
   
   CFArrayAppendValue (form->pdfsArray, pdfData);
   
   // NSLog (@"CFGetRetainCount:pdfData 2: %d", CFGetRetainCount(pdfData));

   CFRelease (pdfData);
      
   // NSLog (@"CFGetRetainCount:pdfData 3: [%d]", CFGetRetainCount(pdfData));
   // was   DrawThemeSecondaryGroup (&frameBounds, kThemeStateActive);
   // on osx but it turned out bad!

   // SetWinPort (savedPort);
   
   return (0);
}

/* ----------------------------------------------------------- id_frame_editText ---- */

int  id_frame_editText (          /* Maybe To Change for all Fields */
 FORM_REC  *form,
 short      index
)
{
   static PicHandle  picHandle = NULL;

   Rect   tmpRect, picRect;

   DITL_item  *f_ditl_def;
   EDIT_item  *f_edit_def;
   
   f_ditl_def = form->ditl_def[index];
   f_edit_def = form->edit_def[index];
   
   if (f_edit_def->e_fld_edits & ID_FE_NO_FRAME)
      return (0);
   
   id_CopyMac2Rect (form, &tmpRect, &f_ditl_def->i_rect);
   
   if (form->scaleRatio != 100)  {
      tmpRect.right  = id_AdjustScaledRight (form, index, &tmpRect);
      tmpRect.bottom = id_AdjustScaledBottom (form, index, &tmpRect);
   }

   InsetRect (&tmpRect, -2, -2);
   OffsetRect (&tmpRect, 0, -1);

   // GetPenState (&penState);

   if (f_edit_def->e_fld_edits & ID_FE_LINE_UNDER)  {
      if (f_edit_def->e_fld_edits & ID_FE_OUTGRAY)  {
         RgnHandle  savedClipHandle;
         Rect       underRect;
         
         if (!picHandle)
            picHandle = id_GetPicture (form, 132);    /* Pict RSRC ID */

         id_GetPictRect (picHandle, &picRect);

         SetRect (&underRect, tmpRect.left-1, tmpRect.bottom+1, tmpRect.right, tmpRect.bottom+3);
         OffsetRect (&picRect, underRect.left, underRect.top);

         savedClipHandle = id_ClipRect (form, &underRect);
         id_DrawPicture (form, picHandle, &picRect);  // maybe Transparent?
         id_RestoreClip (form, savedClipHandle);
      }
      else  {
         /*
         InsetRect (&tmpRect, -2, -2);
         tmpRect.top = tmpRect.bottom - 3;
         DrawThemeSeparator (&tmpRect, kThemeStateActive);
          */
      }
      // SetPenState (&penState);
      
      return (0);
   }
   
   CGContextSaveGState (form->drawRectCtx);
   CGContextSetLineWidth (form->drawRectCtx, 1.);

   if ((f_edit_def->e_fld_edits & ID_FE_OUTGRAY) || (f_ditl_def->i_type & itemDisable))  {
      // frState = kThemeStateInactive;
      InsetRect (&tmpRect, -3, -3);
      // PenPat (QD_Gray());
      CGContextSetStrokeColorWithColor (form->drawRectCtx, [NSColor grayColor].toCGColor);
      id_FrameRect (form, &tmpRect);

      // tmpRect.right  -= 1;
      // tmpRect.bottom -= 1;
   }
   else  {
      // NSColor  *borderColor = [NSColor colorWithCalibratedRed:.3 green:.1 blue:.4 alpha:1];
      CGContextSetStrokeColorWithColor (form->drawRectCtx, [NSColor lightGrayColor].toCGColor);
      // frState = kThemeStateActive;
      // tmpRect.right  -= 1;
      // tmpRect.bottom -= 1;
      // CGContextSetShouldAntialias (form->drawRectCtx, YES);
      id_FrameEditRect (form, &tmpRect);
      // CGContextSetShouldAntialias (form->drawRectCtx, NO);  // ,... see CGPathAddArcToPoint()
      // DrawThemeEditTextFrame (&tmpRect,  kThemeStateActive);
   }
   CGContextRestoreGState (form->drawRectCtx);
  
   // SetPenState (&penState);
   
   return (0);
}

/* ----------------------------------------------------------- id_title_bounds ----- */

int  id_title_bounds (
 FORM_REC  *form,
 short      fldno_1,
 short      fldno_2,
 CGColorRef frPatPtr,
 char      *title_str,
 ID_LAYOUT *specLayout
)
{
   short       index_1 = fldno_1-1;
   short       index_2 = fldno_2-1;
   short       distance, tx_len, len;
   WindowPtr   savedPort;
   Rect        frame_bounds, tr1, tr2;
   FontInfo    fntInfo;
         
   if (id_inpossible_item (form, index_1) || id_inpossible_item (form, index_2))
      return (-1);
   
   id_GetPort (form, &savedPort);
   id_SetPort (form, (WindowPtr)form->my_window);
   
   id_itemsRect (form, index_1, &tr1);
   id_itemsRect (form, index_2, &tr2);

   UnionRect (&tr1, &tr2, &frame_bounds);

   // if (specLayout)
   //    id_SetLayout (form, specLayout);
   // else
   //    id_my_stat_layout (form, index_1);
   // GetFontInfo (&fntInfo);
   // distance = fntInfo.ascent /*+ fntInfo.descent*/;
   
   distance = [[NSFont systemFontOfSize:12] ascender];
   InsetRect (&frame_bounds, -distance, -distance);
   frame_bounds.right -= 1;
   
   // DrawThemePrimaryGroup (&frame_bounds, kThemeStateActive);
   CGContextSaveGState (form->drawRectCtx);
   CGContextSetStrokeColorWithColor (form->drawRectCtx, [NSColor grayColor].toCGColor);  // Right
   id_FrameRoundRect (form, &frame_bounds);
   // id_FrameRect (form, &frame_bounds);
   CGContextRestoreGState (form->drawRectCtx);
   
   if (title_str && (len = strlen(title_str)))  {
      tx_len = id_TextWidth (form, title_str, 0, len);
      tx_len += len / 10;
      SetRect (&tr1, frame_bounds.left + distance + 1,  frame_bounds.top - distance/2 - 1,
                     frame_bounds.left + distance+tx_len + 3, frame_bounds.top + distance/2 + 2);
      tr1.right += len;

      TExTextBox (title_str, len, &tr1, teJustLeft, TRUE, TRUE);  // wrap, erase back
   }
   
   id_SetPort (form, savedPort);
   
   return (0);
}

/* ----------------------------------------------------------- id_same_edit_type ----- */

void  id_same_edit_type (
 FORM_REC  *form,
 short      fld1,
 short      fld2
)
{
   if (form->my_window)          /* Window opened already */
      if ((fld1-1 <= form->last_fldno) && (fld2-1 <= form->last_fldno))  {
      
         if (fld1 != fld2)  {
            short  index = fld2 - 1;
            short  oldJustify = form->edit_def[index]->e_justify;

            form->edit_def[index] = form->edit_def[fld1-1];
#ifdef _DTOOL_OSX_            
            if (form->ditl_def[index]->i_handle)  {   // Control already created!
               if (oldJustify != form->edit_def[index]->e_justify)
                  TExSetAlignment (form->ditl_def[index]->i_handle, form->edit_def[index]->e_justify);
            }
#endif
         }
      }
}

/* .................................................. id_set_field_buffer_text ....... */

void  id_set_field_buffer_text (
 FORM_REC  *form,
 short      fldno,
 char      *text,
 short      txtLen
)
{
   short  index = fldno - 1;

   if (form->edit_def[index]->e_longText)  {
      NOT_YET // id_DisposePtr (form->edit_def[index]->e_longText);
      DisposePtr (form->edit_def[index]->e_longText);
      form->edit_def[index]->e_longText = NULL;
   }

   if (txtLen <= 240)  {
      form->ditl_def[index]->i_data_size = txtLen;
      BlockMove (text, form->ditl_def[index]->i_data.d_text, txtLen);
   }
   else  {
      NOT_YET // form->edit_def[index]->e_longText = id_malloc_or_exit (txtLen+1);
      form->edit_def[index]->e_longText = NewPtr (txtLen+1);
      
      BlockMove (text, form->edit_def[index]->e_longText, txtLen);
      form->edit_def[index]->e_longText[txtLen] = '\0';
      form->ditl_def[index]->i_data_size = 255;
   }
}

/* ..................................................... id_field_text_buffer ....... */

char  *id_field_text_buffer (
 FORM_REC  *form,
 short      fldno
)
{
   short  index = fldno - 1;

   return (form->edit_def[index]->e_longText ? form->edit_def[index]->e_longText : form->ditl_def[index]->i_data.d_text);
}

/* ........................................................ id_field_text_length .... */

int  id_field_text_length (
 FORM_REC  *form,
 short      fldno
)
{
   short  index = fldno - 1;
   
   if (id_inpossible_item(form, index))  return (0);
   
   if (form->edit_def[index]->e_longText)
      return ((int)strlen(form->edit_def[index]->e_longText));
   
   return (form->ditl_def[index]->i_data_size);
}

/* ........................................................ id_field_empty .......... */

Boolean  id_field_empty (
 FORM_REC *form,
 short     fldno
)
{
   short  index = fldno - 1;

   if ((form->ditl_def[index]->i_type & editText) && (index==form->cur_fldno))
      id_get_TE_str (form, index);
   
   return (id_field_text_length(form, fldno) ? FALSE : TRUE);
}

/* .......................................................... id_set_field_layout .... */

int  id_set_field_layout (  // there is pr_SetFldEdits()
 FORM_REC  *form,
 short      fldno,
 ID_LAYOUT *theLayout
)
{
   extern  EDIT_item  default_edit_item;
   
   // EDIT_item *f_edit_def;
   
   short      index = fldno - 1;
   
   if (id_inpossible_item (form, index))  return (-1);
   
   // f_edit_def = form->edit_def[index];

   if (form->edit_def[index] == &default_edit_item)  return (-1);
   
   form->edit_def[index]->e_fld_layout = theLayout;
   
   return (0);
}

/* .......................................................... id_disable_field ...... */

int  id_disable_field (
 FORM_REC  *form,
 short      fldno
)
{
   short          index = fldno-1;
   NSControl     *theCtrl;
   Rect           tmpRect;
   DITL_item     *fDitl_def;
   EDIT_item     *fEdit_def;
   
   if (id_inpossible_item (form, index))
      return (-1);
      
   fDitl_def = form->ditl_def[index];
   fEdit_def = form->edit_def[index];
   
   if (fDitl_def->i_type & itemDisable)
      return (fDitl_def->i_type);
   else
      fDitl_def->i_type |= itemDisable;
   
   theCtrl = (NSControl *)fDitl_def->i_handle;
   
   if (theCtrl)
      [theCtrl setEnabled:NO];
   
   return (fDitl_def->i_type);
}

/* .......................................................... id_enable_field ....... */

int  id_enable_field (
 FORM_REC  *form,
 short      fldno
)
{
   short          index = fldno-1;
   NSControl     *theCtrl;
   Rect           tmpRect;
   DITL_item     *fDitl_def;
   EDIT_item     *fEdit_def;
   
   if (id_inpossible_item (form, index))  return (-1);
      
   fDitl_def = form->ditl_def[index];
   fEdit_def = form->edit_def[index];

   if (fDitl_def->i_type & itemDisable)
      fDitl_def->i_type &= (~itemDisable);
   else
      return (fDitl_def->i_type);
 
   theCtrl = (NSControl *)fDitl_def->i_handle;
   
   if (theCtrl)
      [theCtrl setEnabled:YES];
   
   return (fDitl_def->i_type);
}

/* .......................................................... id_field_enabled ...... */

Boolean  id_field_enabled (
 FORM_REC  *form,
 short      fldno
)
{
   short  index = fldno-1;
   
   if (id_inpossible_item (form, index))  return (FALSE);
      
   if (form->ditl_def[index]->i_type & itemDisable)
      return (FALSE);
   else
      return (TRUE);
}

/* .......................................................... id_redraw_field ....... */

void  id_redraw_field (
 FORM_REC  *form,
 short      fldno
)
{
   short       index = fldno-1;
   Rect        tmpRect;
   DITL_item  *fDitl_def;
   EDIT_item  *fEdit_def;
   
   if (id_inpossible_item (form, index))  return;
      
   fDitl_def = form->ditl_def[index];
   fEdit_def = form->edit_def[index];

   // tmpRect = fDitl_def->i_rect;
   id_itemsRect (form, index, &tmpRect);
   
   _id_redraw_field (form, &tmpRect, fDitl_def, fEdit_def);
}

/* .......................................................... _id_redraw_field ...... */

void _id_redraw_field (
 FORM_REC  *form,
 Rect      *fldRect,
 DITL_item *fDitl_def,
 EDIT_item *fEdit_def
)
{
   NSControl  *theCtl = (NSControl *)fDitl_def->i_handle;

   if (theCtl)
      [theCtl setNeedsDisplay:YES];
}

/* .......................................................... id_base_fldno ......... */

// GET

int  id_base_fldno (
 FORM_REC  *form,
 short      fldno,
 short     *offset
)
{
   short  i, index = fldno-1;
   short  retFldno = fldno;
   short  testBottom = 0;
   Rect   fldRect;
   
   if (offset)
      *offset = 0;
   
   if (id_inpossible_item (form, index) || !(form->edit_def[index]->e_type & ID_UT_ARRAY))
      return (retFldno);

   fldRect = form->ditl_def[index]->i_rect;                        // Must be naked rect!
   
   testBottom = fldRect.bottom;  // Only fields above this

   for (i=index-1; i>0; i--)  {
      if (form->ditl_def[i]->i_rect.bottom > testBottom)
         break;
      if ((form->ditl_def[i]->i_type == editText) && (form->edit_def[i]->e_type & ID_UT_ARRAY))  {
         if ((form->ditl_def[i]->i_rect.left == fldRect.left) && (form->ditl_def[i]->i_rect.right == fldRect.right))  {
            retFldno = i + 1;
            testBottom = form->ditl_def[i]->i_rect.bottom;
         }
         else
            break;
      }
   }

   if (offset)
      *offset = fldno - retFldno;
      
   return (retFldno);
}

/* --------------------------------------------------- entry & exit calls ---------- */

#pragma mark -

/* --------------------------------------------------- id_check_entry -------------- */

int  id_check_entry (
 FORM_REC  *form,
 short      index,
 WindowPtr  savedPort
)
{
   EDIT_item  *f_edit_def;
   short       retVal = 0;
   
   if (f_edit_def=form->edit_def[index])  {
      if (form->ditl_def[index]->i_type & editText)  {
         id_show_comment (form, index, TRUE);
         if (id_field_empty(form, index+1))  {       // 28/04/04
            NOT_YET // if (f_edit_def->e_fld_edits & ID_FE_SYS_DATE)   /* SysDate */
               NOT_YET // id_put_editText (form, index, id_form_date(id_sys_date (), _DD_MM_YY));
            NOT_YET // if (f_edit_def->e_fld_edits & ID_FE_SYS_TIME)   /* SysTime */
               NOT_YET // id_put_editText (form, index, id_form_time(id_sys_time (), _HH_MI_SS));
         }
      }
      if (f_edit_def->e_entry_func)  {
         id_SetPort (form, savedPort);
         retVal = (*f_edit_def->e_entry_func)(form, index+1, f_edit_def->e_occur, ID_ENTRY_FLAG);
         id_SetPort (form, (WindowPtr)form->my_window);
      }
      if (form->ditl_def[index]->i_type & editText)  {
         id_set_pen (form, ID_PEN_FLDIRT, FALSE);
         NOT_YET // id_UDSet (form, index+1);
         NOT_YET // id_CheckCommandsMenu (form, index, TRUE);
      }
   }
   return (retVal);
}

/* --------------------------------------------------- id_check_exit --------------- */

int  id_check_exit (
 FORM_REC  *form,
 short      index,
 WindowPtr  savedPort
)
{
   EDIT_item  *f_edit_def;
   short       retVal;
   char        dChar;
   
   if (f_edit_def=form->edit_def[index])  {
      if (form->ditl_def[index]->i_type & editText)  {
         id_show_comment (form, index, FALSE);
         if (f_edit_def->e_fld_edits & ID_FE_DATE)  {
            dChar = *form->ditl_def[index]->i_data.d_text;
            if (!strchr("+DdJjGgSsPpMmZz", dChar))  {
               char  tmpDate[16];
               
               id_SetPort (form, savedPort);
               NOT_YET // id_getfield (form, index+1, tmpDate, 10);
               NOT_YET // if (!id_checkDateIntegrity (tmpDate, TRUE))
                  NOT_YET // id_putdate (form, index+1, 
                       NOT_YET // id_CheckDateFrame (id_getdate(form, index+1),
                       NOT_YET // f_edit_def->e_fld_edits & ID_FE_DATECHK));
               id_SetPort (form, (WindowPtr)form->my_window);
            }
            NOT_YET // else  if (dChar != '+')  {    // Slovni datumi
               NOT_YET // id_SetPort (form, savedPort);
               NOT_YET // id_putdate (form, index+1, id_GetMacroDate(dChar));
               NOT_YET // id_SetPort (form, form->my_window);
            NOT_YET // }
         }
         NOT_YET // if ((f_edit_def->e_fld_edits & ID_FE_SYS_DATE) && id_field_empty(form, index+1)) /* SysDate */
            NOT_YET // id_put_editText (form, index, id_form_date(id_sys_date (), _DD_MM_YY));
      }
      if (f_edit_def->e_exit_func || dtGData->fDblExitCheckProc)  {
         id_SetPort (form, savedPort);
         if (f_edit_def->e_exit_func && (f_edit_def->e_fld_edits & ID_FE_EXTRA_LEN))
            retVal = (*f_edit_def->e_exit_func)(form, index+1, f_edit_def->e_occur, ID_EXTRA_FLAG);
         else
            retVal = 0;
         if (!retVal)  {
            if (form->exit_check_func)
               retVal = (*form->exit_check_func)(form, index+1);
            else  if (dtGData->fDblExitCheckProc)
               retVal = (*dtGData->fDblExitCheckProc)(form, index+1);
         }
         
         if (!retVal && f_edit_def->e_exit_func)
            retVal = (*f_edit_def->e_exit_func)(form, index+1, f_edit_def->e_occur, ID_EXIT_FLAG);
         id_SetPort (form, (WindowPtr)form->my_window);
         NOT_YET // if (!retVal && form->ditl_def[index]->i_type & editText)
            NOT_YET // id_CheckCommandsMenu (form, index, FALSE);
         return (retVal);
      }
      NOT_YET // else  if (form->ditl_def[index]->i_type & editText)
         NOT_YET // id_CheckCommandsMenu (form, index, FALSE);
   }
   
   return (0);
}

#pragma mark PDF

CGContextRef  id_createPDFContext (CGRect pdfFrame, CFMutableDataRef *pdfData)
{
   CGContextRef  pdfCtx = 0;
   
   *pdfData = CFDataCreateMutable (NULL, 0);
   CGDataConsumerRef  consumer = CGDataConsumerCreateWithCFData (*pdfData);
   
   pdfCtx = CGPDFContextCreate (consumer, &pdfFrame, NULL);
   
   CGDataConsumerRelease (consumer);
   // CFRelease (*pdfData);
   
   CGColorRef  blackCGColor = [NSColor blackColor].toCGColor;
   
   CGContextSetFillColorWithColor (pdfCtx, blackCGColor);
   CGContextSetStrokeColorWithColor (pdfCtx, blackCGColor);
   
   // Make it flipped
   
   CGAffineTransform  translateTransform = CGAffineTransformMakeTranslation (0, -pdfFrame.size.height);
   CGAffineTransform  scaleTransform = CGAffineTransformMakeScale (1, -1);
   
   CGContextConcatCTM (pdfCtx, CGAffineTransformConcat (translateTransform, scaleTransform));
   
   // Later:
   // CGPDFContextBeginPage()
   // CGPDFContextEndPage()
   // CGPDFContextClose()
   
   // CGDataProviderRef provider = CGDataProviderCreateWithCFData ((__bridge CFDataRef)inputData); 
   
   // CGPDFDocumentRef  pdfDocument = CGPDFDocumentCreateWithProvider (CGDataProviderRef cg_nullable provider)
   // CGDataProviderRelease (CGDataProviderRef provider);  // almost same as CFRelease(currentPage);
   // CGPDFPageRef currentPage = CGPDFDocumentGetPage (pdfDocument, pageCtr);
   // CGRect mediaBox = CGPDFPageGetBoxRect(currentPage, kCGPDFMediaBox);
   // CGContextSaveGState(cgContext);
   // Calculate the transform to position the page
   // float suggestedHeight = viewBounds.size.height * 2.0 / 3.0;
   // CGRect suggestedPageRect = CGRectMake (0, 0,
   //                                        suggestedHeight * (mediaBox.size.width / mediaBox.size.height), 
   //                                        suggestedHeight);
   // CGAffineTransform pageTransform = CGPDFPageGetDrawingTransform (currentPage, kCGPDFMediaBox, suggestedPageRect, 0, true);
   // CGContextConcatCTM (cgContext, pageTransform);
   // CGContextDrawPDFPage (cgContext, currentPage);
   // CGContextRestoreGState (cgContext);
   
   // CFRelease (currentPage);
   // CGPDFDocumentRelease (pdfDocument);

   
   return (pdfCtx);
}


#pragma mark Icons

static NSImage  *gGStatusBarBackground = NULL;     // was CIconHandle
static NSImage  *gGStatusBarSeparator = NULL;     // was CIconHandle

NSImage  *id_GetCIcon (short rsrc_id)
{
   NSString  *iconName = [NSString stringWithFormat:@"CICN%04hd", rsrc_id];
   
   NSImage  *iconImage = [NSImage imageNamed:iconName];
   
   return (iconImage);
}

void  id_PlotCIcon (Rect *macRect, NSImage *iconImage)
{
   // CGRect  icnRect = CGRectMake (macRect->left, macRect->top, macRect->right - macRect->left, macRect->bottom - macRect->top);
   CGRect  icnRect = id_Rect2CGRect (macRect);
   
   [MainLoop drawImage:iconImage inFrame:icnRect form:NULL];
}

NSImage  *id_GetIcon (short rsrc_id)
{
   NSString  *iconName = [NSString stringWithFormat:@"ICON%04hd", rsrc_id];
   
   NSImage  *iconImage = [NSImage imageNamed:iconName];
   
   return (iconImage);
}

void  id_PlotIcon (Rect *macRect, NSImage *iconImage)
{
   id_PlotCIcon (macRect, iconImage);
}

/* ----------------------------------------------------- id_GetPictRect -------------- */

int id_GetPictRect (PicHandle picHandle, Rect *picRect)
{
   NSImage  *theImage = (NSImage *)picHandle;
   CGRect    imgRect = { { 0, 0 }, .size = theImage.size };
   
   id_CGRect2Rect (imgRect, picRect);
   
   return (0);
}

/* ----------------------------------------------------- id_GetPicture --------------- */

PicHandle  id_GetPicture (FORM_REC *form, short picID)
{
   NSString  *imgName = [NSString stringWithFormat:@"PICT%04hd", picID];
   NSImage   *theImage = [NSImage imageNamed:imgName];
   
   return ((PicHandle)[theImage retain]);
}

/* ----------------------------------------------------- id_DrawPicture -------------- */

int id_DrawPicture (FORM_REC *form, PicHandle picHandle, Rect *picRect)
{
   CGRect  imgRect = id_Rect2CGRect (picRect);
   
   if (form->drawRectCtx || [form->overlayView canDraw])  {
      
      if (!form->drawRectCtx)
         [form->overlayView lockFocus];
      
      NSImage   *theImage = (NSImage *)picHandle;
      
      [MainLoop drawImage:theImage inFrame:imgRect form:NULL];
      
      if (!form->drawRectCtx)
         [form->overlayView unlockFocus];
   }
   
   return (0);
}

/* ................................................... id_ReleasePicture ........... */

void  id_ReleasePicture (PicHandle picHandle)
{
   NSImage  *theImage = (NSImage *)picHandle;
   
   [theImage release];
}

/* ................................................... id_draw_Picture ............. */

void  id_draw_Picture (FORM_REC *form, short index)
{
   short     scalingError = 0;
   Rect      tmpRect;
   NSImage  *iconImage;
   
   DITL_item  *f_ditl_def;
   EDIT_item  *f_edit_def;
   
   f_ditl_def = form->ditl_def[index];
   f_edit_def = form->edit_def[index];

   if (form->scaleRatio != 100)  {
      id_CopyMac2Rect (form, &tmpRect, &f_ditl_def->i_rect);
      scalingError = tmpRect.bottom;
      tmpRect.bottom = id_AdjustScaledPictBottom (form, index, &tmpRect);

      scalingError = tmpRect.bottom - scalingError;
   }

   if (id_itemsRect (form, index, &tmpRect))
      return;

   tmpRect.bottom += scalingError;

   CGRect  imgRect = id_Rect2CGRect (&tmpRect);
   
   if (form->drawRectCtx || [form->overlayView canDraw])  {
      
      if (!form->drawRectCtx)
         [form->overlayView lockFocus];

      PicHandle  theImage = id_GetPicture (form, form->edit_def[index]->e_elems);

      [MainLoop drawImage:(NSImage *)theImage inFrame:imgRect form:NULL];
      
      id_ReleasePicture (theImage);

      if (!form->drawRectCtx)
         [form->overlayView unlockFocus];
   }
}

/* ................................................... id_create_iconItem .......... */

void  id_create_iconItem (FORM_REC *form, short index, WindowPtr savedPort)
{
   Rect    tmpRect;
   // CGRect  cgRect;

   DITL_item  *f_ditl_def;
   EDIT_item  *f_edit_def;

   NiblessTestAppDelegate  *appDelegate = (NiblessTestAppDelegate *)[NSApp delegate];

   f_ditl_def = form->ditl_def[index];
   f_edit_def = form->edit_def[index];

   id_CopyMac2Rect (form, &tmpRect, &form->ditl_def[index]->i_rect);

   NSButton  *myButton = [appDelegate.firstFormHandler coreCreateButtonWithFrame:id_Rect2CGRect(&tmpRect)
                                                  inForm:form
                                                   title:nil];
   
   f_ditl_def->i_handle = (Handle) myButton;

   [myButton setButtonType:NSMomentaryLightButton]; //Set what type button You want
   // [myButton setBezelStyle:NSRegularSquareBezelStyle]; //Set what style You want
   
   [myButton setBordered:NO];

   // Load images from the app's resources
   NSImage  *image = id_GetIcon (form->edit_def[index]->e_precision);  // e_precision is active icon
   
   // Set images for the buttons
   [myButton setImage:image];
   
   [myButton setTarget:appDelegate.firstFormHandler];
#if defined(__clang__)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#endif
   [myButton setAction:@selector(buttonInDitlPressed:)];
#if defined(__clang__)
#pragma clang diagnostic pop
#endif
}

void  id_resetPopUpMenu (
 FORM_REC  *form,
 short      index
)
{
   short  i;

   NSPopUpButton   *popUp = nil;
   CFStringRef      cfString = NULL;
   OSStatus         status;

   DITL_item  *f_ditl_def;
   EDIT_item  *f_edit_def;

   f_ditl_def = form->ditl_def[index];
   f_edit_def = form->edit_def[index];

   popUp = (NSPopUpButton *)f_ditl_def->i_handle;
   
   [popUp removeAllItems];
   
   for (i=0; i<f_edit_def->e_elems; i++)  {
      id_Mac2CFString (f_edit_def->e_array[i], &cfString, strlen(f_edit_def->e_array[i]));
      
      [popUp addItemWithTitle:(NSString *)cfString];  // insertItemWithTitle:(NSString *)title atIndex:(NSInteger)index;
      // [popUp addItemWithTitle:@"Pero"];  // insertItemWithTitle:(NSString *)title atIndex:(NSInteger)index;

      CFRelease (cfString);
   }
}

/* ----------------------------------------------------- id_ClipRect ----------------- */

RgnHandle  id_ClipRect (FORM_REC *form, Rect *clipRect)
{
   if (!form->drawRectCtx)  {
      id_SysBeep (10);
      return (NULL);
   }
   
   CGRect  rClip = CGRectInset(id_Rect2CGRect(clipRect), -1, -1);
   
   CGContextSaveGState (form->drawRectCtx);
   
   CGContextClipToRect (form->drawRectCtx, rClip);
   
   return ((RgnHandle)0xFFFFFFFF);
}

/* ----------------------------------------------------- id_RestoreClip -------------- */

int id_RestoreClip (FORM_REC *form, RgnHandle savedClipRgn)
{
   if (!form->drawRectCtx)  {
      id_SysBeep (10);
      return (-1);
   }
   
   if (savedClipRgn != (RgnHandle)0xFFFFFFFF)
      return (-1);
   
   CGContextRestoreGState (form->drawRectCtx);
   
   return (0);
}

#pragma mark -

static int  id_InitStatusbarIcons (void)
{
   if (!gGStatusBarBackground)
      gGStatusBarBackground = id_GetCIcon (kSBAR_BACKGROUND);
   
   if (!gGStatusBarSeparator)
      gGStatusBarSeparator = id_GetCIcon (kSBAR_SEPARATOR);
   
   return (0);
}

/* ....................................................... id_DrawStatusBar ......... */

int  id_DrawStatusbar (
 FORM_REC  *form,
 short      drawNow  // if FALSE, just invalidate
)
{
   // IDStatusbarHandle  sbHandle = (IDStatusbarHandle) form->statusBarHandle;
   short              i, iconWidth, iconPosHor;  //, idx = 0;
   Rect               tmpRect, clientRect;
   
   // if (!sbHandle)
   //    return (-1);
   
   iconWidth = kSBAR_ICN_WIDTH;
   iconPosHor = 0;
      
   id_GetClientRect (form, &clientRect);
   
   if (!drawNow)  {
      SetRect (&tmpRect, 0, clientRect.bottom,
                         clientRect.right, clientRect.bottom+kSBAR_HEIGHT);
      // InvalWinRect (form->my_window, &tmpRect);
      [form->my_window.contentView setNeedsDisplay:YES];

      return (0);
   }
      
   // NSLog (@"ClientRect: %@", NSStringFromRect(id_Rect2CGRect(&clientRect)));
   
   while (iconPosHor < clientRect.right)  {
   
      SetRect (&tmpRect, iconPosHor, clientRect.bottom,
                         iconPosHor + iconWidth, clientRect.bottom+kSBAR_HEIGHT);   // ltrb
   
      if (gGStatusBarBackground)
         id_PlotCIcon (&tmpRect, gGStatusBarBackground);
      iconPosHor += iconWidth;
   }
   
   iconPosHor = clientRect.right - 210;
   
   tmpRect.left  = iconPosHor;
   tmpRect.right = iconPosHor + kSBAR_SEP_WIDTH;

   for (i=1; i < 4/*(*sbHandle)->sbItems*/; i++)  {
      if (gGStatusBarSeparator)
         id_PlotCIcon (&tmpRect, gGStatusBarSeparator);
      OffsetRect (&tmpRect, 60, 0);
   }

   // HLock (form->statusBarHandle);
   
   id_DrawStatusbarText (form, 0, "Sve OK");
   id_DrawStatusbarText (form, 1, "1");
   id_DrawStatusbarText (form, 2, "2");
   id_DrawStatusbarText (form, 3, "345");

   // HUnlock (form->statusBarHandle);
   
   return (0);
}

/* ....................................................... id_DrawStatusbarText ..... */

static int  id_DrawStatusbarText (
 FORM_REC *form,
 short     statPart,
 char     *statusText
)
{
   Rect               tmpRect, clientRect;
   
   // if (!form->statusBarHandle)
   //    return (-1);
      
   if (!statusText[0])
      return (0);

   id_GetClientRect (form, &clientRect);
   SetRect (&tmpRect, 0, clientRect.bottom, 0, clientRect.bottom + kSBAR_HEIGHT);   // ltrb
      
   tmpRect.top  += 2;
   
   switch (statPart)  {
      case  0:  // Primary
         tmpRect.left  = 2+2;
         tmpRect.right = clientRect.right - 210;
         break;
      case  1:  // Char Cnt
         tmpRect.left  = clientRect.right - 210 + (kSBAR_SEP_WIDTH/2+1) + 2;
         tmpRect.right = clientRect.right - 150;
         break;
      case  2:  // Secondary
         tmpRect.left  = clientRect.right - 150 + (kSBAR_SEP_WIDTH/2+1) + 2;
         tmpRect.right = clientRect.right - 90;
         break;
      default:  // Ternary
         tmpRect.left  = clientRect.right - 90 + (kSBAR_SEP_WIDTH/2+1) + 2;
         tmpRect.right = clientRect.right - 16;
         break;
   }
   
   // id_set_comment_layout ();
   
   if (form->drawRectCtx || [form->overlayView canDraw])  {
      
      if (!form->drawRectCtx)
         [form->overlayView lockFocus];
      
      // CGContextRef  ctx = [NSGraphicsContext currentContext].graphicsPort;
      
      // CGContextSaveGState (ctx);
      
      NSColor  *theColor = [NSColor blueColor];
      CGFloat   red, green, blue, alpha;
      
      if (statPart)  {
         theColor = [NSColor cyanColor];
         [theColor getRed:&red green:&green blue:&blue alpha:&alpha]; 
         green = 2 * green / 3;
         theColor = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
      }
      
      
      // if (!statPart)
      //    ForeColor ((form->formFlags & ID_F_ERROR_STATE) ? redColor : blueColor);
      // else
      //    CGContextSetStrokeColorWithColor (ctx, [NSColor cyanColor].toCGColor);
      
      CFStringRef  cfStr;
      CGRect       strRect = id_Rect2CGRect (&tmpRect);
      
      id_Mac2CFString (statusText, &cfStr, strlen(statusText));
      
      
      NSMutableParagraphStyle  *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
      textStyle.lineBreakMode = NSLineBreakByWordWrapping;
      textStyle.alignment = NSLeftTextAlignment;  // NSTextAlignmentLeft;
      NSFont   *textFont = [NSFont messageFontOfSize:10];
      
      NSMutableDictionary  *attrs = [NSMutableDictionary dictionaryWithCapacity:3];
      
      [attrs setObject:textStyle forKey:NSParagraphStyleAttributeName];
      [attrs setObject:textFont forKey:NSFontAttributeName];
      [attrs setObject:theColor forKey:NSForegroundColorAttributeName];
      
      
      [(NSString *)cfStr drawInRect:strRect withAttributes:attrs];
      
      [textStyle release];
      
      CFRelease (cfStr);
      
      // TExTransTextBox (statText, strlen (statText), &tmpRect, teJustLeft, TRUE);  // wrap
      
      // ForeColor (blackColor);
      // CGContextRestoreGState (ctx);
      
      if (!form->drawRectCtx)
         [form->overlayView unlockFocus];
   }
   
   return (0);
}

/* ....................................................... id_RedrawStatusBar ....... */

void  id_RedrawStatusbar (FORM_REC *form)
{
   WindowPtr  savedPort;

   id_GetPort (form, &savedPort);
   id_SetPort (form, (WindowPtr)form->my_window);

   if ((form->pen_flags & ID_PEN_DOWN) && (form->cur_fldno >= 0))
      id_show_comment (form,  form->cur_fldno, TRUE);
   else
      id_show_comment (form, -1, 0);

   id_SetPort (form, savedPort);
}

/* ....................................................... id_SetStatusbarText ...... */

int  id_SetStatusbarText (
 FORM_REC *form,
 short     statPart,
 char     *statText
)
{
   IDStatusbarHandle  sbHandle = (IDStatusbarHandle) form->statusBarHandle;
   
   if (!sbHandle)
      return (-1);
      
   HLock (form->statusBarHandle);
   
   switch (statPart)  {
      case  0:
         // con_printf ("%s\n", statText);
         strNCpy ((*sbHandle)->sbPrimaryMsg, statText, 240);
         break;
      case  1:
         strNCpy ((*sbHandle)->sbCharCountMsg, statText, 15);
         break;
      case  2:
         strNCpy ((*sbHandle)->sbSecondaryMsg, statText, 240);
         break;
      default:
         strNCpy ((*sbHandle)->sbTernaryMsg, statText, 240);
         break;
   }
   HUnlock (form->statusBarHandle);
   
   return (id_DrawStatusbar (form, FALSE));  // drawNow
}

/* ----------------------------------------------------------- id_show_comment ------- */

// We don't have the FB struct defined so none of this would work

int  id_show_comment (
 FORM_REC    *form,
 short        index,
 short        mode
)
{
#ifdef _NOT_YET_
   EDIT_item  *f_edit_def;
   FBPtr       theFB = id_FBFindByForm (form);
   short       dfltFlag = TRUE;
   short       statusBarFlag = FALSE;
   char        tmpStr[256];
   WindowPtr   savedPort;
   
   if (theFB || form->status_fldno < 0)
      statusBarFlag = TRUE;
   
   if (index >= 0 && index<=form->last_fldno)  {
      if (f_edit_def=form->edit_def[index])  {
         if (f_edit_def->e_status_line)  {
            if (mode && (form->pen_flags & ID_PEN_DOWN))  {

               if (!statusBarFlag)  {
                  GetWinPort (&savedPort);
                  SetWinPort (form->my_window);
                  ForeColor (blueColor);
                  // SetWinPort (savedPort);
                  id_putfield (form, form->status_fldno+1, f_edit_def->e_status_line);
                  // GetWinPort (&savedPort);
                  // SetWinPort (form->my_window);
                  ForeColor (blackColor);
                  SetWinPort (savedPort);
               }
               else  {
                  if (theFB && theFB->fbExtraComment[0])  {
                     char  statusText[256];
                     
                     sprintf (statusText, "%s ... %s", f_edit_def->e_status_line, theFB->fbExtraComment);
                     id_SetStatusbarText (form, 0, statusText);  // See id_DrawStatusbar()
                  }
                  else
                     id_SetStatusbarText (form, 0, f_edit_def->e_status_line);
               }
               dfltFlag = FALSE;
            }
            else  if (!statusBarFlag && (form->pen_flags & ID_PEN_DOWN))
               id_putfield (form, form->status_fldno+1, "");
         }
      }
   }
   
   if (dfltFlag)  {
      char  statusText[256], *txtStatusOK = "Status: OK";
      
      if (form->formFlags & ID_F_ERROR_STATE)
         sprintf (statusText, "Status: PROBLEM");
      else  if (form->formFlags & ID_F_STATUS_MARK)
         sprintf (statusText, "(•) %s", txtStatusOK);
      else  if (theFB && theFB->fbExtraComment[0])
         sprintf (statusText, " %s", theFB->fbExtraComment);
      else
         sprintf (statusText, "%s", txtStatusOK);
      
      id_SetStatusbarText (form, 0, statusText);
   }
   
   if (theFB && theFB->fbSFHandle)  {
      short  first, last;
      
      first = id_FBFirstEmptyLine(theFB, FALSE);
      last  = id_FBLastEmptyLine(theFB, FALSE);
      
      if (!first && !last)
         sprintf (tmpStr, "%s", "");
      else  if (first != last)
         sprintf (tmpStr, "%hd [%hd]", first, last);
      else
         sprintf (tmpStr, "%hd", first);
                  
      id_SetStatusbarText (form, 2, tmpStr);
   }
   else
      id_SetStatusbarText (form, 2, "");

   if (theFB && theFB->fbShortComment[0])  {
      id_SetStatusbarText (form, 3, theFB->fbShortComment);
   }
   else
      id_SetStatusbarText (form, 3, "");
#endif  // _NOT_YET_
   return (0);
}

#pragma mark -

/* ....................................................... id_CreateIconToolbar ..... */

int  id_CreateIconToolbar (FORM_REC *form)
{
   IDToolbarHandle  tbHandle = NULL;

   form->toolBarHandle = NewHandle (sizeof(IDToolbarRecord));
   
   if (tbHandle = (IDToolbarHandle) form->toolBarHandle)  {
            
      HLock (form->toolBarHandle);
      id_SetBlockToZeros (*form->toolBarHandle, sizeof(IDToolbarRecord));
      
      (*tbHandle)->tbDisabled = FALSE;  // just to make sure!

      (*tbHandle)->hciPadding = id_GetCIcon (STD_EMPTY);
      HUnlock (form->toolBarHandle);
   }
   else
      return (-1);

   return (0);
}

/* ....................................................... id_SetTBItem ............. */

int  id_SetTBItem (
 FORM_REC *form,
 short     idx,
 short     iconId,  // 0 or STD_FILENEW etc...
 short     theMenu,
 short     theItem
)
{
   IDToolbarHandle  tbHandle = (IDToolbarHandle) form->toolBarHandle;
   short            useIconId;  // if icon id is 0, use STD_EMPTY
   short            higIconId, disIconId;
   short            iconWidth = kTB_ICN_WIDTH;
   
   if (!tbHandle)
      return (-1);
   
   HLock ((Handle)tbHandle);
   
   if (idx == (*tbHandle)->tbItems)  {
   
      if (iconId)
         useIconId = iconId;
      else  {
         useIconId = STD_SEPARATOR;
         iconWidth = kTB_SEP_WIDTH;
      }
      
      (*tbHandle)->tbIconId[idx] = useIconId;
      (*tbHandle)->tbState[idx] = TRUE;  // enabled
      
      if (!idx)
         (*tbHandle)->tbOffset[idx] = 0;
      else
         (*tbHandle)->tbOffset[idx] = (*tbHandle)->tbOffset[idx-1] + (*tbHandle)->tbWidth[idx-1];
      (*tbHandle)->tbWidth[idx] = iconWidth;

      (*tbHandle)->tbMenu[idx] = theMenu;
      (*tbHandle)->tbItem[idx] = theItem;

      // id_GetTBIconID (useIconId, &higIconId, &disIconId);

      (*tbHandle)->hciNormal[idx]   = id_GetCIcon (useIconId);
      // (*tbHandle)->hciHigh[idx]     = GetCIcon (higIconId);
      // (*tbHandle)->hciDisabled[idx] = GetCIcon (disIconId);
            
      if ((*tbHandle)->hciNormal[idx])
         idx = ++((*tbHandle)->tbItems);
   }

   HUnlock ((Handle)tbHandle);
   
   return (idx);  // returns next idx if OK
}

/* ....................................................... id_CoreDrawTBItem ........ */

// Ok, ovo se treba zvat Display, tj na Cocoa imamao NSImageView pa ga ne treba crtati
// Pa ovo treba instalirati image view ak već nije i onda više nema što, enable/disable
// negdje drugo - A ako je tu onda samo property na image view

static int  id_CoreDrawTBItem (FORM_REC *form, short idx, short hiFlag, short invalFlag)
{
   IDToolbarHandle  tbHandle = (IDToolbarHandle) form->toolBarHandle;
   NSButton        *imageButton = NULL;
   short            iconWidth, iconPosHor;
   Rect             tmpRect;
   WindowPtr        savedPort;

   if (!tbHandle)
      return (-1);
   
   HLock ((Handle)tbHandle);
   
   if (idx >= 0 && idx < (*tbHandle)->tbItems)  {
      
      OSErr   err;
      SInt32  response;
      
      err = Gestalt (gestaltSystemVersion, &response);      
      
      iconWidth = (*tbHandle)->tbWidth[idx];
      iconPosHor = (*tbHandle)->tbOffset[idx];
      
      SetRect (&tmpRect, iconPosHor, 0, iconPosHor + iconWidth, dtGData->toolBarHeight);   // ltrb
      
      // if (response == 4200)
      //    tmpRect.bottom += 6;
      // if (response == 4245)
      //    tmpRect.bottom += 2;

      if (form->my_window)  {
         
         if ((*tbHandle)->hciNormal[idx] && !(*tbHandle)->imbNormal[idx])  {
            // CGRect  btnRect = NSMakeRect (tmpRect.left, tmpRect.top, tmpRect.right-tmpRect.left, tmpRect.bottom-tmpRect.top);
            CGRect  btnRect = id_Rect2CGRect (&tmpRect);
            
            imageButton = [[NSButton alloc] initWithFrame:id_CocoaRect(form->my_window, btnRect)];
            
            [imageButton setButtonType:NSMomentaryLightButton]; //Set what type button You want
            // [imageButton setBezelStyle:NSRoundedBezelStyle]; //Must not have or it will be bad
            
            [imageButton setBordered:NO];
            
            [imageButton setAction:@selector(handleToolbar:)];
            [imageButton setTarget:[form->my_window contentView]];
            
            [imageButton setImage:(*tbHandle)->hciNormal[idx]];
            
            imageButton.title = @"";
            /*
            imageButton.imagePosition = NSImageOverlaps;
            
            NSButtonCell *cell = imageButton.cell;
            
            cell.imageScaling = NSImageScaleNone;
            
            NSLog (@"cellRect: %@", NSStringFromRect(imageButton.frame));*/
            
            imageButton.tag = idx;
            
            [[form->my_window contentView] addSubview:imageButton];

            (*tbHandle)->imbNormal[idx] = imageButton;
         }
         if ((*tbHandle)->imbNormal[idx])  {
            imageButton = (*tbHandle)->imbNormal[idx];
            
            if ((*tbHandle)->tbDisabled /*|| !(*tbHandle)->tbMenu[idx]*/)  // Nope, it gets lighter
               [imageButton setEnabled:NO];
            else  if (invalFlag)
               [imageButton setNeedsDisplay:YES];
            else  if (hiFlag)
               [imageButton setState:NSOnState];
            else  if ((*tbHandle)->tbState[idx] && !(*tbHandle)->tbDisabled)  {
               [imageButton setEnabled:YES];
               [imageButton setState:NSOffState];
            }
            else
               [imageButton setEnabled:NO];
         }
         
#ifdef _NOT_YET_

         GetWinPort (&savedPort);
         SetWinPort (form->my_window);
         
         if ((*tbHandle)->tbDisabled)
            iconHandle = (*tbHandle)->hciDisabled[idx];
         else  if (invalFlag)
            InvalWinRect (form->my_window, &tmpRect);
         else  if (hiFlag)
            iconHandle = (*tbHandle)->hciHigh[idx];
         else  if ((*tbHandle)->tbState[idx] && !(*tbHandle)->tbDisabled)
            iconHandle = (*tbHandle)->hciNormal[idx];
         else
            iconHandle = (*tbHandle)->hciDisabled[idx];
      
         if (iconHandle)
            PlotCIcon (&tmpRect, iconHandle);
            
         SetWinPort (savedPort);
#endif
      }
   }

   HUnlock ((Handle)tbHandle);
   
   return (0);
}

/* ....................................................... id_DrawTBItem ............ */

static int  id_DrawTBItem (
 FORM_REC *form,
 short     idx
)
{
   return (id_CoreDrawTBItem (form, idx, FALSE, FALSE));  // no hi, yes inval);
}

/* ....................................................... id_drawTBPadding ......... */

// Ovdje crtamo taj vrag pa nije imgView

int  id_DrawTBPadding (
 FORM_REC *form
)
{
   IDToolbarHandle  tbHandle = (IDToolbarHandle) form->toolBarHandle;
   NSView          *contentView = [form->my_window contentView];
   // CIconHandle      iconHandle = NULL;
   short            iconWidth, iconPosHor, idx;
   Rect             tmpRect, clientRect;
   
   if (!tbHandle)
      return (-1);
   
   HLock ((Handle)tbHandle);
   
   idx = (*tbHandle)->tbItems - 1;
   
   if (idx > 0 && idx < kMAX_IDTOOLS)  {

      iconWidth = (*tbHandle)->tbWidth[idx];
      iconPosHor = (*tbHandle)->tbOffset[idx] + iconWidth;
      
      id_GetClientRect (form, &clientRect);
      
      iconWidth = kTB_ICN_WIDTH;
      
      /*if ([contentView canDraw])  {
         
         [contentView lockFocus];*/
      
         while (iconPosHor < clientRect.right)  {
            
            SetRect (&tmpRect, iconPosHor, 0, iconPosHor + iconWidth, dtGData->toolBarHeight);   // ltrb
            
            if ((*tbHandle)->hciPadding)
               id_PlotCIcon (&tmpRect, (*tbHandle)->hciPadding);
            iconPosHor += iconWidth;
         }
         
         /* [contentView unlockFocus];
      }*/
   }
   
   HUnlock ((Handle)tbHandle);
   
   return (0);
}

/* ....................................................... id_DrawIconToolbar ....... */

// Here I call this on form open but really it needs to be called before drawRect:
// Maybe as I catch needsDisplay or something

int  id_DrawIconToolbar (
 FORM_REC *form
)
{
   IDToolbarHandle  tbHandle = (IDToolbarHandle) form->toolBarHandle;
   short            tbItems, i;
   
   if (!tbHandle)
      return (-1);
   
   tbItems = (*tbHandle)->tbItems;
      
   for (i=0; i<tbItems; i++)
      id_DrawTBItem (form, i);
      
   // NOT HERE! - id_DrawTBPadding (form);
   
   id_DrawTBPopUp (form);
  
   return (0);
}

/* ....................................................... id_create_toolbar ........ */

void  id_create_toolbar (FORM_REC *form)
{
   short  idx;
   
   // if (!gGTBCreatorPP)  return;
   
   id_CreateIconToolbar (form);
   
   idx = 0;
   
   if (form->toolBarHandle)  {
      
      // if (gGTBCreatorPP)
      //    (*gGTBCreatorPP) (form);
      
      idx = id_SetTBItem (form, idx, STD_FILENEW,  File_MENU_ID, NEW_Command);
      idx = id_SetTBItem (form, idx, 0, 0, 0);                        // Separator
      idx = id_SetTBItem (form, idx, STD_FILEOPEN, File_MENU_ID, OPEN_Command);
      idx = id_SetTBItem (form, idx, STD_FILESAVE, File_MENU_ID, SAVE_Command);
      idx = id_SetTBItem (form, idx, 0, 0, 0);                        // Separator
      idx = id_SetTBItem (form, idx, STD_UNDO,     Edit_MENU_ID, undoCommand);
      idx = id_SetTBItem (form, idx, STD_CUT,      Edit_MENU_ID, cutCommand);
      idx = id_SetTBItem (form, idx, STD_COPY,     Edit_MENU_ID, copyCommand);
      idx = id_SetTBItem (form, idx, STD_PASTE,    Edit_MENU_ID, pasteCommand);
      idx = id_SetTBItem (form, idx, 0, 0, 0);                        // Separator
      idx = id_SetTBItem (form, idx, STD_FIND,     Work_MENU_ID, FIND_Command);
      idx = id_SetTBItem (form, idx, 0, 0, 0);                        // Separator
      idx = id_SetTBItem (form, idx, STD_PRINT,    File_MENU_ID, PRINT_Command);
      idx = id_SetTBItem (form, idx, 0, 0, 0);                        // Separator
      
      SetRect (&(*(IDToolbarHandle)(form->toolBarHandle))->popUpRect, 0, 0, 0, 0);  // ltrb
   }
}

/* ....................................................... id_CalcTBPopRect ......... */

int  id_CalcTBPopRect (
 FORM_REC *form,
 Rect     *popRect
)
{
   static char     *templateStr = "100 % ";
   IDToolbarHandle  tbHandle = (IDToolbarHandle) form->toolBarHandle;
   short            popWidth, startHorPos, idx, retVal = -1;
   Rect             clientRect, tmpRect;

   if (!tbHandle)
      return (-1);

   HLock ((Handle)tbHandle);
   
   idx = (*tbHandle)->tbItems - 1;
      
   if (idx > 0 && idx < kMAX_IDTOOLS)  {
   
      startHorPos = (*tbHandle)->tbOffset[idx] + (*tbHandle)->tbWidth[idx] + kTB_SEP_WIDTH;
      
      id_GetClientRect (form, &clientRect);

      // TextFont (geneva);  TextSize (9);  TextFace (0);
      
      popWidth = id_TextWidth (form, templateStr, 0, strlen(templateStr));
   
      popWidth += 48;
      
      SetRect (&tmpRect, startHorPos, dtGData->toolBarHeight/4+2 - 3,
                         startHorPos + popWidth, dtGData->toolBarHeight/4 + 16 + 1);   // ltrb

      if (tmpRect.right < clientRect.right)  {
         *popRect = tmpRect;
         retVal = 0;
      }
   }
   HUnlock ((Handle)tbHandle);

   return (retVal);
}

/* ....................................................... id_DrawTBPopUp ........... */

extern  int  gGScaleValues[kScaleLevels];

static int  id_DrawTBPopUp (
 FORM_REC  *form
)
{
   char             tmpStr[256];
   IDToolbarHandle  tbHandle = (IDToolbarHandle) form->toolBarHandle;
   short            popWidth, popPosHor, idx;
   Rect             tmpRect;
   
   if (!tbHandle || (*tbHandle)->popUpHandle || id_CalcTBPopRect(form, &tmpRect))  return (-1);
   
   HLock ((Handle)tbHandle);
   
   (*tbHandle)->popUpRect = tmpRect;
                                           
   sprintf (tmpStr, "%hd %%", form->scaleRatio);
   
   NSPopUpButton      *popUp = nil;
   NSPopUpButtonCell  *cell = nil;
   
   CGRect  popFrame = NSMakeRect (tmpRect.left, tmpRect.top, tmpRect.right - tmpRect.left, tmpRect.bottom - tmpRect.top);
   
   popUp = [[NSPopUpButton alloc] initWithFrame:id_CocoaRect(form->my_window, popFrame)];
   
   [[form->my_window contentView] addSubview:popUp];
   
   [popUp setTag:-1];
   
   [popUp setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize] - 1]];
   
   // popUp->OnSelect_listener = NULL;
   
   cell = [popUp cell];
   /*[cell setBezelStyle:NSShadowlessSquareBezelStyle];*/
   [cell setArrowPosition:NSPopUpArrowAtBottom];
   cell.controlSize = NSMiniControlSize;  // NSSmallControlSize
   
   
   [popUp setPullsDown:NO];
   [popUp setTarget:[form->my_window contentView]];
   [popUp setAction:@selector(onScaleSelectionChange:)];
   
   for (int i=0; i<kScaleLevels; i++)
      [popUp addItemWithTitle:[NSString stringWithFormat:@"%d %%", gGScaleValues[i]]];

   /*for (int i=100; i<=200; i+=10)
      [popUp addItemWithTitle:[NSString stringWithFormat:@"%d %%", i]];*/

   HUnlock ((Handle)tbHandle);
   
   return (0);
}

