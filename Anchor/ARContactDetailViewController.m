//
//  ARContactDetailViewController.m
//  Anchor
//
//  Created by Austen McDonald on 1/30/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARContactDetailViewController.h"

#import "ARContactHeaderDataSource.h"
#import "ARNotesDataSource.h"
#import "ARAnnotationsDataSource.h"

@interface ARContactDetailViewController ()

@property (nonatomic, strong) ARContact *contact;
@property (nonatomic, strong) NSArray *dataSources;

@end

@implementation ARContactDetailViewController

- (instancetype)initWithContact:(ARContact *)contact
{
  if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    self.contact = contact;

    self.dataSources = @[
                         [[ARContactHeaderDataSource alloc] initWithContact:self.contact],

                         ];
  }
  return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.dataSources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  id<UITableViewDataSource> dataSource = self.dataSources[section];
  return [dataSource tableView:tableView numberOfRowsInSection:0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  id<UITableViewDataSource> dataSource = self.dataSources[indexPath.section];
  return [dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
}

@end
