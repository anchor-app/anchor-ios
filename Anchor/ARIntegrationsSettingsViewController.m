//
//  ARIntegrationsSettingsViewController.m
//  Anchor
//
//  Created by Austen McDonald on 2/17/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARIntegrationsSettingsViewController.h"

#import <Parse/Parse.h>

#import "ARSingleSectionDataSource.h"
#import "ARFullContactDataSource.h"
#import "ARUser.h"

@interface ARIntegrationsSettingsViewController () <ARDataSourceDelegate>

@property (nonatomic, strong) NSArray<ARSingleSectionDataSource *> *dataSources;

@end

@implementation ARIntegrationsSettingsViewController

- (instancetype)init
{
  if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    self.title = @"Manage Integrations";

    self.dataSources = [self _dataSourcesForCurrentState];
  }
  return self;
}

- (NSArray *)_dataSourcesForCurrentState
{
  NSMutableArray *result = [NSMutableArray array];

  ARFullContactDataSource *fcDS = [[ARFullContactDataSource alloc] init];
  fcDS.delegate = self;
  [result addObject:fcDS];

  return result;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return [_dataSources[section] tableView:tableView titleForHeaderInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [_dataSources count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_dataSources[section] tableView:tableView numberOfRowsInSection:0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [_dataSources[indexPath.section] tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [_dataSources[indexPath.section] tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)dataSourceDataChanged:(ARSingleSectionDataSource *)dataSource
{
  [self.tableView reloadData];
}

- (void)dataSourceCellsHeightChanged:(ARSingleSectionDataSource *)dataSource
{
  [self.tableView beginUpdates];
  [self.tableView endUpdates];
}

@end
