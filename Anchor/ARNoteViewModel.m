//
//  ARNoteViewModel.m
//  Anchor
//
//  Created by Austen McDonald on 2/8/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARNoteViewModel.h"

#import "ARNote.h"

@implementation ARNoteViewModel

- (NSString *)key
{
  ARNote *note = (ARNote *)self.object;

  static NSDateFormatter *dateFormatter;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, yyyy"];
  });

  return [[dateFormatter stringFromDate:note.date] uppercaseString];
}

- (NSString *)value
{
  ARNote *note = (ARNote *)self.object;
  return note.text;
}

- (void)setValue:(NSString *)value
{
  ARNote *note = (ARNote *)self.object;
  note.text = value;
}

@end
