//
//  DTTableViewController.m
//  NiblessTest
//
//  Created by me on Thu Oct 05 2023.
//  Copyright (c) 2023 Delovski d.o.o. All rights reserved.
//

// So this controller is attached to a form and it gets the data on itself
// At first, there is an idea that we have only one table on a form.
// If there's more, well, I'll think about it then...
// Number of collumns is number of userItem-s where e_type & ID_UT_LIST
// Number of rows is e_elems
// Data is e_array

// This is how we create a TableView:
// Ignore all items defined as lists untill we come to a list with a scrollBar
// Then we create a table view within a unified frame of all list items
// UnionRect() for first to last items
// Each column: -setWidth: for the width of that item in rsrc ditl
// Set column identifier as the string with that ditl_def index

#import  "DTTableViewController.h"  

#import  "MainLoop.h"

@implementation DTTableViewController

- (id)initWithForm:(FORM_REC *)aForm
{
   if (self = [super init])  {
      self->form = aForm;
   }
   
   return (self);
}

#pragma mark -

- (NSView *)coreCreateTableViewWithFrame:(CGRect)ctlFrame
                                  inForm:(FORM_REC *)aForm
                             withColumns:(short)numberOfColumns
{
   CGRect  tableRect = { { 0, 0 }, { ctlFrame.size.width, ctlFrame.size.height } };
   
   NSScrollView  *tableContainer = [[NSScrollView alloc] initWithFrame:id_CocoaRect(aForm->my_window, ctlFrame)];
   NSTableView   *aTableView = [[NSTableView alloc] initWithFrame:tableRect];
   
   [tableContainer setDocumentView:aTableView];
   [tableContainer setHasVerticalScroller:YES];
   
   [[aForm->my_window contentView] addSubview:tableContainer];
   
   [aTableView setTag:++aForm->creationIndex];
   
   return (tableContainer);
}

// NSTableViewDataSource Protocol Method

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
   NSInteger  retVal = id_numberOfRowsInTableView (self->form);
   
   return (retVal);
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
   short  index = [tableColumn.identifier intValue];  // index as string
   short  level = (short)row;
   
   NSString  *retObject = nil;
   
   if (!id_inpossible_item(form, index))  {
      if (((form->ditl_def[index]->i_type & 127) == userItem) && (form->edit_def[index]->e_type & ID_UT_LIST))  {
         CFStringRef  cfStr;
         
         id_Mac2CFString (form->edit_def[index]->e_array[level], &cfStr, strlen(form->edit_def[index]->e_array[level]));  // this needs to be cfreleased
         
         retObject = [NSString stringWithString:(NSString *)cfStr];
         
         CFRelease (cfStr);
      }
   }
   
   return (retObject);
}

#ifdef _NIJE_
// NSTableViewDelegate Protocol Method

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
   NSTextField  *tvCell = nil;  // [tableView makeViewWithIdentifier:identifier owner:self];
   
   if (!tvCell)  {
      NSTextFieldCell  *tfCell = nil;
      
      tvCell = [[NSTextField alloc] initWithFrame:CGRectZero];
      
      tfCell = [tvCell cell];  // from NSControl
      
      [tfCell setEditable:NO];
      [tfCell setSelectable:YES];
      [tfCell setBordered:NO];
      [tfCell setBezeled:NO];
      [tfCell setDrawsBackground:NO];
   }
   
   if ([tableColumn.identifier isEqualToString:@"numbers"])
      tvCell.stringValue = @"1";
   else
      tvCell.stringValue = @"2";
   
   NSLog (@"Cell: %@", tvCell.stringValue);
   
   return (tvCell);
}
#endif

@end

int  id_numberOfRowsInTableView (FORM_REC *form)
{
   short  i;
   
   for (i=0; i<=form->last_fldno; i++)  {        /* Find first list */
      if (((form->ditl_def[i]->i_type & 127) == userItem) &&
          (form->edit_def[i]->e_type & ID_UT_LIST))
         return (form->edit_def[i]->e_elems);
   }
   
   return (0);
}

int  id_numberOfCollumnsInTableView (FORM_REC *form)
{
   short  i, retVal = 0;
   
   for (i=0; i<=form->last_fldno; i++)  {        /* Find first list */
      if (((form->ditl_def[i]->i_type & 127) == userItem) && (form->edit_def[i]->e_type & ID_UT_LIST))
         retVal++;
   }
   
   return (retVal);
}


