//
//  Bouquet.m
//  NiblessTest
//
//  Created by me on 20.09.23.
//  Copyright 2023 Delovski d.o.o. All rights reserved.
//

#define _BOUQUET_SRC_

#import  "Bouquet.h"
#import  "MainLoop.h"
#import  "GetNextEvent.h"
#import  "FirstForm.h"

ID_LAYOUT     gLayGeneva9     = { geneva, 9, 0 };
ID_LAYOUT     gLayGeneva9bold = { geneva, 9, bold };
ID_LAYOUT     gLayGeneva10    = { geneva, 10, 0 };
ID_LAYOUT     gLayGeneva12    = { geneva, 12, 0 };
ID_LAYOUT     gLayMonaco9     = { monaco, 9, 0 };
ID_LAYOUT     gLayMonaco10    = { monaco, 10, 0 };
ID_LAYOUT     gLayTimes9      = { times,  9, 0 };
ID_LAYOUT     gLayTimes10     = { times, 10, 0 };
ID_LAYOUT     gLayTimes10bold = { times, 10, bold };

static FORM_REC  kupdobForm = { 0 };

// --------------------------------

#ifdef _BOUQUET_SRC_

EDIT_item  kupdob_edit_items[] = {
 { K_PICT_UP,   ID_UT_PICTURE, 0, 0, 603, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_MID,  ID_UT_PICTURE, 0, 0, 602, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_PICT_DN,   ID_UT_PICTURE, 0, 0, 604, 0, 0, ID_FE_CLIP,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_KUPDOB,    0, 40, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER | ID_FE_DATA_REQ,
                NULL, NULL, NULL,
                NULL, attach_kd_kupdob/*, finda_kd_kupdob*/ },

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

 { K_DRZAVA,    0, 24, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                NULL/*attach_kd_drzava*/, NULL/*attach_kd_drzava*/ },

 { K_LABEL,     0, 19, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_CAT_INFO,  0, 1, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER | ID_FE_TOUPPER,
                "AGINPR", NULL, "Nepovezano ili A - naπa Adresa, G - Grupacija, I - sudjelujuÊi Interesi, P - Poslovnica, R - Recurring",
                NULL, NULL },

 { K_ZIRO,      0, 28, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER | ID_FE_TOUPPER,
                NULL, NULL, NULL,
                NULL, NULL/*attach_kd_ziro*/ },

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
                NULL, NULL/*attach_kd_mat_broj*/ },

 { K_OIB,       0, 11, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, "OIB, obavezni podatak za sve pravne subjekte",
                NULL, NULL/*attach_kd_oib*/ },

 { K_PDV_BROJ,  0, 16, 0, 0, 0, teJustLeft, ID_FE_OUTGRAY | ID_FE_LINE_UNDER,
                NULL, NULL, "PDV broj inozemnih poslovnih subjekata, vaæan podatak za EU partnere",
                NULL, NULL/*attach_kd_pdv_broj*/ },

#ifdef _NIJE_
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
#endif

 { K_I_CHAIN,   ID_UT_ICON_ITEM, 0, 145, 146, 147, 0, ID_FE_DOWN_ONLY,
                NULL, NULL, NULL, 
                NULL, NULL },

 { K_I_INFO,    ID_UT_ICON_ITEM, 0, 305, 306, 307, 0, ID_FE_UP_ONLY,
                NULL, NULL, NULL, 
                NULL, NULL },
          
#ifdef _NIJE_
 { K_INFO_BOX,  0, 240, 0, 0, 0, teJustRight, 0,
                NULL, NULL, NULL,
                NULL, NULL },
#endif
 { K_12x_POP,   ID_UT_POP_UP, 0, 0, 2, 0, teJustLeft, 0,  // Regular popUps
                "Reg", NULL, NULL,
                attach_kd_12x_pop, attach_kd_12x_pop },

 { K_22x_POP,   ID_UT_POP_UP, 0, 0, 2, 0, teJustLeft, 0,
                "Reg", NULL, NULL,
                attach_kd_22x_pop, attach_kd_22x_pop },
#ifdef _NIJE_
 { K_PLS_POP,   ID_UT_POP_UP, 0, 0, 2, 0, teJustLeft, 0,
                "Reg", NULL, NULL,
                attach_kd_pls_pop, attach_kd_pls_pop },
#endif
 { K_R1R2_POP,   ID_UT_POP_UP, 0, 0, 4, 0, teJustLeft, 0,
                NULL, NULL, NULL,
                attach_pr_r1r2_pop, attach_pr_r1r2_pop },

 { K_SMALL_9,   0, 31, 0, 0, 0, teJustCenter, 0,
                NULL, NULL, NULL, 
                NULL, NULL },   

 { K_TXT_12x,   0, 3, 0, 0, 0, teJustRight, 0,
                NULL, NULL, NULL,
                NULL, NULL },

 { K_TXT_22x,   0, 3, 0, 0, 0, teJustRight, 0,
                NULL, NULL, NULL,
                NULL, NULL },

#ifdef _NIJE_
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


// --------------------------------

static void  pr_kd_SpecEditTypes (FORM_REC *form)
{
   extern ID_LAYOUT  gLayGeneva9bold, gLayGeneva9, /*gLayGeneva10,*/ gLayTimes9, gLayTimes10;
   
   short   i;

   for (i=K_PICT_MID+1; i<K_PICT_DN; i++)
      id_same_edit_type (form, K_PICT_MID, i);

   id_set_field_layout (form, K_STAT_9_L, &gLayGeneva9);
   id_same_edit_type (form, K_STAT_9_L, K_MAT_BROJ-1);
   id_same_edit_type (form, K_STAT_9_L, K_OIB-1);
   id_same_edit_type (form, K_STAT_9_L, K_OSOBA-1);
   id_same_edit_type (form, K_STAT_9_L, K_MOBITEL-1);
   id_same_edit_type (form, K_STAT_9_L, K_E_MAIL-1);
   id_same_edit_type (form, K_STAT_9_L, K_URL-1);
   id_same_edit_type (form, K_STAT_9_L, K_NAPOMENA-1);
   id_same_edit_type (form, K_STAT_9_L, K_HOLDING_CD-1);
   id_same_edit_type (form, K_STAT_9_L, K_STD_RBT_P-1);
   id_same_edit_type (form, K_STAT_9_L, K_STD_ROK-1);

   id_set_field_layout (form, K_STAT_9_R, &gLayGeneva9);
   id_same_edit_type (form, K_STAT_9_R, K_KTO_22x-1);
   id_same_edit_type (form, K_STAT_9_R, K_PLS_KONTO-1);

   id_set_field_layout (form, K_SMALL_9, &gLayTimes9);
   id_same_edit_type (form, K_SMALL_9, K_SMALL_9+1);

   id_set_field_layout (form, K_INFO_BOX, &gLayTimes10);
   id_set_field_layout (form, K_NAPOMENA, &gLayGeneva9);

   id_set_field_layout (form, K_TXT_12x, &gLayGeneva9bold);
   id_same_edit_type (form, K_TXT_12x, K_TXT_22x);
}

int  pr_OnUpdateKupdob (
 FORM_REC    *form,
 EventRecord *uEvent,
 short        when,
 short        msg
)
{
   extern ID_LAYOUT  gLayGeneva9bold, gLayGeneva9, gLayGeneva10, gLayTimes9, gLayTimes10;

   char  tmpStr[256];
   
   if (when == ID_BEGIN_OF_OPEN)  {
      form->popUp_layout = &gLayGeneva9bold;
      form->stat_layout  = &gLayGeneva10;
      
      // form->hover_check_func = pr_hoverCheckKupdob;

      pr_kd_SpecEditTypes (form);
   }
   else  if (when == ID_BEGIN_OF_UPDATE)  {
      id_FrameCard (form, 12);
   }
   else  if (when == ID_END_OF_UPDATE)  {
      if (form->ditl_def[K_12x_POP-1]->i_rect.top > form->ditl_def[K_I_INFO-1]->i_rect.top)
         id_title_bounds (form, K_I_CHAIN, K_22x_CHECK, QD_Black(), "Konto ako je:", &gLayGeneva9);
      else
         id_title_bounds (form, K_I_CHAIN, K_KTO_22x, QD_Black(), "Konto ako je:", &gLayGeneva9);
   }
   else  if (when == ID_PEN_UP_UPDATE)  {
      /*theFB = id_FBFindByForm (form);*/
      id_enable_field (form, K_KTO_12x);
      id_enable_field (form, K_KTO_22x);
   }
   
   return (0);
}

void  pr_OpenKupdob (void)
{
   Rect  tmpRect;
   
   SetRect (&tmpRect, 32+1, 32+39, 32+484, 32+244+72+64+8+54 /*- 28*/);
   
   if (!kupdobForm.my_window)  {
      id_init_form (&kupdobForm);
      
      kupdobForm.update_func = pr_OnUpdateKupdob;
      
      pr_CreateDitlWindow (&kupdobForm, 601, &tmpRect, "Adresar", &kupdob_edit_items[0]);
      
      id_move_field (&kupdobForm, K_12x_POP, 0, -303);
      id_move_field (&kupdobForm, K_22x_POP, 0, -303);
      
      id_move_field (&kupdobForm, K_TXT_12x, 0,  303);
      id_move_field (&kupdobForm, K_TXT_22x, 0,  303);
      
      id_move_field (&kupdobForm, K_KTO_12x, 24, 0);
      id_move_field (&kupdobForm, K_KTO_22x, 24, 0);
   }
}
