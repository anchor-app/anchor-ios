//
//  ARKeyValueViewModel.h
//  Anchor
//
//  Created by Austen McDonald on 2/8/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Parse/Parse.h>

typedef NS_ENUM(NSInteger, ARKeyValueViewModelType) {
  ARKeyValueViewModelTypeNew,
  ARKeyValueViewModelTypeExisting,
};

@interface ARKeyValueViewModel : NSObject

- (instancetype)initWithType:(ARKeyValueViewModelType)type object:(PFObject *)object parentObject:(PFObject *)parentObject relation:(PFRelation *)relation;

@property (nonatomic, assign) ARKeyValueViewModelType type;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, readonly, strong) PFObject *object;
@property (nonatomic, readonly, strong) PFObject *parentObject;
@property (nonatomic, readonly, strong) PFRelation *relation;

@end
