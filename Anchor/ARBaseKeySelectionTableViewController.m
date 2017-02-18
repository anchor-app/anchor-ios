//
//  ARBaseKeySelectionTableViewController.m
//  Anchor
//
//  Created by Austen McDonald on 2/14/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARBaseKeySelectionTableViewController.h"

@interface ARKeySelectionViewModel ()

@property (nonatomic, assign) ARKeySelectionViewModelType type;
@property (nonatomic, strong) NSString *key;

@end

@implementation ARKeySelectionViewModel

- (instancetype)initWithType:(ARKeySelectionViewModelType)type key:(NSString *)key
{
  if (self = [super init]) {
    self.type = type;
    self.key = key;
  }
  return self;
}

@end

@implementation ARBaseKeySelectionTableViewController


- (void)configureCell:(UITableViewCell *)cell withViewModel:(ARKeySelectionViewModel *)viewModel
{
  switch (viewModel.type) {
    case ARKeySelectionViewModelTypeNewKey:
      cell.textLabel.text = [NSString stringWithFormat:@"Add a new key: %@", viewModel.key];
      break;
    case ARKeySelectionViewModelTypeKey:
      cell.textLabel.text = viewModel.key;
      break;
  }
}

@end
