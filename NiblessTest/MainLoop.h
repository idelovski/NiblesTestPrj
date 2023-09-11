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

void  id_SysBeep (short numb);

NSWindow  *FrontWindow (void);
FORM_REC  *id_FindForm (NSWindow *nsWindow);
FORM_REC  *id_init_form (FORM_REC *form);

int   id_release_form (FORM_REC *form);

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

#if __MAC_OS_X_VERSION_MAX_ALLOWED > 1090
void  SetRect (Rect *rect, short l, short t, short r, short b);
void  InsetRect (Rect *rect, short h, short v);
#endif

int  TExMeasureText (char *cStr, long len, short *txtWidth, short *txtHeight);
int  TExSetAlignment (NSTextField *theCtl, short teJust);

int  id_TextWidth (FORM_REC *form, char *txtPtr, short startOffset, short len);


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

void id_GetClientRect (FORM_REC *form, Rect *rect);
void id_get_form_rect (Rect *rect, FORM_REC *form, short clientFlag);
int  id_get_fld_rect (FORM_REC *form, short fldno, Rect *fldRect);

Boolean  id_isHighField (FORM_REC *form, short fldno);

int  id_inpossible_item (FORM_REC *form, short index);

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
int  id_frame_fields (FORM_REC *form, NSControl *fldno_1, NSControl *fldno_2, short distance, PatPtr frPatPtr);

int  id_AdjustScaledRight (FORM_REC *form, short index, Rect *fldRect);
int  id_AdjustScaledBottom (FORM_REC *form, short index, Rect *fldRect);
int  id_AdjustScaledPictBottom (FORM_REC *form, short index, Rect *fldRect);

int  id_frame_editText (FORM_REC *form, short index);


CGContextRef  id_createPDFContext (CGRect pdfFrame, CFMutableDataRef *pdfData);

#define  kSBAR_BACKGROUND 701
#define  kSBAR_SEPARATOR  702

#define  kSBAR_HEIGHT      16
#define  kSBAR_ICN_WIDTH   64
#define  kSBAR_SEP_WIDTH   12

int   id_GetPictRect (PicHandle picHandle, Rect *picRect);

PicHandle  id_GetPicture (FORM_REC *form, short picID);

int   id_DrawPicture (FORM_REC *form, PicHandle picHandle, Rect *picRect);
void  id_ReleasePicture (PicHandle picHandle);
void  id_draw_Picture (FORM_REC *form, short index);

RgnHandle  id_ClipRect (FORM_REC *form, Rect *clipRect);
int        id_RestoreClip (FORM_REC *form, RgnHandle savedClipRgn);

int  id_DrawStatusbar (FORM_REC *form, short drawNow);

void id_create_toolbar (FORM_REC *form);
int  id_DrawIconToolbar (FORM_REC *form);
int  id_DrawTBPadding (FORM_REC *form);

#define K_PICT_UP       1
#define K_PICT_MID      2  // till 22
#define K_PICT_DN      23

#define  K_KUPDOB      25
#define  K_KUPDOB_CD   27

#define  K_ADRESA_1   29
#define  K_ADRESA_2   30
#define  K_ADRESA_3   31
#define  K_ADRESA_4   32
#define  K_TEL_1      34
#define  K_TEL_2      36
#define  K_TEL_3      38
#define  K_FAX        41


#ifdef _MAIN_LOOP_SRC_

EDIT_item  kupdob_edit_items[] = {
 { K_PICT_UP,   ID_UT_PICTURE, 0, 0, 603, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+1,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+2,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+3,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+4,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+5,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+6,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+7,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+8,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+9,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+10,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+11,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+12,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+13,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+14,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+15,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+16,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+17,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+18,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+19,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID+20,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_DN,   ID_UT_PICTURE, 0, 0, 604, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_KUPDOB,    0, 40, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER | ID_FE_DATA_REQ,
                NULL, NULL, NULL,
                NULL, NULL /*attach_kd_kupdob, finda_kd_kupdob*/ },

 { K_KUPDOB_CD, 0, 5, 0, 0, 0, teJustLeft, ID_FE_DIGITS | ID_FE_OUTGRAY | ID_FE_LINE_UNDER | ID_FE_DATA_REQ,
                NULL, NULL, NULL,
                NULL, NULL /*generate_kupdob_cd, generate_kupdob_cd*/ },

 { K_ADRESA_1,  0, 31, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                NULL/*attach_kd_addresa_1*/, NULL },

 { K_ADRESA_2,  0, 40, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_ADRESA_3,  0, 40, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_ADRESA_4,  0, 40, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                NULL, NULL/*attach_kd_addresa_3*/ },

 { K_TEL_1,     0, 17, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_TEL_2,     0, 17, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                NULL, NULL },


 { K_TEL_3,     0, 17, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_FAX,       0, 17, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                NULL, NULL },

#ifdef _NIJE_
 { K_DRZAVA,    0, 24, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                attach_kd_drzava, attach_kd_drzava },

 { K_LABEL,     0, 19, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_CAT_INFO,  0, 1, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER | ID_FE_TOUPPER,
                "AGINPR", NULL, "Nepovezano ili A - naπa Adresa, G - Grupacija, I - sudjelujuÊi Interesi, P - Poslovnica, R - Recurring",
                NULL, NULL },

 { K_ZIRO,      0, 28, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER | ID_FE_TOUPPER,
                NULL, NULL, NULL,
                NULL, attach_kd_ziro },

 { K_STAT_9_L,  0, 31, 0, 0, 0, teJustLeft, 0,
                NULL, NULL, NULL, 
                NULL, NULL },   

 { K_PNBR_0,    0, 2, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER | ID_FE_DIGITS,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_POZIV,     0, 24, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_MAT_BROJ,  0, 13, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                NULL, attach_kd_mat_broj },

 { K_OIB,       0, 11, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, "OIB, obavezni podatak za sve pravne subjekte",
                NULL, attach_kd_oib },

 { K_PDV_BROJ,  0, 16, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, "PDV broj inozemnih poslovnih subjekata, vaæan podatak za EU partnere",
                NULL, attach_kd_pdv_broj },

 { K_STAT_9_R,  0, 31, 0, 0, 0, teJustRight, 0,
                NULL, NULL, NULL, 
                NULL, NULL },   

 { K_KTO_12x,   0, 4, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER | ID_FE_DIGITS,
                NULL, NULL, "Konto kupca, domaÊi ili inozemni",
                attach_kd_konto, attach_kd_konto },

 { K_12x_CHECK, ID_UT_CICN, 0, 516, 516, 516, 0, 0,
                NULL, NULL, NULL, 
                NULL, NULL },

 { K_KTO_22x,   0, 4, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER | ID_FE_DIGITS,
                NULL, NULL, "Konto dobavljaËa, domaÊi ili inozemni",
                attach_kd_konto, attach_kd_konto },

 { K_22x_CHECK, ID_UT_CICN, 0, 516, 516, 516, 0, 0,
                NULL, NULL, NULL, 
                NULL, NULL },

 { K_PLS_KONTO, 0, 4, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                attach_kd_konto, attach_kd_konto },

 { K_PLS_CHECK, ID_UT_CICN, 0, 516, 516, 516, 0, 0,
                NULL, NULL, NULL, 
                NULL, NULL },

 { K_OSOBA,     0, 23, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_MOBITEL,   0, 17, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_E_MAIL,    0, 47, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL, 
                NULL, NULL },   

 { K_URL,       0, 31, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL, 
                NULL, NULL },
             
 { K_NAPOMENA,  0, 63, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_HOLDING_CD, 0, 5, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER | ID_FE_DIGITS | ID_FE_LETTERS,
                NULL, NULL, NULL,
                NULL, attach_k_holding, finda_k_holding },

 { K_HOLDING,   0, 23, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER | ID_FE_PROTECT | ID_FE_SKIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_STD_RBT_P, 0, 4, 1, 0, 0, teJustRight, ID_FE_OUTGRAY | ID_FE_LINE_UNDER | ID_FE_NUMERIC,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_STD_ROK,   0, 3, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER | ID_FE_DIGITS,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_LINK_TXT,  0, 240, 0, 0, 0, teJustLeft, 0,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_S_VISITORS, 0, 240, 0, 0, 0, teJustLeft, 0,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_I_CHAIN,   ID_UT_ICON_ITEM, 0, 145, 146, 147, 0, ID_FE_DOWN_ONLY,
                NULL, NULL, NULL, 
                NULL, NULL },

 { K_I_INFO,    ID_UT_ICON_ITEM, 0, 305, 306, 307, 0, ID_FE_UP_ONLY,
                NULL, NULL, NULL, 
                NULL, NULL },
          
 { K_INFO_BOX,  0, 240, 0, 0, 0, teJustRight, 0,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_12x_POP,   ID_UT_POP_UP, 0, 0, 2, 0, teJustLeft, 0,  // Regular popUps
                "Reg", NULL, NULL,
                attach_kd_12x_pop, attach_kd_12x_pop },

 { K_22x_POP,   ID_UT_POP_UP, 0, 0, 2, 0, teJustLeft, 0,
                "Reg", NULL, NULL,
                attach_kd_22x_pop, attach_kd_22x_pop },

 { K_PLS_POP,   ID_UT_POP_UP, 0, 0, 2, 0, teJustLeft, 0,
                "Reg", NULL, NULL,
                attach_kd_pls_pop, attach_kd_pls_pop },

 { K_R1R2_POP,   ID_UT_POP_UP, 0, 0, 4, 0, teJustLeft, 0,
                NULL, NULL, NULL,
                attach_pr_r1r2_pop, attach_pr_r1r2_pop },

 { K_SMALL_9,   0, 31, 0, 0, 0, teJustCenter, 0,
                NULL, NULL, NULL, 
                NULL, NULL },   

 { K_TXT_12x,   0, 3, 0, 0, 0, teJustRight, 0,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_STICKY,    0, 127, 0, 0, 0, teJustLeft, 0,
                NULL, NULL, NULL, 
                NULL, NULL },   

 { K_IBAN,      0, 35, 0, 0, 0, teJustLeft, 0,
                NULL, NULL, NULL, 
                NULL, NULL },
#endif

 { 0,           0 } 
};
#endif

