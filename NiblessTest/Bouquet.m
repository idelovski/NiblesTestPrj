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
