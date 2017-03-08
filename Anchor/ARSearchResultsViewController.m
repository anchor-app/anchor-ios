//
//  ARSearchResultsViewController.m
//  Anchor
//
//  Created by Austen McDonald on 3/3/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARSearchResultsViewController.h"

@interface ARSearchResultsViewController ()

@end

@implementation ARSearchResultsViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _filteredViewModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *identifier = @"ARSearchViewControllerIdentifier";
  UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }

  [self configureCell:cell withViewModel:_filteredViewModels[indexPath.row]];

  return cell;
}

@end
