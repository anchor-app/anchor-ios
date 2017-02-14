//
//  AREvent.h
//  Anchor
//
//  Created by Austen McDonald on 1/10/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKEvent;
@class ARContact;

/**
 Designed for local storage.
 */
@interface AREvent : NSObject

@property (nonatomic, readonly, copy) NSArray<ARContact *> *participants;
@property (nonatomic, readonly, strong) EKEvent *underlyingEvent;

+ (instancetype)eventWithParticipants:(NSArray<ARContact *> *)participants underlyingEvent:(EKEvent *)underlyingEvent;

@end
