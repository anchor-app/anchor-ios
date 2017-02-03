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
#import "ARContact.h"

@interface ARNotesDataSource () <ARNoteTableViewCellDelegate>
@end

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
  cell.delegate = self;

  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  ARNote *note = _notes[indexPath.row];

  return [ARNoteTableViewCell heightForNote:note width:tableView.frame.size.width];
}

- (void)cell:(ARNoteTableViewCell *)cell note:(ARNote *)note textViewDidChange:(UITextView *)textView
{
  if (_delegate) {
    // It could be that this is a new Note and we need to attach it to a contact.
    // This is probably super inefficient.
    [note.contact.notes addObject:note];
    [note.contact saveEventually];

    note.text = textView.text;
    [note saveEventually];
    
    [_delegate dataSourceCellsHeightChanged:self];
  }
}

@end
