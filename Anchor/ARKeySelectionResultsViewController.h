//
//  ARKeySelectionResultsViewController.h
//  Anchor
//
//  Created by Austen McDonald on 2/14/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARBaseKeySelectionTableViewController.h"

@class ARKeySelectionViewModel;

@interface ARKeySelectionResultsViewController : ARBaseKeySelectionTableViewController

@property (nonatomic, strong) NSArray<ARKeySelectionViewModel *> *filteredViewModels;

@end
