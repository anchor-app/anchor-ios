//
//  ARNoteTableViewCell.m
//  Anchor
//
//  Created by Austen McDonald on 2/1/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARNoteTableViewCell.h"

@implementation ARNoteTableViewCell

- (void)setNote:(ARNote *)note
{
  _note = note;

  self.textLabel.text = note.text;
}
@end
