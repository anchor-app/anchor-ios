//
//  ARKeyValueViewModel.m
//  Anchor
//
//  Created by Austen McDonald on 2/8/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//
#import "ARKeyValueViewModel.h"

@interface ARKeyValueViewModel ()

@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) PFObject *parentObject;
@property (nonatomic, strong) PFRelation *relation;

@end

@implementation ARKeyValueViewModel

@dynamic key;
@dynamic value;

- (instancetype)initWithType:(ARKeyValueViewModelType)type object:(PFObject *)object parentObject:(PFObject *)parentObject relation:(PFRelation *)relation
{
  if (self = [super init]) {
    self.type = type;
    self.object = object;
    self.parentObject = parentObject;
    self.relation = relation;
  }
  return self;
}

@end
