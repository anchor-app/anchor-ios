//
//  AREventDataSource.m
//  Anchor
//
//  Created by Austen McDonald on 2/13/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "AREventDataSource.h"

#import "AREvent.h"
#import "ARContact.h"
#import "ARContactDetailViewController.h"

@interface AREventDataSource ()

@property (nonatomic, strong) AREvent *event;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) NSDateFormatter *startTimeFormatter;

@end

@implementation AREventDataSource

- (instancetype)initWithEvent:(AREvent *)event date:(NSDate *)date navigationController:(UINavigationController *)navigationController
{
  if (self = [super init]) {
    self.event = event;
    self.date = date;
    self.navigationController = navigationController;

    self.startTimeFormatter = [[NSDateFormatter alloc] init];
    [self.startTimeFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.startTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
  }
  return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _event.participants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *identifier = @"ARScheduleViewControllerContactCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }

  ARContact *participant = _event.participants[indexPath.row];

  if (participant.createdAt == nil) {
    cell.textLabel.text = participant.emails[0];
    cell.accessoryType = UITableViewCellAccessoryNone;
  } else {
    cell.textLabel.text = participant.fullName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }

  return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  NSTimeInterval duration = [_event.underlyingEvent.endDate timeIntervalSinceDate:_event.underlyingEvent.startDate];
  NSString *title = [NSString stringWithFormat:@"%@ (%ld min) %@",
                     [_startTimeFormatter stringFromDate:_event.underlyingEvent.startDate],
                     (long)(duration / 60),
                     _event.underlyingEvent.title];
  return title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  ARContact *participant = _event.participants[indexPath.row];

  if (participant.createdAt != nil) {
    ARContactDetailViewController *vc = [[ARContactDetailViewController alloc] initWithContact:participant date:_date];
    [_navigationController pushViewController:vc animated:YES];
  }
}

@end
