//
//  AREventViewModel.m
//  Anchor
//
//  Created by Austen McDonald on 2/9/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "AREventViewModel.h"

#import "AREvent.h"
#import "ARContact.h"

@interface AREventSubItemViewModel ()

@property (nonatomic, assign) AREventSubItemViewModelType type;
@property (nonatomic, strong) ARContact *contact;

@end

@implementation AREventSubItemViewModel

- (instancetype)initWithType:(AREventSubItemViewModelType)type contact:(ARContact *)contact
{
  if (self = [super init]) {
    self.type = type;
    self.contact = contact;
  }
  return self;
}

@end

@interface AREventViewModel ()

@property (nonatomic, strong) AREvent *event;
@property (nonatomic, strong) NSArray<AREventSubItemViewModel *> *eventSubItemViewModels;

@end

@implementation AREventViewModel

- (instancetype)initWithEvent:(AREvent *)event
{
  if (self = [super init]) {
    self.event = event;
    self.state = AREventViewModelStateCollapsed;
    _eventSubItemViewModels = [self _subItemViewModelsWhenCollapsed];
  }
  return self;
}

- (void)setState:(AREventViewModelState)state
{
  if (state != _state) {
    _state = state;

    switch (_state) {
      case AREventViewModelStateExpanded:
        _eventSubItemViewModels = [self _subItemViewModelsWhenExpanded];
        break;
      case AREventViewModelStateCollapsed:
        _eventSubItemViewModels = [self _subItemViewModelsWhenCollapsed];
        break;
    }
  }
}

- (void)_fillContactVMs:(NSMutableArray<AREventSubItemViewModel *> *)contactVMs newContactVMs:(NSMutableArray<AREventSubItemViewModel *> *)newContactVMs
{
  _.array(_event.participants).each(^(ARContact *contact) {
    if (contact.createdAt != nil) {
      AREventSubItemViewModel *vm = [[AREventSubItemViewModel alloc] initWithType:AREventSubItemViewModelTypeContact contact:contact];
      [contactVMs addObject:vm];
    } else {
      AREventSubItemViewModel *vm = [[AREventSubItemViewModel alloc] initWithType:AREventSubItemViewModelTypeNewContact contact:contact];
      [newContactVMs addObject:vm];
    }
  });
}

- (NSArray<AREventSubItemViewModel *> *)_subItemViewModelsWhenExpanded
{
  NSMutableArray<AREventSubItemViewModel *> *result = [NSMutableArray array];
  NSMutableArray<AREventSubItemViewModel *> *newContactVMs = [NSMutableArray array];

  [self _fillContactVMs:result newContactVMs:newContactVMs];

  [result addObjectsFromArray:newContactVMs];

  if (newContactVMs.count > 5) {
    [result addObject:[[AREventSubItemViewModel alloc] initWithType:AREventSubItemViewModelTypeCollapseButton contact:nil]];
  }

  return result;
}

- (NSArray<AREventSubItemViewModel *> *)_subItemViewModelsWhenCollapsed
{
  NSMutableArray<AREventSubItemViewModel *> *result = [NSMutableArray array];
  NSMutableArray<AREventSubItemViewModel *> *newContactVMs = [NSMutableArray array];

  [self _fillContactVMs:result newContactVMs:newContactVMs];

  if (newContactVMs.count <= 5) {
    [result addObjectsFromArray:newContactVMs];
  } else {
    [result addObjectsFromArray:[newContactVMs objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5)]]];
    [result addObject:[[AREventSubItemViewModel alloc] initWithType:AREventSubItemViewModelTypeExpandButton contact:nil]];
  }

  return result;
}

@end
