//
//  AREventViewModel.h
//  Anchor
//
//  Created by Austen McDonald on 2/9/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AREvent;
@class ARContact;

typedef NS_ENUM(NSInteger, AREventSubItemViewModelType) {
  AREventSubItemViewModelTypeContact,
  AREventSubItemViewModelTypeNewContact,
  AREventSubItemViewModelTypeExpandButton,
  AREventSubItemViewModelTypeCollapseButton,
};

@interface AREventSubItemViewModel : NSObject

@property (nonatomic, readonly, assign) AREventSubItemViewModelType type;
@property (nonatomic, readonly, strong) ARContact *contact;

- (instancetype)initWithType:(AREventSubItemViewModelType)type contact:(ARContact *)contact;

@end

typedef NS_ENUM(NSInteger, AREventViewModelState) {
  AREventViewModelStateCollapsed,
  AREventViewModelStateExpanded,
};

@interface AREventViewModel : NSObject

@property (nonatomic, assign) AREventViewModelState state;
@property (nonatomic, readonly, strong) AREvent *event;
@property (nonatomic, readonly, strong) NSArray<AREventSubItemViewModel *> *eventSubItemViewModels;

- (instancetype)initWithEvent:(AREvent *)event;

@end
