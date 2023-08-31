//
//  MainLoop.m
//  GeneralCocoaProject
//
//  Created by me on 16.07.23.
//  Copyright 2023 Delovski d.o.o. All rights reserved.
//

#import  "MainLoop.h"

#import  "DTOverlayView.h"
#import  "GetNextEvent.h"
#import  "NiblesTestAppDelegate.h"
#import  "FirstForm.h"


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

@implementation MainLoop

#pragma mark Menu

static FORM_REC  newForm;

+ (NSWindow *)openInitialWindowAsForm:(FORM_REC *)form
{
   NSWindow  *aWindow;
	// Insert code here to initialize your application
   
   CGFloat  menuBarHeight = NSStatusBar.systemStatusBar.thickness;
   NSRect   availableFrame = [NSScreen mainScreen].visibleFrame;
   
   id_init_form (form);

   availableFrame.origin.y += menuBarHeight;
   availableFrame.size.height -= menuBarHeight;
      
   NSLog (@"Menu bar height: %.0f", menuBarHeight);
   NSLog (@"Screen Frame orig: %@", NSStringFromRect (availableFrame));
   NSLog (@"Screen Frame normal: %@", NSStringFromRect (id_CocoaRect(nil, availableFrame)));
   
   
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
   [aWindow makeKeyAndOrderFront:NSApp];
   
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

   NSView  *foreView = [[DTOverlayView alloc] initWithFrame:viewFrame];  // Find a way to put it on top
   
   [(NSView *)form->my_window.contentView addSubview:foreView positioned:NSWindowAbove relativeTo:nil];
   
   form->overlayView = foreView;
   
   [foreView release];
}

+ (void)menuAction:(id)sender
{
   NiblesTestAppDelegate  *appDelegate = (NiblesTestAppDelegate *)[NSApp delegate];
   NSDictionary           *menuDict = appDelegate.menuDict;

   CGRect  tmpRect = CGRectMake(1, 39, 1+484, 39+244+72+64+8+54);
   
   NSLog (@"%@", sender);
   
   NSMenu      *menuBar = [NSApp mainMenu];
   NSMenuItem  *menuItem = (NSMenuItem *)sender;
   NSMenu      *superMenu = [menuItem menu];
   NSMenuItem  *parentItem = [menuItem parentItem];
   
   NSInteger    menuIndex = [menuBar indexOfItem:parentItem];
   NSInteger    itemIndex = [superMenu indexOfItem:menuItem];
   
   NSNumber  *num = [menuDict valueForKey:superMenu.title];
   
   if (num)
      NSLog (@"Menu index: %d, itemIndex: %d", [num intValue], itemIndex);
   else
      NSLog (@"Menu index: %d, itemIndex: %d", menuIndex+128, itemIndex);
   

   if (!newForm.my_window && menuIndex > 3)  {
      id_SetBlockToZeros (&newForm, sizeof(FORM_REC));
      pr_CreateDitlWindow (&newForm, 601, tmpRect, "Bravo majstore");
   }
} 

+ (void)buildMainMenu
{
   char   appName[256];
   FSRef  appParentFolderFSRef;

   NiblesTestAppDelegate  *appDelegate = (NiblesTestAppDelegate *)[NSApp delegate];
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
   
   tmpMenuItem = [self findMenuItem:130-128 withTag:8];  // Osobnosti
   if (tmpMenuItem)
      pr_InsertSubMenu (tmpMenuItem, self, 12);
   
   tmpMenuItem = [self findMenuItem:130-128 withTag:11];  // Hyper
   if (tmpMenuItem)
      pr_InsertSubMenu (tmpMenuItem, self, 14);

   tmpMenuItem = [self findMenuItem:130-128 withTag:13];  // IBAN
   if (tmpMenuItem)
      pr_InsertSubMenu (tmpMenuItem, self, 13);

   tmpMenuItem = [self findMenuItem:133-128 withTag:3];  // Matpod
   if (tmpMenuItem)
      pr_InsertSubMenu (tmpMenuItem, self, 1);
   tmpMenuItem = [self findMenuItem:133-128 withTag:4];  // Skladno
   if (tmpMenuItem)
      pr_InsertSubMenu (tmpMenuItem, self, 2);
   tmpMenuItem = [self findMenuItem:133-128 withTag:6];  // Skladno
   if (tmpMenuItem)
      pr_InsertSubMenu (tmpMenuItem, self, 3);
   tmpMenuItem = [self findMenuItem:133-128 withTag:7];  // Skladno
   if (tmpMenuItem)
      pr_InsertSubMenu (tmpMenuItem, self, 4);

   tmpMenuItem = [self findMenuItem:133-128 withTag:9];  // Skladno
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

BOOL  id_MainLoop (FORM_REC *form)
{
   EventRecord  evtRecord;
   BOOL         done = FALSE;
   
   do  {
      
      id_GetNextEvent (&evtRecord, 500.);

      // NSLog (@"One tick!...");
      
      if (evtRecord.what == keyDown)
         NSLog (@"Key in keyDown: %c %hd", (unsigned char)evtRecord.message, (short)evtRecord.message);
      
      // if (evtRecord.what == keyDown && evtRecord.message == 'q')
      //   done = TRUE;
      
      if (evtRecord.what == keyDown && evtRecord.message == '\t')  {
         NSLog (@"Tab!");
         
         if (form->leftField.currentEditor == form->my_window.firstResponder)  {
            NSLog (@"Left had Focus");
            [form->my_window makeFirstResponder:form->rightField];
            // [form->rightField becomeFirstResponder];
         }
         else  if (form->rightField.currentEditor == form->my_window.firstResponder)  {
            NSLog (@"Right has Focus");
            [form->my_window makeFirstResponder:form->leftField];
            // [form->leftField becomeFirstResponder];
         }
         
         if (form->leftField.window == form->my_window)
            NSLog (@"My nigger!");
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
   
   dtGData->statusBarHeight = 20;  // On Win98...
   dtGData->toolBarHeight   = kTB_ICN_HEIGHT;

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

/* ................................................... id_init_form ................. */

FORM_REC  *id_init_form (FORM_REC *form)
{
   id_SetBlockToZeros (form, sizeof (FORM_REC));
   
   form->scaleRatio = 100;
   
   form->pathsArray = CFArrayCreateMutable (NULL, 0, &kCFTypeArrayCallBacks);
   form->pdfsArray = CFArrayCreateMutable (NULL, 0, &kCFTypeArrayCallBacks);
   
   return (form);
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
   if ([NSApp mainWindow])
      return ([NSApp mainWindow]);
      
   return ([NSApp keyWindow]);  // or mainWindow
}

OSErr id_GetParentFSRef (const FSRef *fileFSRef, FSRef *parentFSRef)
{
   OSErr osErr = FSGetCatalogInfo (fileFSRef, kFSCatInfoNone, NULL, NULL, NULL, parentFSRef);
   
   return (osErr);
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
   
   CFStringGetBytes (tmpStr ? tmpStr : srcStr, CFRangeMake(0, len), kTextEncodingISOLatin1/*kTextEncodingWindowsLatin2*/, '?', FALSE, (UInt8 *) dstStr, maxLen, &usedBufLen);
   
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

// -----------------------

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

int  id_GetApplicationDataDir (FSRef *appDataFSRef) // out, appData folder, there is id_GetAppDataVolume()
{
   short               retVal = -1;
   // FSSpec              appDataFSSpec;
   OSStatus            osStatus;
   
   osStatus = FSFindFolder (kOnSystemDisk, kPreferencesFolderType, kDontCreateFolder, appDataFSRef);
   
   // osStatus = FindFolder (kOnSystemDisk, kPreferencesFolderType, kDontCreateFolder,
   //                        &appDataFSSpec.vRefNum, &appDataFSSpec.parID);
   
   if (!osStatus)  {
      // appDataFSSpec.name[0] = '\0';

      // if (!FSpMakeFSRef(&appDataFSSpec, appDataFSRef))
         retVal = 0;
   }
   
   return (retVal);
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
   
   err = Gestalt (gestaltSystemVersion, &response);
   
   if (err == noErr) 
      NSLog (@"Gestalt: %ld - %lx\n", response, response);
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

#pragma mark -

// Needed only for windows as all views are flipped

CGRect  id_CocoaRect (NSWindow *window, CGRect nmlRect)
{
   NSView  *contentView = window ? [window contentView] : nil;
   CGRect   contentRect = window ? contentView.bounds : [[NSScreen mainScreen] frame];
   CGRect   cocoaRect = nmlRect;
   
   if (!window)
      cocoaRect.origin.y = contentRect.size.height - (nmlRect.origin.y + nmlRect.size.height);
   
   return (cocoaRect);
}

#pragma mark printing

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
   
   NiblesTestAppDelegate  *appDelegate = (NiblesTestAppDelegate *)[NSApp delegate];
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
            [tmpMenuItem setTag:i];
            
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
   
   NiblesTestAppDelegate  *appDelegate = (NiblesTestAppDelegate *)[NSApp delegate];
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
            [tmpMenuItem setTag:i];
         
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
         sprintf (dateText, "%02hd%02hd%02hd", dtRec.day, dtRec.month, dtRec.year-2000);
      else
         sprintf (dateText, "%02hd%02hd%02hd", dtRec.day, dtRec.month, dtRec.year-1900);
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
   
   sprintf (txtBuff, "%.3s, %02hd. %.3s, %hd.", dayOfWeek, (short)gDate.day, monthName, gDate.year);
   
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

void  InsetRect (Rect *rect, short h, short v)
{ 
   rect->left += h; 
   rect->top += v; 
   rect->right -= h; 
   rect->bottom -= v; 
} 
#endif

CGRect  id_Rect2CGRect (Rect *rect)
{
   return (CGRectMake(rect->left, rect->top, rect->right-rect->left, rect->bottom-rect->top));
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
   
   SetRect (rect,
            viewFrame.origin.x, viewFrame.origin.y,
            viewFrame.origin.x + viewFrame.size.width, viewFrame.origin.y + viewFrame.size.height);
   
   // if (form->w_procID == documentProc)  {
      rect->top += dtGData->toolBarHeight;
      rect->bottom -= kSBAR_HEIGHT /*dtGData->statusBarHeight*/;
   // }
}

/* ....................................................... id_itemsRect ............. */

int id_itemsRect (FORM_REC *form, NSControl *field, Rect *fldRect)
{
   // short  scalePercent = 0;
   
   // if (id_inpossible_item (form, index))  {
   //    SetRect (fldRect, 0, 0, 0, 0);
   //    return (-1);
   // }
   
   SetRect (fldRect,
            field.frame.origin.x, field.frame.origin.y,
            field.frame.origin.x + field.frame.size.width, field.frame.origin.y + field.frame.size.height);
   
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
 PatPtr      frPatPtr
)
{
   WindowPtr   savedPort;
   Rect        frameBounds, fldRect1, fldRect2;
         
   // if (id_inpossible_item (form, index_1) || id_inpossible_item (form, index_2))
   //    return (-1);
   
   id_itemsRect (form, fldno_1, &fldRect1);
   id_itemsRect (form, fldno_2, &fldRect2);
   
   SetRect (&frameBounds, fldRect1.left,  fldRect1.top,     /* LT */
                          fldRect2.right, fldRect2.bottom); /* RB */
   
   InsetRect (&frameBounds, -distance, -distance);

   /*PenPat (frPatPtr);
   FrameRect (&frameBounds);
   PenPat (QD_Black());*/
   
   CGRect  frameRect = CGRectMake (frameBounds.left, frameBounds.top, frameBounds.right - frameBounds.left, frameBounds.bottom - frameBounds.top);
   
   CGMutablePathRef  path = CGPathCreateMutable ();
   
	CGPathAddRect (path, NULL, frameRect);
   
   CFArrayAppendValue (form->pathsArray, path);
   
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

static NSImage  *id_GetCIcon (short rsrc_id)
{
   NSString  *iconName = [NSString stringWithFormat:@"CICN%04hd", rsrc_id];
   
   NSImage  *iconImage = [NSImage imageNamed:iconName];
   
   return (iconImage);
}

static void  id_PlotCIcon (Rect *macRect, NSImage *iconImage)
{
   CGRect  icnRect = CGRectMake (macRect->left, macRect->top, macRect->right - macRect->left, macRect->bottom - macRect->top);
   
   [MainLoop drawImage:iconImage inFrame:icnRect form:NULL];
}

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
      
   NSLog (@"ClientRect: %@", NSStringFromRect(id_Rect2CGRect(&clientRect)));
   
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
         tmpRect.left  = 2;
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
      CGRect       strRect = CGRectMake (tmpRect.left, tmpRect.top, tmpRect.right-tmpRect.left, tmpRect.bottom-tmpRect.top);
      
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
            CGRect  btnRect = NSMakeRect (tmpRect.left, tmpRect.top, tmpRect.right-tmpRect.left, tmpRect.bottom-tmpRect.top);
            
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
            
            if ((*tbHandle)->tbDisabled)
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
   
   for (int i=100; i<=200; i+=10)
      [popUp addItemWithTitle:[NSString stringWithFormat:@"%d %%", i]];

   HUnlock ((Handle)tbHandle);
   
   return (0);
}

