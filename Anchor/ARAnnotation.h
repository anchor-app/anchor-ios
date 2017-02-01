//
//  ARAnnotation.h
//  Anchor
//
//  Created by Austen McDonald on 2/1/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <Parse/Parse.h>

@class Contact;

@interface ARAnnotation : PFObject <PFSubclassing>

@property (nonatomic, readonly, strong) Contact *contact;
@property (nonatomic, readonly, copy) NSString *key;
@property (nonatomic, readonly, copy) NSString *value;

+ (instancetype)annotationForContact:(Contact *)contact withKey:(NSString *)key value:(NSString *)value;

@end
