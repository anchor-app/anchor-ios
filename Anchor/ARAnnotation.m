//
//  ARAnnotation.m
//  Anchor
//
//  Created by Austen McDonald on 2/1/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARAnnotation.h"

@interface ARAnnotation ()

@property (nonatomic, strong) ARContact *contact;

@end

@implementation ARAnnotation

@dynamic contact;
@dynamic key;
@dynamic value;

+ (instancetype)annotationForContact:(ARContact *)contact withKey:(NSString *)key value:(NSString *)value
{
  ARAnnotation *a = [ARAnnotation object];
  a.contact = contact;
  a.key = key;
  a.value = value;

  return a;
}

+ (void)load {
  [self registerSubclass];
}

+ (NSString *)parseClassName
{
  return @"Annotation";
}

@end
