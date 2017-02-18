//
//  ARKeySelectionResultsViewController.m
//  Anchor
//
//  Created by Austen McDonald on 2/14/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARKeySelectionResultsViewController.h"

@interface ARKeySelectionResultsViewController ()

@end

@implementation ARKeySelectionResultsViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _filteredViewModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *identifier = @"ARKeySelectionViewControllerIdentifier";
  UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }

  [self configureCell:cell withViewModel:_filteredViewModels[indexPath.row]];

  return cell;
}

@end
