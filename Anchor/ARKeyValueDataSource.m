//
//  ARKeyValueDataSource.m
//  Anchor
//
//  Created by Austen McDonald on 2/8/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARKeyValueDataSource.h"

#import <UIKit/UIKit.h>

#import "ARKeyValueTableViewCell.h"
#import "ARKeyValueViewModel.h"
#import "ARKeySelectorView.h"
#import "ARKeyManager.h"
#import "ARKeySelectionViewController.h"

@interface ARKeyValueDataSource () <ARKeyValueTableViewCellDelegate, ARKeySelectionViewControllerDelegate>

@property (nonatomic, strong) ARKeyManager *keyManager;
@property (nonatomic, strong) UIViewController *viewController;

@end

@implementation ARKeyValueDataSource

- (instancetype)initWithViewModels:(NSArray<ARKeyValueViewModel *> *)viewModels keyManager:(ARKeyManager *)keyManager viewController:(UIViewController *)viewController
{
  if (self = [super init]) {
    self.viewModels = viewModels;
    self.keyManager = keyManager;
    self.viewController = viewController;
  }
  return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _viewModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *identifier = @"ARKeyValueTableViewCellIdentifier";
  ARKeyValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[ARKeyValueTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.delegate = self;
  }

  cell.viewModel = _viewModels[indexPath.row];

  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  ARKeyValueViewModel *viewModel = _viewModels[indexPath.row];

  return [ARKeyValueTableViewCell heightForViewModel:viewModel width:tableView.frame.size.width];
}

- (void)_upgradeViewModelIfNeeded:(ARKeyValueViewModel *)vm
{
  // It could be that this is a new Annotation and we need to attach it to a contact.
  switch (vm.type) {
    case ARKeyValueViewModelTypeNew:
    {
      // The Parse documentation seems to say that you can just save the parent object of
      // a relation and have the new children saved as well, but that's not my experience. Instead,
      // the child will be saved but not attached to the relation.
      [[vm.object saveInBackground] continueWithBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        [vm.relation addObject:vm.object];
        return [vm.parentObject saveInBackground];
      }];

      vm.type = ARKeyValueViewModelTypeExisting;
      break;
    }
    case ARKeyValueViewModelTypeExisting:
      // No need to do anything special here.
      break;
  }
}

- (void)cell:(ARKeyValueViewModel *)cell didDeleteViewModel:(ARKeyValueViewModel *)viewModel
{
  [viewModel.relation removeObject:viewModel.object];
  [viewModel.object deleteEventually];
  [viewModel.parentObject saveEventually];

  NSMutableArray *a = [_viewModels mutableCopy];
  [a removeObject:viewModel];

  self.viewModels = a;

  if (_delegate) {
    [_delegate dataSourceDataChanged:self];
  }
}

- (void)cell:(ARKeyValueTableViewCell *)cell viewModelDidChange:(ARKeyValueViewModel *)viewModel key:(NSString *)key value:(NSString *)value
{
  if (key != nil) {
    viewModel.key = key;
  }
  if (value != nil) {
    viewModel.value = value;
  }

  [self _upgradeViewModelIfNeeded:viewModel];

  [viewModel.object saveEventually];

  if (key != nil) {
    [_delegate dataSourceDataChanged:self];
  }

  if (value != nil) {
    [_delegate dataSourceCellsHeightChanged:self];
  }
}

- (void)cell:(ARKeyValueTableViewCell *)cell didTapKeySelectorForViewModel:(ARKeyValueViewModel *)viewModel
{
  ARKeySelectionViewController *vc = [_keyManager keySelectionViewControllerForViewModel:viewModel];
  vc.delegate = self;
  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
  vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(_onKeySelectionCancel)];
  [_viewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)_onKeySelectionCancel
{
  [_viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)keySelectionViewController:(ARKeySelectionViewController *)viewController didSelectKey:(NSString *)key forViewModel:(ARKeyValueViewModel *)viewModel;
{
  [_keyManager updateKeyCacheWithKey:key];
  [self cell:nil viewModelDidChange:viewModel key:key value:nil];
  [_viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
