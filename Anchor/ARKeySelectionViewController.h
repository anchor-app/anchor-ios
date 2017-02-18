//
//  ARKeySelectionViewController.h
//  Anchor
//
//  Created by Austen McDonald on 2/14/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARBaseKeySelectionTableViewController.h"

@class ARKeyValueViewModel;
@class ARKeySelectionViewController;

@protocol ARKeySelectionViewControllerDelegate <NSObject>

- (void)keySelectionViewController:(ARKeySelectionViewController *)viewController didSelectKey:(NSString *)key forViewModel:(ARKeyValueViewModel *)viewModel;

@end

@interface ARKeySelectionViewController : ARBaseKeySelectionTableViewController

- (instancetype)initWithViewModel:(ARKeyValueViewModel *)viewModel keys:(NSArray<NSString *> *)keys;

@property (nonatomic, weak) id<ARKeySelectionViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray<NSString *> *keys;

@end
