//
//  MainLoop.m
//  GeneralCocoaProject
//
//  Created by Sophie Marceau on 16.07.23.
//  Copyright 2023 Delovski d.o.o. All rights reserved.
//

#import "MainLoop.h"
#import "GetNextEvent.h"


// GLOBALS

DTGlobalData     *dtGData = NULL;
FORM_REC         *dtMainForm = NULL;
FORM_REC         *dtDialogForm = NULL;
FORM_REC         *dtRenderedForm = NULL;

static int  pr_InspectMenu (short theMenuID);  // 129 is File menu
static int  pr_CreateMenu (NSMenu *menuBar, id target, short theMenuID);  // 129 is File menu
static int  pr_InsertSubMenu (NSMenuItem *parentMenuItem, id target, short theMenuID);

@implementation MainLoop

#pragma mark Menu

+ (void)menuAction:(id)sender
{
   NSLog (@"%@", sender);
} 

+ (void)buildMainMenu
{
   FSRef  appParentFolderFSRef /*, parentFSRef, bundleParentFolderFSRef*/;
   char   appName[256];

   if (!id_GetApplicationExeFSRef(&appParentFolderFSRef))  {
      if (!id_ExtractFSRef(&appParentFolderFSRef, appName, nil/*&parentFSRef*/))
         NSLog (@"AppName: %s", appName);
   }
   
   // **** Menu Bar **** //
   NSMenu      *menubar = [NSMenu new];
   NSMenuItem  *tmpMenuItem;
   
   [NSApp setMainMenu:menubar];
   
   // **** App Menu **** //
   NSMenuItem  *appMenuItem = [NSMenuItem new];
   NSMenu      *appMenu = [NSMenu new];
   
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
   [tmpMenuItem setTarget: NSApp];
   
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

@end

BOOL  id_MainLoop (FORM_REC *form)
{
   EventRecord  evtRecord;
   BOOL         done = FALSE;
   
   dtMainForm = form;
   
   do  {
      
      id_GetNextEvent (&evtRecord, 500.);

      // NSLog (@"One tick!...");
      
      if (evtRecord.what == keyDown)
         NSLog (@"Key in keyDown: %c %hd", (unsigned char)evtRecord.message, (short)evtRecord.message);
      
      if (evtRecord.what == keyDown && evtRecord.message == 'q')
         done = TRUE;
      
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
   
   NSMenu      *mainMenu = [NSApp mainMenu];
   NSMenuItem  *subMenu = [mainMenu itemAtIndex:0];
   MenuHandle  *menuHandle = (MenuHandle *)mainMenu;
   
   NSLog (@"Menu title: %@", [((NSMenu *)menuHandle) title]);
   NSLog (@"Menu title: %@", [((NSMenu *)subMenu) title]);
   
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
   
   if (!id_InitComputerName (compName, 128))
      NSLog (@"Computer: %s", compName);
   if (!id_InitComputerUserName (userName, 128))
      NSLog (@"User: %s", userName);

   

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

   NSLog (@"id_FindForm: %@ %d", nsWindow.title, (int)nsWindow.windowNumber);

   if (dtDialogForm && dtDialogForm->my_window == nsWindow)
      return (dtDialogForm);
   if (dtRenderedForm && dtRenderedForm->my_window == nsWindow)
      return (dtRenderedForm);

   if (dtMainForm->my_window == nsWindow)
      NSLog (@"We have ourseves a window!");
   
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
   
   *dstStr = CFStringCreateWithBytes (NULL, (const UInt8 *) chPtr, usedLen, kTextEncodingWindowsLatin2/*kTextEncodingISOLatin2*/, FALSE);  // or kTextEncodingMacRoman
   
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
   // err = FSOpenResourceFile (&ref, 0, NULL, fsRdPerm, res);
   
   return (resRefNum);
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

void TestVersion (void)
{
   OSErr   err;
   SInt32  response;
   
   err = Gestalt (gestaltSystemVersion, &response);
   
   if (err == noErr) 
      NSLog (@"Gestalt: %ld - %lx\n", response, response);
}

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
      
      NSLog (@"Menu title: %s\n", tmpStr);
      
      for (chPtr=mr->i_title+dataSize+1, dataSize=*(chPtr-1); dataSize; chPtr += dataSize+1+3+1,dataSize=*(chPtr-1))  {
         BlockMove (chPtr, tmpStr, dataSize);
         tmpStr[dataSize] = '\0';
         NSLog (@"Item title: %s (%c)\n", tmpStr, *(chPtr + dataSize+1) ? *(chPtr + dataSize+1) : ' ');
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
   
   if (mh)  {
      HLock (mh);
      mr = (MENU_rsrc *)*mh;
      
      dataSize = mr->i_title_size;
      BlockMove (mr->i_title, tmpStr, dataSize);
      tmpStr[dataSize] = '\0';
      
      NSLog (@"Menu title: %s\n", tmpStr);
      
      id_Mac2CFString (tmpStr, &cfStr, strlen(tmpStr));
      
      theMenu = [[NSMenu alloc] initWithTitle:(NSString *)cfStr];
      
      CFRelease (cfStr);
      
      for (i=1,chPtr=mr->i_title+dataSize+1, dataSize=*(chPtr-1); dataSize; chPtr += dataSize+1+3+1,dataSize=*(chPtr-1),i++)  {
         BlockMove (chPtr, tmpStr, dataSize);
         tmpStr[dataSize] = '\0';
         NSLog (@"Item title: %s (%c)\n", tmpStr, *(chPtr + dataSize+1) ? *(chPtr + dataSize+1) : ' ');

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
   
   if (mh)  {
      HLock (mh);
      mr = (MENU_rsrc *)*mh;
      
      dataSize = mr->i_title_size;
      BlockMove (mr->i_title, tmpStr, dataSize);
      tmpStr[dataSize] = '\0';
      
      NSLog (@"Menu title: %s\n", tmpStr);
      
      // id_Mac2CFString (tmpStr, &cfStr, strlen(tmpStr));
      
      theMenu = [[NSMenu alloc] initWithTitle:parentMenuItem.title/*(NSString *)cfStr*/];
      
      // CFRelease (cfStr);
      
      for (i=1,chPtr=mr->i_title+dataSize+1, dataSize=*(chPtr-1); dataSize; chPtr += dataSize+1+3+1,dataSize=*(chPtr-1),i++)  {
         BlockMove (chPtr, tmpStr, dataSize);
         tmpStr[dataSize] = '\0';
         NSLog (@"Item title: %s (%c)\n", tmpStr, *(chPtr + dataSize+1) ? *(chPtr + dataSize+1) : ' ');

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


