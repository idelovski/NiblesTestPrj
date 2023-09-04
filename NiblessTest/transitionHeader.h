//
//  transitionHeader.h
//  GeneralCocoaProject
//
//  Created by me on 16.07.23.
//  Copyright 2023 Delovski d.o.o. All rights reserved.
//

// This thing will contain Carbon types and stuff

// TEMP STUFF

// -------------------
#define _DTOOL_COCOA_
// -------------------


#define  MAX_PATH        256

#define  kEVENTS_STACK    64

#define  id_stop_emsg(msg)  NSLog(@msg)

#define  kScaleLevels   11
#define  kScaledFonts   (kScaleLevels-1)

#define  id_SetBlockToZeros(ptr,sz)   memset(ptr,'\0',sz)
#define  BlockMove(s,d,l)             memmove(d,s,l)
#define  BlockMoveData(s,d,l)         memmove(d,s,l)
#define  GetHandleSize(h)             GlobalSize(h)
#define  SetHandleSize(h,s)           GlobalReAlloc(h,s,GHND)
#define  MoveTo(hdc,x,y)              MoveToEx(hdc,x,y,NULL)
#define  EmptyRect(r)                 IsRectEmpty(r)
// #define  TickCount()                  GetTickCount()
// #define  FrameRect                    DrawRect
// #define  Ellipse                      DrawEllipse

#define  GetMouse(p)                  GetCursorPos(p)
#define  CountMItems(mh)              GetMenuItemCount(mh)

#define  topLeft(r)        (((POINT *)&(r))[0])
#define  botRight(r)       (((POINT *)&(r))[1])


#pragma mark AppleStuff


typedef struct  {
   short   vRefNum;
   short   versNum;
   OSType  fType;
   char    fName[MAX_PATH];
} AppFile;

enum {
   newYork                 = 2,
   geneva                  = 3,
   monaco                  = 4,
   times                   = 20,
   helvetica               = 21,
   courier                 = 22
};


#ifdef _NIJE_

enum {
   nullEvent                     = 0,
   mouseDown                     = 1,
   mouseUp                       = 2,
   keyDown                       = 3,
   keyUp                         = 4,
   autoKey                       = 5,
   updateEvt                     = 6,
   diskEvt                       = 7,    /* Not sent in Carbon. See kEventClassVolume in CarbonEvents.h*/
   activateEvt                   = 8,
   osEvt                         = 15,
   kHighLevelEvent               = 23
};

enum {
   mDownMask                     = 1 << mouseDown, /* mouse button pressed*/
   mUpMask                       = 1 << mouseUp, /* mouse button released*/
   keyDownMask                   = 1 << keyDown, /* key pressed*/
   keyUpMask                     = 1 << keyUp, /* key released*/
   autoKeyMask                   = 1 << autoKey, /* key repeatedly held down*/
   updateMask                    = 1 << updateEvt, /* window needs updating*/
   diskMask                      = 1 << diskEvt, /* disk inserted*/
   activMask                     = 1 << activateEvt, /* activate/deactivate window*/
   highLevelEventMask            = 0x0400, /* high-level events (includes AppleEvents)*/
   osMask                        = 1 << osEvt, /* operating system events (suspend, resume)*/
   everyEvent                    = 0xFFFF /* all of the above*/
};

enum {
   charCodeMask                  = 0x000000FF,
   keyCodeMask                   = 0x0000FF00,
   adbAddrMask                   = 0x00FF0000,
   osEvtMessageMask              = (unsigned long)0xFF000000
};

enum {
   /* OS event messages.  Event (sub)code is in the high byte of the message field.*/
   mouseMovedMessage             = 0x00FA,
   suspendResumeMessage          = 0x0001
};

enum {
   resumeFlag                    = 1     /* Bit 0 of message indicates resume vs suspend*/
};

/*
 CARBON ALERT! BATTLESTATIONS!
 
 The EventModifiers bits defined here are also used in the newer Carbon Event
 key modifiers parameters. There are two main differences:
 
 1)  The Carbon key modifiers parameter is a UInt32, not a UInt16. Never try to
 extract the key modifiers parameter from a Carbon Event into an EventModifiers
 type. You will probably get your stack trashed.
 2)  The Carbon key modifiers is just that: key modifiers. That parameter will
 never contain the button state bit.
 */
enum {
   /* modifiers */
   activeFlagBit                 = 0,    /* activate? (activateEvt and mouseDown)*/
   btnStateBit                   = 7,    /* state of button?*/
   cmdKeyBit                     = 8,    /* command key down?*/
   shiftKeyBit                   = 9,    /* shift key down?*/
   alphaLockBit                  = 10,   /* alpha lock down?*/
   optionKeyBit                  = 11,   /* option key down?*/
   controlKeyBit                 = 12,   /* control key down?*/
   rightShiftKeyBit              = 13,   /* right shift key down? Not supported on Mac OS X.*/
   rightOptionKeyBit             = 14,   /* right Option key down? Not supported on Mac OS X.*/
   rightControlKeyBit            = 15    /* right Control key down? Not supported on Mac OS X.*/
};

enum {
   activeFlag                    = 1 << activeFlagBit,
   btnState                      = 1 << btnStateBit,
   cmdKey                        = 1 << cmdKeyBit,
   shiftKey                      = 1 << shiftKeyBit,
   alphaLock                     = 1 << alphaLockBit,
   optionKey                     = 1 << optionKeyBit,
   controlKey                    = 1 << controlKeyBit,
   rightShiftKey                 = 1 << rightShiftKeyBit, /* Not supported on Mac OS X.*/
   rightOptionKey                = 1 << rightOptionKeyBit, /* Not supported on Mac OS X.*/
   rightControlKey               = 1 << rightControlKeyBit /* Not supported on Mac OS X.*/
};

/* MacRoman character codes*/
enum {
   kNullCharCode                 = 0,
   kHomeCharCode                 = 1,
   kEnterCharCode                = 3,
   kEndCharCode                  = 4,
   kHelpCharCode                 = 5,
   kBellCharCode                 = 7,
   kBackspaceCharCode            = 8,
   kTabCharCode                  = 9,
   kLineFeedCharCode             = 10,
   kVerticalTabCharCode          = 11,
   kPageUpCharCode               = 11,
   kFormFeedCharCode             = 12,
   kPageDownCharCode             = 12,
   kReturnCharCode               = 13,
   kFunctionKeyCharCode          = 16,
   kCommandCharCode              = 17,   /* glyph available only in system fonts*/
   kCheckCharCode                = 18,   /* glyph available only in system fonts*/
   kDiamondCharCode              = 19,   /* glyph available only in system fonts*/
   kAppleLogoCharCode            = 20,   /* glyph available only in system fonts*/
   kEscapeCharCode               = 27,
   kClearCharCode                = 27,
   kLeftArrowCharCode            = 28,
   kRightArrowCharCode           = 29,
   kUpArrowCharCode              = 30,
   kDownArrowCharCode            = 31,
   kSpaceCharCode                = 32,
   kDeleteCharCode               = 127,
   kBulletCharCode               = 165,
   kNonBreakingSpaceCharCode     = 202
};

/* useful Unicode code points*/
enum {
   kShiftUnicode                 = 0x21E7, /* Unicode UPWARDS WHITE ARROW*/
   kControlUnicode               = 0x2303, /* Unicode UP ARROWHEAD*/
   kOptionUnicode                = 0x2325, /* Unicode OPTION KEY*/
   kCommandUnicode               = 0x2318, /* Unicode PLACE OF INTEREST SIGN*/
   kPencilUnicode                = 0x270E, /* Unicode LOWER RIGHT PENCIL; actually pointed left until Mac OS X 10.3*/
   kPencilLeftUnicode            = 0xF802, /* Unicode LOWER LEFT PENCIL; available in Mac OS X 10.3 and later*/
   kCheckUnicode                 = 0x2713, /* Unicode CHECK MARK*/
   kDiamondUnicode               = 0x25C6, /* Unicode BLACK DIAMOND*/
   kBulletUnicode                = 0x2022, /* Unicode BULLET*/
   kAppleLogoUnicode             = 0xF8FF /* Unicode APPLE LOGO*/
};

typedef UInt16     EventKind;
typedef UInt16     EventMask;

typedef UInt16     EventModifiers;

struct EventRecord {
   EventKind           what;
   UInt32              message;
   UInt32              when;
   Point               where;
   EventModifiers      modifiers;
   
   NSWindow           *nswindow;    // Cocoa stuff
};
typedef struct EventRecord              EventRecord;

#endif  // _NIJE_

#pragma mark MyStuff

typedef struct _OSTypeTable  {
   OSType  osType;
   char   *fExtension;
   char   *fDescription;
   short   allowAll;
   OSType  inclOSType;
} OSTypeTable;

typedef struct {
   short     oFont;
   short     oSize;
   short     oFace;  // was Style;
   NSFont   *hFont;
   NSFont   *hScaledFont[kScaledFonts];
} ID_LAYOUT;

typedef union  {                  /* --------------------- Data in every DITL item --- */
    short  d_ctl_rsrcID;
    char   d_title[255];
    char   d_text[255];
    short  d_icon_rsrcID;
} DITL_i_data;

typedef struct  {                /* -------------------- Data from ResorceDataFile --- */
    Handle         i_handle;
    Rect           i_rect;
    char           i_type;
    unsigned char  i_data_size;
    DITL_i_data    i_data;
} DITL_item;

typedef struct  {                /* -------------------- Menu from ResorceDataFile --- */
   short          i_menu_id;
   short          i_placeholder_w;
   short          i_placeholder_h;
   short          i_mdef_id;
   short          i_zero;
   short          i_enableFlags_1;
   short          i_enableFlags_2;
   unsigned char  i_title_size;
   char           i_title[255];
   char           i_item[];
} MENU_rsrc;

#ifdef _DTOOL_COCOA_

typedef struct  {                /* -------------------- Data from ResorceDataFile --- */
   SInt32         i_handle;
   Rect           i_rect;
   char           i_type;
   unsigned char  i_data_size;
   DITL_i_data    i_data;
} DITL_rsrc_item;

#endif  // _DTOOL_COCOA_

struct _Form;

typedef struct  {                /* -------------------- Edit data for an item ------- */
   short       e_fldno;
   short       e_type;
   short       e_maxlen, e_precision;
   short       e_elems, e_onscreen;
   short       e_justify;
   SInt32      e_fld_edits;
   char       *e_regular;         // reused by TePop
   char       *e_future_use;      // Used on titles
   char       *e_status_line;
   int       (*e_entry_func)(struct _Form *, int, int, int),
             (*e_exit_func)(struct _Form *, int, int, int),
             (*e_find_func)(struct _Form *, int, int, int);
   short       e_occur;         /* Internal use */
   short       e_next_field;    /* Internal use */
   short       e_inRecOffset;   // Internal use, negative value is sfRec
   char        e_inRecType;     // Internal use, neki enum
   char        e_auto_alloced;  // Well, ...
   char      **e_array;         /* Internal use */
   char       *e_longText;      /* Internal use, content over 240 */
   // MWSHandle   mwsHandle;       /* Internal use */
   ID_LAYOUT  *e_fld_layout;    /* Internal use, set by user */
} EDIT_item;


struct  _Form  {
   short         itemHit;
   short         creationIndex;
   short         cur_fldno;  // Tag Minus One
   short         prev_cur_fldno;
   short         scaleRatio;

   NSWindow     *my_window;
   
   NSButton     *okButton;
   NSButton     *newWinButton;
   NSButton     *imgButton;
   
   NSImageView  *imgView;
   
   NSTextField  *leftField;
   NSTextField  *rightField;

   NSTextField  *labelField;

   NSTextField  *bigField;

   NSButton     *radioButton[3];
   NSButton     *checkBoxButton;

   NSPopUpButton  *popUpButtonL;
   NSPopUpButton  *popUpButtonS;
   NSPopUpButton  *popUpButtonR;

   Handle          DITL_handle; /* Resorce handle */ 
   short           last_fldno;  /* Copied from DITL */
   
   DITL_item     **ditl_def;
   EDIT_item     **edit_def;
   
   Handle          toolBarHandle;
   
   NSView         *overlayView;
   
   CGContextRef    drawRectCtx;  // = [NSGraphicsContext currentContext];
   
   CFMutableArrayRef  pathsArray;  // = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
   CFMutableArrayRef  pdfsArray;   // = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);

};
typedef struct  _Form  FORM_REC;

typedef struct  {
   // DTMBarInfo   mbi;
   
   short        mBarDisabled;
   short        appInBackground;
   short        popUpTracking;
   
   char         unDoText[256];   /*  UnDo Data */
   char         unDoFlag;
   short        unSelStart, unSelEnd;
   
   short        tabStyle;        /*  Tab Modifiers */
   
   short        errCode;
   char        *errMsg;
   
   NSTextField  *theInput;
   
   ID_LAYOUT    layStat;         /*  LayOuts */
   ID_LAYOUT    layEdit;
   ID_LAYOUT    layComm;
   ID_LAYOUT    layList;
   
   short        scrapCount;
   char         scrapTaken;
   char         scrapToGive;
   
   char        *grabText;        /* Text Grabing for Scrap */  // was Handle on Mac
   long         grabCnt;
   long         grabMax;
   unsigned
    short       dateStart,
                dateEnd;
   
   int        (*fbAccessProc) (void * fbPtr, short someFlag);
   int        (*errLogSaveProc) (char *, char *, char, char);
   int        (*fDblEditCheckProc)(void /*struct FormRecord*/ *, short fldNo, short txLen, short selStart, short selEnd, char ch);
   int        (*fDblExitCheckProc)(void /*struct FormRecord*/ *, short fldNo);
   
   short        errLogActive;
   
   short        quitNow;
   short        exportWaiting;  // for AutoExport
   short        uninstallNow;
   short        openFile;
   AppFile      openAFile;
   short        inportFile;
   AppFile      inportAFile;
   
   short        attachFile;
   AppFile      attachAFile;
   // FBPtr        attachFB;
   
   short        appVRefNum;    // from appPath, not GetSpecFolder...
   short        installFlag;
   
   short        toolBarHeight;
   
   short        postedMenu;    // to post a menu event
   short        postedItem;
   
   OSType       appSignature;
   OSTypeTable *osTypesTable;
   
   unsigned
   long        lastEventTick;  // TickCount() of last event
   unsigned
   long        lastEventDateTime;  // 
   unsigned
   long        lastJobDateTime;  // id_end_standard_job ()
   
   // Win extensions...
   
   short        deltaPerLine;    // wheel
   short        accumDelta;
   
   short        statusBarHeight;
   short        menuFontAveCharWidth;  // tmAveCharWidth for menuFont

#ifdef _MAYBE_
   HPEN         dotPen;
   HPEN         dashPen;
   HPEN         solidPen;        // stockObject, don't delete
   HPEN         whitePen;        // stockObject, don't delete
   HPEN         redPen;
   HPEN         greenPen;
   HPEN         yellowPen;
   HPEN         bluePen;
   
   HPEN         liteShdPen;
   HPEN         darkShdPen;
#endif
   
   EventRecord  eventRecord[kEVENTS_STACK];
   char         eventsUsed[kEVENTS_STACK];
   
   // ResFileInfo  resFileTable[kRES_FILE_STACK]; 
   // char         resFileUsed[kRES_FILE_STACK];
   
   CGPoint      mousePos;        // where -> eventRecord
   NSWindow    *whichWindow;     // za FindWindow(), tj. extra eventRec
   
   void       (*menuSetupHandler) (FORM_REC *form);
   FORM_REC    *commDlgForm;
   NSWindow    *commDlgNSWindow;
   
   char         appName[32];
   char         appPath[MAX_PATH];
   char         cmdLineFile[MAX_PATH];  // File to open at startup
   char         cmdLineParam[32];       // param like /print etc. at startup
   
   short        autoTaskVRefNum;
   char        *autoTaskCmdBuff;
   unsigned
   long        lastAutoTaskDateTime;  // So we know how much to wait
   
   short   fuse_vRefNumStartPrograms;   // Start Menu
   short   fuse_vRefNumAppData;         // C:\\AppData\\Bouquet
   short   fuse_vRefNumProgramFiles;    // C:\\Program Files\\Bouquet
   short   fuse_vRefNumNotUsed;
} DTGlobalData;

extern DTGlobalData  *dtGData;

#pragma mark TB

/* --------------------------------------------------------------- Menu IDs ---------- */

#define  kMenusInBar        6

#define  Apple_MENU_ID    128         /* --- Menu Titles --- */
#define  File_MENU_ID     129
#define  Edit_MENU_ID     130
#define  Task_MENU_ID     131
#define  Work_MENU_ID     132
#define  Wind_MENU_ID     133

#define  kSubMenusInAppl    9

#define  NEW_Command        1           /* --- File Menu Items --- */
#define  OPEN_Command       3
#define  LOCK_Command       4
#define  CLOSE_Command      5
#define  SAVE_Command       7
#define  SAVE_AS_Command    8
#define  INFO_Command      10
#define  PG_SET_Command    12
#define  PRINT_Command     13
#define  QUIT_Command      15

#define  undoCommand       1           /* --- Edit Menu Items --- */
#define  cutCommand        3
#define  copyCommand       4
#define  pasteCommand      5
#define  clearCommand      6

#define  FIND_Command       1         /* --- Work Menu Items --- */

/* ................................................... TOOLBAR ...................... */

#define  kMAX_IDTOOLS      16

#define  kTB_SEP_WIDTH     12
#ifdef _DTOOL_MAC_9_
#define  kTB_ICN_WIDTH     24
#else
#define  kTB_ICN_WIDTH     28
#endif
#define  kTB_ICN_HEIGHT    32


#define  STD_SEPARATOR    812
#define  STD_EMPTY        813

#define  STD_FILENEW      814
#define  STD_FILEOPEN     815
#define  STD_FILESAVE     816
#define  STD_UNDO         822
#define  STD_CUT          820
#define  STD_COPY         818
#define  STD_PASTE        821
#define  STD_FIND         819
#define  STD_PRINT        817

#define  HIL_FILENEW      824
#define  HIL_FILEOPEN     825
#define  HIL_FILESAVE     826
#define  HIL_UNDO         832
#define  HIL_CUT          830
#define  HIL_COPY         828
#define  HIL_PASTE        831
#define  HIL_FIND         829
#define  HIL_PRINT        827

#define  DIS_FILENEW      834
#define  DIS_FILEOPEN     835
#define  DIS_FILESAVE     836
#define  DIS_UNDO         842
#define  DIS_CUT          840
#define  DIS_COPY         838
#define  DIS_PASTE        841
#define  DIS_FIND         839
#define  DIS_PRINT        837


typedef struct _IDToolbar  {
   short        tbItems;
   short        tbDisabled;  // whole tb is disabled

   short        tbIconId[kMAX_IDTOOLS];  // cicn ids
   short        tbState[kMAX_IDTOOLS];   // enabled or not
   short        tbOffset[kMAX_IDTOOLS];  // x offset
   short        tbWidth[kMAX_IDTOOLS];   // 16 or 32

   short        tbMenu[kMAX_IDTOOLS];    // theMenu
   short        tbItem[kMAX_IDTOOLS];    // theItem

   NSImage     *hciPadding;  // CIconHandle

   NSImage     *hciNormal[kMAX_IDTOOLS];   // CIconHandle
   NSButton    *imbNormal[kMAX_IDTOOLS];
   // NSImage     *hciHigh[kMAX_IDTOOLS];      // CIconHandle
   // NSImage     *hciDisabled[kMAX_IDTOOLS];  // CIconHandle
   
   Rect         popUpRect;
   
   NSPopUpButton  *popUpHandle;
   
} IDToolbarRecord, *IDToolbarPtr, **IDToolbarHandle;

typedef struct _IDStatusbar  {
   short        sbItems;   // should be 2 at the time
   
   /*unsigned
    long        sbPrimaryTimeStamp;
   unsigned
    long        sbSecondaryTimeStamp;*/
   
   char         sbPrimaryMsg[256];
   char         sbSecondaryMsg[256];
   char         sbTernaryMsg[256];
   char         sbCharCountMsg[16];
   
} IDStatusbarRecord, *IDStatusbarPtr, **IDStatusbarHandle;
