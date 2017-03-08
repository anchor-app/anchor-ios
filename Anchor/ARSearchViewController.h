//
//  ARSearchViewController.h
//  Anchor
//
//  Created by Austen McDonald on 3/3/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARSearchBaseTableViewController.h"

@class ARContact;
@class ARSearchViewController;
@class ARSearchViewModel;

@protocol ARSearchViewControllerDelegate <NSObject>

- (void)searchViewController:(ARSearchViewController *)viewController didSelectContactId:(NSString *)contactId forViewModel:(ARSearchViewModel *)viewModel;

@end

@interface ARSearchViewController : ARSearchBaseTableViewController

@property (nonatomic, weak) id<ARSearchViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray<ARContact *> *contacts;

@end
