//
//  ARNotesDataSource.m
//  Anchor
//
//  Created by Austen McDonald on 1/30/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARNotesDataSource.h"

#import "ARNoteTableViewCell.h"
#import "ARNote.h"
#import "Contact.h"

@implementation ARNotesDataSource

- (instancetype)initWithNotes:(NSArray<ARNote *> *)notes
{
  if (self = [super init]) {
    self.notes = notes;
  }
  return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *identifier = @"ARNoteTableViewCell";
  ARNoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[ARNoteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }

  ARNote *note = _notes[indexPath.row];
  cell.note = note;

  return cell;
}

@end
