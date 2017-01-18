//
//  Schedule.h
//  Carnegie
//
//  Created by Austen McDonald on 1/15/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Parse/Parse.h>

@class Contact;
@class Event;

/**
 Designed for local storage.
 */
@interface Schedule : NSObject

+ (instancetype)scheduleWithEvents:(NSArray<Event *> *)events contacts:(NSArray<Contact *> *)contacts;

@property (nonatomic, readonly, copy) NSArray<Event *> *events;
@property (nonatomic, readonly, copy) NSArray<Contact *> *contacts;

@end
