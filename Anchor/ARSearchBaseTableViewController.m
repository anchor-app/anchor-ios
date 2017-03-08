//
//  ARSearchBaseTableViewController.m
//  Anchor
//
//  Created by Austen McDonald on 3/3/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARSearchBaseTableViewController.h"

#import "ARContact.h"

@interface ARSearchViewModel ()

@property (nonatomic, assign) ARSearchViewModelType type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *contactId;

@end

@implementation ARSearchViewModel

- (instancetype)initWithType:(ARSearchViewModelType)type name:(NSString *)name contactId:(NSString *)contactId;
{
  if (self = [super init]) {
    self.type = type;
    self.name = name;
    self.contactId = contactId;
  }
  return self;
}

@end

@implementation ARSearchBaseTableViewController


- (void)configureCell:(UITableViewCell *)cell withViewModel:(ARSearchViewModel *)viewModel
{
  switch (viewModel.type) {
    case ARSearchViewModelTypeNewContact:
      cell.textLabel.text = [NSString stringWithFormat:@"Add a new contact: %@", viewModel.name];
      break;
    case ARSearchViewModelTypeContact:
      cell.textLabel.text = viewModel.name;
      break;
  }
}

@end
