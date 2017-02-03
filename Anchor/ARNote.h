//
//  ARNote.h
//  Anchor
//
//  Created by Austen McDonald on 1/30/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <EventKit/EventKit.h>
#import <Parse/Parse.h>

@class ARContact;

@interface ARNote : PFObject <PFSubclassing>

@property (nonatomic, readonly, strong) NSDate *date;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, readonly, strong) ARContact *contact;

+ (instancetype)noteForContact:(ARContact *)contact withText:(NSString *)text date:(NSDate *)date;

@end
