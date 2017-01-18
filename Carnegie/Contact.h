//
//  CNGEParticipant.h
//  Carnegie
//
//  Created by Austen McDonald on 1/10/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <EventKit/EventKit.h>
#import <Parse/Parse.h>

@interface Contact : PFObject<PFSubclassing>

@property (nonatomic, readonly, copy) NSString *fullName;
@property (nonatomic, readonly, strong) NSArray<NSString *> *emails;

+ (instancetype)contactWithFullName:(NSString *)fullName emails:(NSArray<NSString *> *)emails;

@end
