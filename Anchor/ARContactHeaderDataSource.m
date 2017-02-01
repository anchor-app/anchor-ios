//
//  ARContactHeaderDataSource.m
//  Anchor
//
//  Created by Austen McDonald on 1/30/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARContactHeaderDataSource.h"

#import "ARContactHeaderTableViewCell.h"
#import "Contact.h"

@interface ARContactHeaderDataSource ()

@property (nonatomic, strong) Contact *contact;

@end

@implementation ARContactHeaderDataSource

- (instancetype)initWithContact:(Contact *)contact
{
  if (self = [super init]) {
    self.contact = contact;
  }
  return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *identifier = @"ARContactHeaderTableViewCell";
  ARContactHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[ARContactHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }
  cell.fullName = self.contact.fullName;
  cell.photoURL = self.contact.photoURL;

  return cell;
}

@end
