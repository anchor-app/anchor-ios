//
//  ARKeySelectionViewController.m
//  Anchor
//
//  Created by Austen McDonald on 2/14/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARKeySelectionViewController.h"

#import "ARKeySelectionResultsViewController.h"
#import "ARKeyValueViewModel.h"

@interface ARKeySelectionViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) ARKeyValueViewModel *viewModel;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) ARKeySelectionResultsViewController *resultsTableController;
@property (nonatomic, strong) NSArray<ARKeySelectionViewModel *> *viewModels;

@end

@implementation ARKeySelectionViewController

- (instancetype)initWithViewModel:(ARKeyValueViewModel *)viewModel keys:(NSArray *)keys
{
  if (self = [super initWithStyle:UITableViewStylePlain]) {
    self.viewModel = viewModel;
    self.keys = keys;

    self.title = @"Annotation Key";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.resultsTableController = [[ARKeySelectionResultsViewController alloc] init];
  _searchController = [[UISearchController alloc] initWithSearchResultsController:_resultsTableController];
  _searchController.searchResultsUpdater = self;
  _searchController.hidesNavigationBarDuringPresentation = NO;
  [_searchController.searchBar sizeToFit];
  _searchController.searchBar.placeholder = @"Search for a key or enter a new one";
  _searchController.searchBar.showsCancelButton = NO;
  self.tableView.tableHeaderView = _searchController.searchBar;

  // We want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables.
  _resultsTableController.tableView.delegate = self;
  _searchController.delegate = self;
  _searchController.dimsBackgroundDuringPresentation = NO; // default is YES
  _searchController.searchBar.delegate = self; // so we can monitor text changes + others

  // Search is now just presenting a view controller. As such, normal view controller
  // presentation semantics apply. Namely that presentation will walk up the view controller
  // hierarchy until it finds the root view controller or one that defines a presentation context.
  //
  self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];

  [_searchController setActive:YES];
}

- (void)setKeys:(NSArray<NSString *> *)keys
{
  _keys = keys;

  // For the initial view, don't show an "Add key:..." row. Force this by passing nil as searchText.
  self.viewModels = [self _viewModelsForKeys:_keys searchText:nil];

  [self.tableView reloadData];
  [self updateSearchResultsForSearchController:_searchController];
}

- (NSArray<ARKeySelectionViewModel *> *)_viewModelsForKeys:(NSArray<NSString *> *)keys searchText:(NSString *)text
{
  NSMutableArray<ARKeySelectionViewModel *> *result = [NSMutableArray array];

  // update the filtered array based on the search text
  NSString *searchText = text.lowercaseString;

  // strip out all the leading and trailing spaces
  NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

  if (strippedString.length > 0 && ![keys containsObject:strippedString]) {
    [result addObject:[[ARKeySelectionViewModel alloc] initWithType:ARKeySelectionViewModelTypeNewKey key:strippedString]];
  }

  for (NSString *key in _keys) {
    [result addObject:[[ARKeySelectionViewModel alloc] initWithType:ARKeySelectionViewModelTypeKey key:key]];
  }

  return result;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
}


#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {

}

- (void)willPresentSearchController:(UISearchController *)searchController {
}

- (void)didPresentSearchController:(UISearchController *)searchController {
  [_searchController.searchBar becomeFirstResponder];
}

- (void)willDismissSearchController:(UISearchController *)searchController {
  // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
  // do something after the search controller is dismissed
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.keys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *identifier = @"ARKeySelectionViewControllerIdentifier";
  UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }

  [self configureCell:cell withViewModel:_viewModels[indexPath.row]];

  return cell;
}

// here we are the table view delegate for both our main table and filtered table, so we can
// push from the current navigation controller (resultsTableController's parent view controller
// is not this UINavigationController)
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  ARKeySelectionViewModel *viewModel = (tableView == self.tableView) ? _viewModels[indexPath.row] : _resultsTableController.filteredViewModels[indexPath.row];

  [_delegate keySelectionViewController:self didSelectKey:viewModel.key forViewModel:_viewModel];
}


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
  // update the filtered array based on the search text
  NSString *searchText = searchController.searchBar.text.lowercaseString;

  // strip out all the leading and trailing spaces
  NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

  // break up the search terms (separated by spaces)
  NSArray *searchItems = nil;
  if (strippedString.length > 0) {
    searchItems = [strippedString componentsSeparatedByString:@" "];
  }

  NSArray *searchResults = _.array(_keys).filter(^BOOL (NSString *key) {
    for (NSString *searchString in searchItems) {
      if ([key containsString:searchString]) {
        return YES;
      }
    }
    return NO;
  }).unwrap;

  // hand over the filtered results to our search results table
  ARKeySelectionResultsViewController *tableController = (ARKeySelectionResultsViewController *)self.searchController.searchResultsController;
  tableController.filteredViewModels = [self _viewModelsForKeys:searchResults searchText:strippedString];
  [tableController.tableView reloadData];
}

@end
