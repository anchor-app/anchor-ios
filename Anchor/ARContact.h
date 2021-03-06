//
//  ARContact.h
//  Anchor
//
//  Created by Austen McDonald on 1/10/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <EventKit/EventKit.h>
#import <Parse/Parse.h>

@class PFRelation;

@interface ARContact : PFObject<PFSubclassing>

@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSArray<NSString *> *emails;
@property (nonatomic, readonly, copy) NSString *fullContactJSON;
@property (nonatomic, readonly, copy) NSString *photoURL;
@property (nonatomic, readonly, strong) PFRelation *notes;
@property (nonatomic, readonly, strong) PFRelation *annotations;

+ (instancetype)contactWithFullName:(NSString *)fullName emails:(NSArray<NSString *> *)emails;

@end
