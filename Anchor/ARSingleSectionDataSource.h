//
//  ARSingleSectionDataSource.h
//  Anchor
//
//  Created by Austen McDonald on 2/1/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UITableViewController.h>

@class ARSingleSectionDataSource;

@protocol ARDataSourceDelegate

- (void)dataSourceCellsHeightChanged:(ARSingleSectionDataSource *)dataSource;
- (void)dataSourceDataChanged:(ARSingleSectionDataSource *)dataSource;

@end

@interface ARSingleSectionDataSource : NSObject <UITableViewDataSource>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
