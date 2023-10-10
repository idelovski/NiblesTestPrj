//
//  DTTableViewController.h
//  NiblessTest
//
//  Created by me on Thu Oct 05 2023.
//  Copyright (c) 2023 Delovski d.o.o. All rights reserved.
//

#import  <Foundation/Foundation.h>
#import  <Cocoa/Cocoa.h>

#import  "transitionHeader.h"

@interface DTTableViewController : NSObject <NSTableViewDataSource, NSTableViewDelegate>
{
   FORM_REC  *form;
}

- (id)initWithForm:(FORM_REC *)aForm;

@end

int  id_numberOfRowsInTableView (FORM_REC *form);
int  id_numberOfColumnsInTableView (FORM_REC *form, short *firstIdx, short *lastIdx);

int  id_columnInTableViewForFormField (FORM_REC *form, short fldno);
