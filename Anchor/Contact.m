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
@property (nonatomic, strong) NSArray<NSString *> *emails;

@end

@implementation Contact

@dynamic fullName;
@dynamic emails;

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

@end
