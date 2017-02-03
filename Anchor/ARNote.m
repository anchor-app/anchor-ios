//
//  ARNote.m
//  Anchor
//
//  Created by Austen McDonald on 1/30/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARNote.h"

#import "ARContact.h"

@interface ARNote ()

@property (nonatomic, strong) ARContact *contact;
@property (nonatomic, strong) NSDate *date;

@end

@implementation ARNote

@dynamic contact;
@dynamic text;
@dynamic date;

+ (instancetype)noteForContact:(ARContact *)contact withText:(NSString *)text date:(NSDate *)date
{
  ARNote *note = [ARNote object];
  note.contact = contact;
  note.text = text;
  note.date = date;

  return note;
}

+ (void)load {
  [self registerSubclass];
}

+ (NSString *)parseClassName
{
  return @"Note";
}

@end
