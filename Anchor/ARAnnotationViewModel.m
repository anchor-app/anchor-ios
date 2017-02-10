//
//  ARAnnotationViewModel.m
//  Anchor
//
//  Created by Austen McDonald on 2/8/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARAnnotationViewModel.h"

#import "ARAnnotation.h"

@implementation ARAnnotationViewModel

- (instancetype)initWithType:(ARKeyValueViewModelType)type object:(PFObject *)object parentObject:(PFObject *)parentObject relation:(PFRelation *)relation
{
  if (self = [super initWithType:type object:object parentObject:parentObject relation:relation]) {
    self.canEdit = YES;
  }
  return self;
}

- (NSString *)key
{
  ARAnnotation *annotation = (ARAnnotation *)self.object;

  switch (self.type) {
    case ARKeyValueViewModelTypeNew:
      return @"SELECT A TYPE";
    case ARKeyValueViewModelTypeExisting:
      return [annotation.key uppercaseString];
  }
}

- (void)setKey:(NSString *)key
{
  ARAnnotation *annotation = (ARAnnotation *)self.object;
  annotation.key = key;
}

- (NSString *)value
{
  ARAnnotation *annotation = (ARAnnotation *)self.object;
  return annotation.value;
}

- (void)setValue:(NSString *)value
{
  ARAnnotation *annotation = (ARAnnotation *)self.object;
  annotation.value = value;
}

@end
