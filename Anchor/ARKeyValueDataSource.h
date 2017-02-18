//
//  ARKeyValueDataSource.h
//  Anchor
//
//  Created by Austen McDonald on 2/8/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARSingleSectionDataSource.h"

#import <UIKit/UITableViewController.h>

@class ARKeyValueViewModel;
@class ARKeyManager;

@interface ARKeyValueDataSource : ARSingleSectionDataSource

- (instancetype)initWithViewModels:(NSArray<ARKeyValueViewModel *> *)viewModels keyManager:(ARKeyManager *)keyManager viewController:(UIViewController *)viewController;

@property (nonatomic, copy) NSArray<ARKeyValueViewModel *> *viewModels;
@property (nonatomic, weak) id<ARDataSourceDelegate> delegate;

@end
