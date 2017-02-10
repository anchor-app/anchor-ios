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

@interface ARKeyValueDataSource : ARSingleSectionDataSource

- (instancetype)initWithViewModels:(NSArray<ARKeyValueViewModel *> *)viewModels;

@property (nonatomic, copy) NSArray<ARKeyValueViewModel *> *viewModels;
@property (nonatomic, weak) id<ARDataSourceDelegate> delegate;

@end
