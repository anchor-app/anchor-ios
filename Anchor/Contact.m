//
//  CNGEParticipant.m
//  Anchor
//
//  Created by Austen McDonald on 1/10/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import "Contact.h"

@interface Contact ()

@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSArray<NSString *> *emails;
@property (nonatomic, copy) NSString *fullContactJSON;
@property (nonatomic, copy) NSString *photoURL;

@end

@implementation Contact

@dynamic fullName;
@dynamic emails;
@dynamic fullContactJSON;
@dynamic photoURL;
@synthesize notes = _notes;
@synthesize annotations = _annotations;

+ (instancetype)contactWithFullName:(NSString *)fullName emails:(NSArray<NSString *> *)emails
{
  Contact *c = [Contact object];
  c.fullName = fullName;
  c.emails = emails;
  return c;
}

+ (void)load {
  [self registerSubclass];
}

+ (NSString *)parseClassName
{
  return @"Contact";
}

- (PFRelation *)annotations
{
  if (_annotations == nil) {
    _annotations = [self relationForKey:@"annotations"];
  }
  return _annotations;
}

- (void)setAnnotations:(PFRelation *)annotations
{
  _annotations = annotations;
}

- (PFRelation *)notes
{
  if (_notes == nil) {
    _notes = [self relationForKey:@"notes"];
  }
  return _notes;
}

- (void)setNotes:(PFRelation *)notes
{
  _notes = notes;
}

@end
