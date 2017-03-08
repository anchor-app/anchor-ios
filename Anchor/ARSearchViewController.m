//
//  ARSearchViewController.m
//  Anchor
//
//  Created by Austen McDonald on 3/3/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARSearchViewController.h"

#import <Bolts/Bolts.h>
#import <Parse/Parse.h>

#import "ARSearchResultsViewController.h"
#import "ARContact.h"

@interface ARSearchViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) ARSearchResultsViewController *resultsTableController;
@property (nonatomic, strong) NSArray<ARSearchViewModel *> *viewModels;
@property (nonatomic, strong) NSArray<NSString *> *emails;
@property (nonatomic, strong) NSArray<NSString *> *fullNames;

@end

@implementation ARSearchViewController

- (instancetype)init
{
  if (self = [super initWithStyle:UITableViewStylePlain]) {
    self.title = @"Search";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.resultsTableController = [[ARSearchResultsViewController alloc] init];
  _searchController = [[UISearchController alloc] initWithSearchResultsController:_resultsTableController];
  _searchController.searchResultsUpdater = self;
  _searchController.hidesNavigationBarDuringPresentation = NO;
  [_searchController.searchBar sizeToFit];
  _searchController.searchBar.placeholder = @"Search for a contact or enter a new one";
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

- (void)setContacts:(NSArray<ARContact *> *)contacts
{
  _contacts = contacts;

  self.viewModels = [_.array(_contacts).map(^(ARContact *c) {
    return [[ARSearchViewModel alloc] initWithType:ARSearchViewModelTypeContact name:c.fullName contactId:c.objectId];
  }) unwrap];

  [self.tableView reloadData];
  [self updateSearchResultsForSearchController:_searchController];
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
  return _viewModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *identifier = @"ARSearchViewControllerIdentifier";
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
  ARSearchViewModel *viewModel = (tableView == self.tableView) ? _viewModels[indexPath.row] : _resultsTableController.filteredViewModels[indexPath.row];

  [_delegate searchViewController:self didSelectContactId:viewModel.contactId forViewModel:viewModel];
}


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
  // Update the filtered array based on the search text.
  NSString *searchText = searchController.searchBar.text.lowercaseString;

  // Strip out all the leading and trailing spaces.
  NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

  if (strippedString.length > 0) {
    // Find the Contact objects by email and name using a cloud function.
    [[PFCloud callFunctionInBackground:@"searchContacts" withParameters:@{@"q": strippedString}] continueWithSuccessBlock:^id _Nullable(BFTask<id> * _Nonnull t)
     {
       NSMutableArray<ARSearchViewModel *> *viewModels = [NSMutableArray array];
       NSArray<NSDictionary *> *results = t.result;

       [viewModels addObject:[[ARSearchViewModel alloc] initWithType:ARSearchViewModelTypeNewContact name:strippedString contactId:nil]];
       for (NSDictionary *r in results) {
         [viewModels addObject:[[ARSearchViewModel alloc] initWithType:ARSearchViewModelTypeContact name:r[@"fullName"] contactId:r[@"contactId"]]];
       }

       dispatch_async(dispatch_get_main_queue(), ^{
         // hand over the filtered results to our search results table
         ARSearchResultsViewController *tableController = (ARSearchResultsViewController *)self.searchController.searchResultsController;
         tableController.filteredViewModels = viewModels;
         [tableController.tableView reloadData];
       });
       return nil;
     }];
  }
}

@end

