//
//  ARKeyValueDataSource.m
//  Anchor
//
//  Created by Austen McDonald on 2/8/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARKeyValueDataSource.h"

#import "ARKeyValueTableViewCell.h"
#import "ARKeyValueViewModel.h"
#import "ARKeySelectorView.h"

@interface ARKeyValueDataSource () <ARKeyValueTableViewCellDelegate>

@end

@implementation ARKeyValueDataSource

- (instancetype)initWithViewModels:(NSArray<ARKeyValueViewModel *> *)viewModels;
{
  if (self = [super init]) {
    self.viewModels = viewModels;
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

      if (_delegate) {
        [_delegate dataSourceDataChanged:self];
      }
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

- (void)cell:(ARKeyValueTableViewCell *)cell viewModel:(ARKeyValueViewModel *)viewModel keyDidChange:(ARKeySelectorView *)keySelectorView
{
  [self _upgradeViewModelIfNeeded:viewModel];

  // This is probably super inefficient.
  viewModel.key = keySelectorView.key;
  [viewModel.object saveEventually];
}

- (void)cell:(ARKeyValueTableViewCell *)cell viewModel:(ARKeyValueViewModel *)viewModel valueDidChange:(UITextView *)valueTextView
{
  [self _upgradeViewModelIfNeeded:viewModel];

  // This is probably super inefficient.
  viewModel.value = valueTextView.text;
  [viewModel.object saveEventually];

  if (_delegate) {
    [_delegate dataSourceCellsHeightChanged:self];
  }
}

- (void)cell:(ARKeyValueTableViewCell *)cell didTapKeySelectorForViewModel:(ARKeyValueViewModel *)viewModel
{
  
}

@end
