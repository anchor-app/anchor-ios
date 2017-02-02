//
//  ARSchedule.m
//  Anchor
//
//  Created by Austen McDonald on 1/15/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import "ARSchedule.h"

@interface ARSchedule ()

@property (nonatomic, copy) NSArray<AREvent *> *events;
@property (nonatomic, copy) NSArray<ARContact *> *contacts;

@end

@implementation ARSchedule

+ (instancetype)scheduleWithEvents:(NSArray<AREvent *> *)events contacts:(NSArray<ARContact *> *)contacts
{
  ARSchedule *s = [[ARSchedule alloc] init];
  s.events = events;
  s.contacts = contacts;
  return s;
}

@end
