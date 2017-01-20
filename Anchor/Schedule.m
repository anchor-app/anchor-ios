//
//  Schedule.m
//  Anchor
//
//  Created by Austen McDonald on 1/15/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import "Schedule.h"

@interface Schedule ()

@property (nonatomic, copy) NSArray<Event *> *events;
@property (nonatomic, copy) NSArray<Contact *> *contacts;

@end

@implementation Schedule

+ (instancetype)scheduleWithEvents:(NSArray<Event *> *)events contacts:(NSArray<Contact *> *)contacts
{
  Schedule *s = [[Schedule alloc] init];
  s.events = events;
  s.contacts = contacts;
  return s;
}

@end
