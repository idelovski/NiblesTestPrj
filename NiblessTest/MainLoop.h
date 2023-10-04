//
//  MainLoop.h
//  NiblessTest
//
//  Created by me on 16.07.23.
//  Copyright 2023 Delovski d.o.o. All rights reserved.
//

// #import <Cocoa/Cocoa.h>
#import  <Carbon/Carbon.h>
#import  <AppKit/AppKit.h>

#include  <sys/types.h>
#include  <sys/stat.h>

#import  "NSFont+CFTraits.h"

// #import <CarbonCore/CarbonCore.h>

#import  "transitionHeader.h"

@class  NiblessTestAppDelegate;

@interface MainLoop : NSObject
{
}

+ (void)handleApplicationDidFinishLaunchingWithAppDelegate:(NiblessTestAppDelegate *)appDelegate;
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

void  id_SysBeep (short numb);

NSWindow  *FrontWindow (void);
void       SelectWindow (NSWindow *win);
void       SendBehind (NSWindow *ourWin, NSWindow *otherWin);

void  id_printWindowsOrder (void);  // Stupid utility f()

FORM_REC  *id_FindForm (NSWindow *nsWindow);
FORM_REC  *id_init_form (FORM_REC *form);

int   id_release_form (FORM_REC *form);

char *strNCpy (char *s1, const char *s2, long n);

int  stricmp (char *s1, char *s2);
int  strnicmp (char *s1, char *s2, short n);

int  id_isCroAlpha (char ch, short spaceIsAlpha);

void   id_ConvertTextTo1250 (char *sText, short *len, short expandNewLines);
void   id_ConvertTextTo1250L (char *sText, long *len, short expandNewLines);  // expands \r
void   id_Convert1250ToText (char *sText, short *len, short expandNewLines);  // shrinks \r\n

// Ha, ha, who wrote these functions? Total mess with similar stuff
OSErr     id_GetParentFSRef (const FSRef *fileFSRef, FSRef *parentFSRef);
OSStatus  id_GetFilesFSRef (const FSRef *parentFSRef, char *fileName, FSRef *fsRef);
int       id_ExtractFSRef (FSRef *srcFSref, char *fileName, FSRef *parentFSRef);

int   id_GetApplicationExeFSRef (FSRef *appParentFolderFSRef);  // out, exe folder
int   id_GetApplicationParentFSRef (FSRef *appParentFolderFSRef);  // out, bundle folder
int   id_GetMyApplicationResourcesFSRef (FSRef *rsrcFolderFSRef);  // put them into dTOOL_INT.C, add these fsRefs to dtGlobals!

int  id_GetDefaultDir (FSRef *fsRef); // out
int  id_SetDefaultDir (FSRef *fsRef);  // in
int  id_GetDesktopDir (FSRef *desktopFSRef); // out, Desktop folder
int  id_GetDocumentsDir (FSRef *desktopFSRef); // out, Desktop folder
int  id_GetDefaultDir (FSRef *fsRef); // out
int  id_SetDefaultDir (FSRef *fsRef);  // in

short  OpenResFile (char *resFileName);  // c string

int  id_GetApplicationDataDir (FSRef *appDataFSRef); // out, appData folder, there is id_GetAppDataVolume()
int  id_SetInitialDefaultDir (FSRef *appFolderFSRef); // out, applications folder inside the bundle

int   id_BreakFullPath (char  *fullPath,     // in
                        char  *driveLetter,  // out, no op on Mac
                        char  *purePath,     // out, contains driveLetter
                        char  *fileName,     // out, with or without extension
                        char  *fileExtension // out, optional
                        );
int  id_ConcatPath (char *fullPath, char *morePath);
int  id_CoreConcatPath (char *fullPath, char *morePath, short webFlag);
int  id_NavGetFile (NSArray *allowedTypes, char *fileName, FSRef *parentFSRef, Boolean *aliasFlag);
int  id_CreateAliasToPath (char *cTargetFolderPath, char *cParentFolderPath, char *cFileName, OSType fileType);

int  id_UniCharToUpper (UniChar *uch);
int  id_CharToUniChar (char ch, UniChar *uch);
int  id_UniCharToChar (UniChar uch, char *ch);

char        *id_CFString2Mac (const CFStringRef srcStr, char *dstStr, short *strLen);
CFStringRef  id_Mac2CFString (const char *srcStr, CFStringRef *dstStr, long strLen);
CFStringRef  id_CreateCFString (const char *srcStr);

OSStatus  id_FSDeleteFile (FSRef *parentFSRef, char *fileName);  // fileName may be NULL
OSStatus  id_FSRenameFile (FSRef *theFileRef, char *newFileName);

int  id_InitComputerName (char *compName, short buffSize);
int  id_InitComputerUserName (char *userName, short buffSize);

void  TestVersion (void);
void  pr_ListFonts (void);
void  pr_ListEncodings (void);

#if __MAC_OS_X_VERSION_MAX_ALLOWED > 1090
enum {
   systemFont                    = 0,
   applFont                      = 1
};

void  SetRect (Rect *rect, short l, short t, short r, short b);
void  OffsetRect (Rect *rect, short h, short v);
void  InsetRect (Rect *rect, short h, short v);
void  UnionRect (Rect *rect1, Rect *rect2, Rect *targetRect);
void  SetPt (Point *pt, short h, short v);

Boolean  PtInRect (Point pt, const Rect *r);

#endif

int  TExSetText (NSTextField *theCtl, char *theText, short txLen);
int  TExGetText (NSTextField *theCtl, char *theText, short *maxLen);  // maxLen is in & out
int  TExGetTextLen (NSTextField *theCtl);

int  TExMeasureText (char *cStr, long len, short *txtWidth, short *txtHeight);
void TExTextBox (char *str, long len, Rect *txtRect, short teJust, short teWrap, short eraseBackground);
int  TExSetAlignment (NSTextField *theCtl, short teJust);

int  TExSetSelection (NSTextField *theCtl, short selStart, short selEnd);
int  TExGetSelection (NSTextField *theCtl, short *selStart, short *selEnd);

int  TExIdle (WindowPtr windowPtr, NSTextField *editInput);
int  TExActivate (NSWindow *aWindow, NSTextField *editInput);
int  TExDeactivate (NSWindow *aWindow, NSTextField *editInput);
int  TExUpdate (NSTextField  *editInput, Rect *fldRect);
int  TExClick (Point myPt, UInt16 evtModifiers, EventRecord *evtPtr, NSTextField *editInput);

int  id_put_TE_str (FORM_REC *form, short index);
int  id_get_TE_str (FORM_REC *form, short index);

NSTextAlignment  TExAlignment (short teJust);

int  id_TextWidth (FORM_REC *form, char *txtPtr, short startOffset, short len);

int  id_check_chr_edit_char (FORM_REC *form, short index, char ch);
int  id_check_chr_edit_size (FORM_REC *form, short index, short newSize);

int  id_TE_change (FORM_REC *form, short index, FontInfo *fntInfo, WindowPtr savedPort, short sel, short mouseFlag);
void id_post_TE_change (FORM_REC *form, short index);

int  id_gofield (FORM_REC *form, short fldno, short sel);

int  id_find_next_fld (FORM_REC *form);
int  id_find_prev_fld (FORM_REC *form);

int  GetFontNum (char *fontName, short *fontNum);
int  GetFontName (short fontNum, char *fontName, short maxLen);

NSFont  *id_GetFont (short txtFont, short txtSize, short txtFace);
int      id_SetFont (FORM_REC *form, short index, short txtFont, short txtSize, short txtFace);

void  id_SetUpLayout (ID_LAYOUT *theLayout, short oFont, short oSize, short oFace);
void  id_SetLayout (FORM_REC *form, short index, ID_LAYOUT *theLayout);

void  id_set_edit_layout (FORM_REC *form, short index);
void  id_my_edit_layout (FORM_REC *form, short index);
void  id_set_stat_layout (FORM_REC *form, short index);
void  id_my_stat_layout (FORM_REC *form, short index);
void  id_set_comment_layout (FORM_REC *form);
void  id_set_list_layout (FORM_REC *form, short index);
void  id_my_list_layout (FORM_REC *form, short index);
void  id_my_popUp_layout (FORM_REC *form, short index);
void  id_set_system_layout (FORM_REC *form, short index);

void   id_pen_down  (FORM_REC *, short);
void   id_pen_up  (FORM_REC *);
int    id_get_pen  (FORM_REC *, short);
int    id_set_pen  (FORM_REC *, short, short);

#define  HiWord(x) ((short)((long)(x) >> 16))
#define  LoWord(x) ((short)(x))

#define  MakeLong(a, b) ((SInt32) (((short) (a)) | ((UInt32) ((short) (b))) << 16))

CGRect  id_CocoaRect (NSWindow *window, CGRect nmlRect);
CGRect  id_CarbonRect (CGRect cocoaRect);

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
void   id_attach_EDIT_info (FORM_REC *form, EDIT_item *edit_array, short last_fldno, short skipOthers);

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

#define  RectWidth(rc)                    ((rc)->right-(rc)->left)
#define  RectHeight(rc)                   ((rc)->bottom-(rc)->top)

#define   IS_LEAP_YEAR(yr)   (!((yr)%4) && (yr)%100 || !((yr)%400))

unsigned short  id_sys_date (void);

void  GetTime (DateTimeRec *dtRec);
void  GetDateTime (unsigned long *secs);
void  SecondsToDate (unsigned long secs, DateTimeRec *dtRec);
void  DateToSeconds (const DateTimeRec *dtRec, unsigned long *secs);


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

CGRect  id_Rect2CGRect (Rect *rect);
Rect   *id_CGRect2Rect (CGRect cgRect, Rect *rect);

CGColorRef  QD_DarkGray (void);
CGColorRef  QD_LightGray (void);
CGColorRef  QD_Gray (void);
CGColorRef  QD_Black (void);
CGColorRef  QD_White (void);

int   id_GetCursor (void);
void  id_SetCursor (FORM_REC *form, short cursID);

void id_GetClientRect (FORM_REC *form, Rect *rect);
void id_get_form_rect (Rect *rect, FORM_REC *form, short clientFlag);
int  id_get_fld_rect (FORM_REC *form, short fldno, Rect *fldRect);

Boolean  id_isHighField (FORM_REC *form, short fldno);

int  id_inpossible_item (FORM_REC *form, short index);
int  id_move_field (FORM_REC *form, short fldno, short dh, short dv);

#define  MulDiv(val,numerator,denominator)  ((int)((double)val*numerator/denominator))

Rect  *GetWindowRect (WindowPtr win, Rect *rect);  // my own shit!

void  id_WinRect2FormRectEx (FORM_REC *form, Rect *winRect, Rect *formRect, short scaleRatio);
void  id_WinRect2FormRect (FORM_REC *form, Rect *winRect, Rect *formRect);
void  id_FormRect2WinRectEx (FORM_REC *form, Rect *formRect, Rect *winRect, short scaleratio);
void  id_FormRect2WinRect (FORM_REC *form, Rect *formRect, Rect *winRect);

void id_MulDivRect (Rect *theRect, int mul, int div);
void id_CopyMac2Rect (FORM_REC *form, Rect *dstRect, MacRect *srcRect);
int  id_itemsRect (FORM_REC *form, short index, Rect *fldRect);
int  id_controlsRect (FORM_REC *form, NSControl *field, Rect *fldRect);
int  id_frame_fields (FORM_REC *form, NSControl *fldno_1, NSControl *fldno_2, short distance, CGColorRef frPatPtr);

int  id_AdjustScaledRight (FORM_REC *form, short index, Rect *fldRect);
int  id_AdjustScaledBottom (FORM_REC *form, short index, Rect *fldRect);
int  id_AdjustScaledPictBottom (FORM_REC *form, short index, Rect *fldRect);

int  id_frame_editText (FORM_REC *form, short index);

int  id_title_bounds (FORM_REC *form, short fldno_1, short fldno_2, CGColorRef frPatPtr, char *title_str, ID_LAYOUT *specLayout);

void     id_set_field_buffer_text (FORM_REC *form, short fldno, char *text, short txtLen);
char    *id_field_text_buffer (FORM_REC *form, short fldno);
int      id_field_text_length (FORM_REC *form, short fldno);
Boolean  id_field_empty (FORM_REC *form, short fldno);

int  id_set_field_layout (FORM_REC *form, short index, ID_LAYOUT *theLayout);
void id_same_edit_type (FORM_REC *, short, short);

int  id_disable_field (FORM_REC *form, short fldno);
int  id_enable_field (FORM_REC *form, short fldno);

Boolean  id_field_enabled (FORM_REC *form, short fldno);

void  id_redraw_field (FORM_REC *form, short fldno);
void _id_redraw_field (FORM_REC *form, Rect *fldRect, DITL_item *fDitl_def, EDIT_item *fEdit_def);
int   id_base_fldno (FORM_REC *form, short fldno, short *offset);

int   id_check_entry (FORM_REC *form, short index, WindowPtr savedPort);
int   id_check_exit (FORM_REC *form, short index, WindowPtr savedPort);

CGContextRef  id_createPDFContext (CGRect pdfFrame, CFMutableDataRef *pdfData);

#define  kSBAR_BACKGROUND 701
#define  kSBAR_SEPARATOR  702

#define  kSBAR_HEIGHT      16
#define  kSBAR_ICN_WIDTH   64
#define  kSBAR_SEP_WIDTH   12

NSImage  *id_GetIcon (short rsrc_id);
NSImage  *id_GetCIcon (short rsrc_id);

void  id_PlotIcon (Rect *macRect, NSImage *iconImage);
void  id_PlotCIcon (Rect *macRect, NSImage *iconImage);


int   id_GetPictRect (PicHandle picHandle, Rect *picRect);

PicHandle  id_GetPicture (FORM_REC *form, short picID);

int   id_DrawPicture (FORM_REC *form, PicHandle picHandle, Rect *picRect);
void  id_ReleasePicture (PicHandle picHandle);
void  id_draw_Picture (FORM_REC *form, short index);
void  id_create_iconItem (FORM_REC *form, short index, WindowPtr savedPort);

void  id_resetPopUpMenu (FORM_REC *form, short index);

RgnHandle  id_ClipRect (FORM_REC *form, Rect *clipRect);
int        id_RestoreClip (FORM_REC *form, RgnHandle savedClipRgn);

int  id_DrawStatusbar (FORM_REC *form, short drawNow);
void id_RedrawStatusbar (FORM_REC *form);
int  id_SetStatusbarText (FORM_REC *form, short statPart, char *statText);

int  id_show_comment (FORM_REC *form, short index, short mode);

void id_create_toolbar (FORM_REC *form);
int  id_DrawIconToolbar (FORM_REC *form);
int  id_DrawTBPadding (FORM_REC *form);


