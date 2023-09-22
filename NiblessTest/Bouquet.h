//
//  Bouquet.h
//  NiblessTest
//
//  Created by me on 20.09.23.
//  Copyright 2023 Delovski d.o.o. All rights reserved.
//

// #import <Cocoa/Cocoa.h>
#import  <Carbon/Carbon.h>
#import  <AppKit/AppKit.h>

#import  "transitionHeader.h"

#define K_PICT_UP       1
#define K_PICT_MID      2  // till 22
#define K_PICT_DN      23

#define  K_KUPDOB     25
#define  K_KUPDOB_CD  27
#define  K_ADRESA_1   29
#define  K_ADRESA_2   30
#define  K_ADRESA_3   31
#define  K_ADRESA_4   32
#define  K_TEL_1      34
#define  K_TEL_2      36
#define  K_TEL_3      38
#define  K_FAX        41

#define  K_DRZAVA     43
#define  K_C_EU       44

#define  K_LABEL      46  // 2013
#define  K_CAT_INFO   47  // 2016

#define  K_ZIRO       49
#define  K_STAT_9_L   50  // used a lot later
#define  K_PNBR_0     51
#define  K_POZIV      52

#define  K_MAT_BROJ   54
#define  K_OIB        56  // 07/2009
#define  K_PDV_BROJ   58  // 07/2013

#define  K_STAT_9_R   59  // 60

#define  K_KTO_12x    60
#define  K_12x_CHECK  61
#define  K_KTO_22x    63
#define  K_22x_CHECK  64
#define  K_PLS_KONTO  66
#define  K_PLS_CHECK  67

#define  K_OSOBA      69
#define  K_MOBITEL    71
#define  K_E_MAIL     73
#define  K_URL        75

#define  K_NAPOMENA   77

#define  K_HOLDING_CD 79
#define  K_HOLDING    80
#define  K_STD_RBT_P  82
#define  K_STD_ROK    84

#define  K_LINK_TXT   86
#define  K_STICKY_CHK 87  // !
#define  K_S_VISITORS 88  // +

#define  K_I_CHAIN   89
#define  K_I_INFO    90

#define  K_INFO_BOX  91

#define  K_12x_POP   92
#define  K_22x_POP   93
#define  K_PLS_POP   94
#define  K_R1R2_POP  95

#define  K_SMALL_9   96  // 96

#define  K_B_OK      98
#define  K_B_CANCEL  99

#define K_UF_MODULE 100
#define K_UF_TIP    101
#define K_UF_BR     102
#define K_KL_MODULE 103
#define K_KL_TIP    104
#define K_KL_BR     105
#define K_PO_MODULE 106
#define K_PO_TIP    107
#define K_PO_BR     108

#define K_PF_MODULE 109
#define K_PF_TIP    110
#define K_PF_BR     111
#define K_IF_MODULE 112
#define K_IF_TIP    113
#define K_IF_BR     114
#define K_IA_MODULE 115
#define K_IA_TIP    116
#define K_IA_BR     117

#define K_DP_MODULE 118
#define K_DP_TIP    119
#define K_DP_BR     120
#define K_RV_MODULE 121
#define K_RV_TIP    122
#define K_RV_BR     123

#define K_TXT_12x   124
#define K_TXT_22x   125

#define K_C_STICKY    126
#define K_STICKY      127
#define K_C_SKIP_INFO 128

#define K_STORE_DATE  129  // Store open date
#define K_OPCINA_CD   130
#define K_IBAN        131

#define K_C_CIJ_PF    132
#define K_R_CIJ_PF    133  // prefak
#define K_R_CIJ_ZO    134  // zorder

#define K_DISTANCE_KM 135

#define K_C_SKIP_EXP  136
#define K_C_SKIP_IMP  137

#define  K_LAST_ELEM  K_C_SKIP_IMP


int  attach_kd_kupdob (FORM_REC *form, int fldno, int offset, int mode);
int  attach_kd_12x_pop (FORM_REC *form, int fldno, int offset, int mode);
int  attach_kd_22x_pop (FORM_REC *form, int fldno, int offset, int mode);
int  attach_pr_r1r2_pop (FORM_REC *form, int fldno, int offset, int mode);


void pr_OpenKupdob (void);
int  pr_OnUpdateKupdob (FORM_REC *form, EventRecord *uEvent, short when, short msg);
