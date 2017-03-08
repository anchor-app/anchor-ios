//
//  ARSearchResultsViewController.h
//  Anchor
//
//  Created by Austen McDonald on 3/3/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARSearchBaseTableViewController.h"

@class ARSearchViewModel;

@interface ARSearchResultsViewController : ARSearchBaseTableViewController

@property (nonatomic, strong) NSArray<ARSearchViewModel *> *filteredViewModels;

@end
