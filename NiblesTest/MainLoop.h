//
//  MainLoop.h
//  GeneralCocoaProject
//
//  Created by me on 16.07.23.
//  Copyright 2023 Delovski d.o.o. All rights reserved.
//

// #import <Cocoa/Cocoa.h>
#import  <Carbon/Carbon.h>
#import  <AppKit/AppKit.h>

#import  "NSFont+CFTraits.h"

// #import <CarbonCore/CarbonCore.h>

#import "transitionHeader.h"

@interface MainLoop : NSObject
{
}

+ (NSWindow *)openInitialWindowAsForm:(FORM_REC *)form;
+ (void)finalizeFormWindow:(FORM_REC *)form;

+ (void)menuAction:(id)sender;

+ (void)buildMainMenu;
+ (NSMenuItem *)findMenuItem:(NSInteger)itemsMenuIndex withTag:(NSInteger)itemsTag;

+ (BOOL)drawImage:(NSImage *)image
          inFrame:(CGRect)imgFrame
             form:(FORM_REC *)form;

+ (void)resizeControl:(NSControl *)aControl
               inForm:(FORM_REC *)form
           toNewRatio:(short)ratio;

@end

BOOL  id_MainLoop (FORM_REC *form);

int   id_InitDTool (short idApple, short idFile, short idEdit, int (*errLogSaver) (char *, char *, char, char));

NSWindow  *FrontWindow (void);
FORM_REC  *id_FindForm (NSWindow *nsWindow);
FORM_REC  *id_init_form (FORM_REC *form);

char *strNCpy (char *s1, const char *s2, long n);

OSErr id_GetParentFSRef (const FSRef *fileFSRef, FSRef *parentFSRef);

int   id_GetApplicationExeFSRef (FSRef *appParentFolderFSRef);  // out, exe folder
int   id_GetApplicationParentFSRef (FSRef *appParentFolderFSRef);  // out, bundle folder
int   id_GetMyApplicationResourcesFSRef (FSRef *rsrcFolderFSRef);  // put them into dTOOL_INT.C, add these fsRefs to dtGlobals!

int   id_GetDefaultDir (FSRef *fsRef); // out
int   id_SetDefaultDir (FSRef *fsRef);  // in

short  OpenResFile (char *resFileName);  // c string

int   id_ExtractFSRef (FSRef *srcFSref, char *fileName, FSRef *parentFSRef);

OSStatus  id_GetFilesFSRef (const FSRef *parentFSRef, char *fileName, FSRef *fsRef);

int  id_GetDefaultDir (FSRef *fsRef); // out
int  id_SetDefaultDir (FSRef *fsRef);  // in

int  id_GetApplicationDataDir (FSRef *appDataFSRef); // out, appData folder, there is id_GetAppDataVolume()
int  id_SetInitialDefaultDir (FSRef *appFolderFSRef); // out, applications folder inside the bundle

int  id_UniCharToUpper (UniChar *uch);
int  id_CharToUniChar (char ch, UniChar *uch);
int  id_UniCharToChar (UniChar uch, char *ch);

char        *id_CFString2Mac (const CFStringRef srcStr, char *dstStr, short *strLen);
CFStringRef  id_Mac2CFString (const char *srcStr, CFStringRef *dstStr, long strLen);

OSStatus  id_FSDeleteFile (FSRef *parentFSRef, char *fileName);  // fileName may be NULL
OSStatus  id_FSRenameFile (FSRef *theFileRef, char *newFileName);

int  id_InitComputerName (char *compName, short buffSize);
int  id_InitComputerUserName (char *userName, short buffSize);

void  TestVersion (void);
void  pr_ListFonts (void);
void  pr_ListEncodings (void);

CGRect  id_CocoaRect (NSWindow *window, CGRect nmlRect);

#pragma mark printing

typedef struct  {
    GrafPtr      savedPort;
    SInt32       lastTick;

    short        border_dist;
    short        line_height;
    
    short        verStart;
    short        horStart;
    
    short        prn_font;
    short        prn_size;
    Style        prn_style;

    short        prFirstPageNo;
    short        prLastPageNo;
    short        prMode;   /* BitField types defined below */
    Byte         normalHeight;
    Byte         savyHeight;
    
    short        prDITL;
    
    Handle       DITL_handle;   /* Resorce DITL handle */
                                /* All time on Mac, on Win it is released in OpenDITL() */    
    Handle       hSubDITL;
    short        last_fldno, lastSubFldno;
    short          headPrinted;
    short          footPrinted;
    
   short           exVRefNum;      /* Export data */
   char            exPresetFNameStr[64];
   char            exFNameStr[64];
   short           exFRef;
   
   short           exCurExcelRow;
   short           exCurExcelCol;
   char            exExcelFullpath[256];
#ifdef _EXCEL_   
   lxw_workbook   *lxwWorkbook;
   lxw_worksheet  *lxwWorksheet;
#else
   void           *lxwWorkbook;
   void           *lxwWorksheet;
#endif
   UInt32            exBytesDone;
    
   Rect         exOldRect;
   Byte         exWaitingRect;
   Byte         exFlagCSV;      // '\t' or ','
   Byte         exSemiCSV;      // Use ';' instead
   Byte         exFlagQuote;    // Use '"' arround long numbers
   
   short        curResRef;
   short        altResRef;
   
   short        ctrlFldno;
   short        useWidePrnType;
   SInt32         ctrlTick;
   char         ctrlText[128];
   
   Byte         forcePreView;
   Byte         usePrnBreak;
   Byte         useTimeStamp;
   Byte         useUtf8Export;
   
   Byte         pageClosed;   // was global gGPageClosed
   
   PMPrintSession   printSession;
   PMPageFormat     pageFormat;
   PMPageFormat     pageFormatPortrait;
   PMPageFormat     pageFormatLandscape;
   PMPageFormat     pageFormatPOS;
   PMPrintSettings  printSettings;
   GrafPtr          myPrPort;
   
   void           *embededFB;
   void           *embededForm;
   short           embededPageNo;
   
   char            pdfFileName[64];
   short           pdfVRefNum;
   short           noPrintDialog;
   char            posPrinterID[64];
   char            savedPrinterId[64];
   char            posPaperID[64];

}  ID_PR_DATA;

#pragma mark -

void   id_copy_DITL_info (DITL_item **ditl_def, Handle ditl_handle);

void  *id_calloc (size_t count, size_t size);
char **id_malloc_array (size_t n, size_t s);
void   id_clear_array (char **aPtr, size_t n, size_t s);
void   id_copy_array (char **tarPtr, char **srcPtr, size_t n, size_t s);
int    id_add_unique_array_elem (char **aPtr, size_t n, char *newItem, size_t sz);
int    id_sort_array_elems (char **aPtr, size_t n);
size_t id_array_used_count (char **aPtr, size_t n);

void   id_free_array (char **aPtr);

#pragma mark -

#pragma mark Date & Time

#define  _DDMMYY       1
#define  _DD_MM_YY     2
#define  _DD_MM_YY_    3
#define  _DD_MM        4
#define  _DD_MM_       5
#define  _YY           6
#define  _TEXT_DATE    7
#define  _MM_YY        8
#define  _MM           9
#define  _DD          10
#define  _DD_MM_YYYY  11
#define  _MMYY        12
#define  _YYYY        13
#define  _DDMMYYYY    14
#define  _DD_MM_YYYY_ 15
#define  _DDsMMsYYYY  16  // with slashes
#define  _YYYYMMDD    17
#define  _YYYY_MM_DD  18

#define  _HHMISS      32
#define  _HH_MI_SS    33
#define  _HH_MI       34
#define  _HHMI        35

#define  kPivotDate   32
#define  kMaxMonths   12


unsigned short  id_sys_date (void);

unsigned short id_secs2Short (unsigned long totalSecs);
unsigned long  id_short2Secs (unsigned short dateShort);

unsigned short id_date2Short (char *dateText, unsigned short *dateShort);

char  *id_Short2DateEx (unsigned short dateShort, char *dateText, Boolean year4Digit);
char  *id_Short2Date (unsigned short dateShort, char *dateText);

char  *id_form_date (unsigned short dateShort, short fmt);

int  id_short2DayOfWeek (unsigned short dateShort);  // 0=mon, 1=tue, ...
int  id_short2Year (unsigned short dateShort);  // full year, like 2008, 2009,...
int  id_short2Month (unsigned short dateShort);  // 1,2,...12, 0 is err

char  *id_monthName (unsigned short idxMonth);  // one based
char  *id_get_month_name (unsigned short dateShort);
char  *id_get_day_name (unsigned short dateShort);

int  id_itemsRect (FORM_REC *form, NSControl *field, Rect *fldRect);
int  id_frame_fields (FORM_REC *form, NSControl *fldno_1, NSControl *fldno_2, short distance, PatPtr frPatPtr);

CGRect  id_Rect2CGRect (Rect *rect);
Rect   *id_CGRect2Rect (CGRect cgRect, Rect *rect);

CGContextRef  id_createPDFContext (CGRect pdfFrame, CFMutableDataRef *pdfData);

#define  kSBAR_BACKGROUND 701
#define  kSBAR_SEPARATOR  702

#define  kSBAR_HEIGHT      16
#define  kSBAR_ICN_WIDTH   64
#define  kSBAR_SEP_WIDTH   12

int  id_DrawStatusbar (FORM_REC *form, short drawNow);

void id_create_toolbar (FORM_REC *form);
int  id_DrawIconToolbar (FORM_REC *form);
int  id_DrawTBPadding (FORM_REC *form);
