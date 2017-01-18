//
//  Event.h
//  Carnegie
//
//  Created by Austen McDonald on 1/10/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKEvent;

/**
 Designed for local storage.
 */
@interface Event : NSObject

// email -> Contact or NSNull
@property (nonatomic, readonly, copy) NSDictionary<NSString *, id> *participants;
@property (nonatomic, readonly, strong) EKEvent *underlyingEvent;

+ (instancetype)eventWithParticipants:(NSDictionary<NSString *, id> *)participants underlyingEvent:(EKEvent *)underlyingEvent;

- (NSString *)emailAtIndex:(NSInteger)index;
- (id)contactOrNullAtIndex:(NSInteger)index;

@end
