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

@class Contact;

@interface ARNote : PFObject <PFSubclassing>

@property (nonatomic, readonly, strong) NSDate *date;
@property (nonatomic, readonly, copy) NSString *text;
@property (nonatomic, readonly, strong) Contact *contact;

+ (instancetype)noteForContact:(Contact *)contact withText:(NSString *)text date:(NSDate *)date;

@end
