//
//  AREvent.m
//  Anchor
//
//  Created by Austen McDonald on 1/10/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import "AREvent.h"

#import <EventKit/EventKit.h>

#import "ARContact.h"

@interface AREvent ()

@property (nonatomic, copy) NSArray<ARContact *> *participants;
@property (nonatomic, strong) EKEvent *underlyingEvent;

@end

@implementation AREvent

+ (instancetype)eventWithParticipants:(NSArray<ARContact *> *)participants underlyingEvent:(EKEvent *)underlyingEvent
{
  AREvent *e = [[AREvent alloc] init];
  e.participants = participants;
  e.underlyingEvent = underlyingEvent;

  return e;
}

@end
