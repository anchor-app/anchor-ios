//
//  ARSchedule.h
//  Anchor
//
//  Created by Austen McDonald on 1/15/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Parse/Parse.h>

@class ARContact;
@class AREvent;

/**
 Designed for local storage.
 */
@interface ARSchedule : NSObject

+ (instancetype)scheduleWithEvents:(NSArray<AREvent *> *)events contacts:(NSArray<ARContact *> *)contacts;

@property (nonatomic, readonly, copy) NSArray<AREvent *> *events;
@property (nonatomic, readonly, copy) NSArray<ARContact *> *contacts;

@end
