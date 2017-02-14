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
#import "AREventViewModel.h"

@interface AREventDataSource ()

@property (nonatomic, strong) AREvent *event;
@property (nonatomic, strong) AREventViewModel *viewModel;
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

    self.viewModel = [[AREventViewModel alloc] initWithEvent:_event];

    self.startTimeFormatter = [[NSDateFormatter alloc] init];
    [self.startTimeFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.startTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
  }
  return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _viewModel.eventSubItemViewModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *identifier = @"ARScheduleViewControllerContactCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }

  AREventSubItemViewModel *vm = _viewModel.eventSubItemViewModels[indexPath.row];

  switch (vm.type) {
    case AREventSubItemViewModelTypeContact:
      cell.textLabel.text = vm.contact.fullName;
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      break;
    case AREventSubItemViewModelTypeNewContact:
      cell.textLabel.text = vm.contact.emails[0];
      cell.accessoryType = UITableViewCellAccessoryNone;
      break;
    case AREventSubItemViewModelTypeCollapseButton:
      cell.textLabel.text = @"See Less Unknown Contacts";
      cell.accessoryType = UITableViewCellAccessoryNone;
      break;
    case AREventSubItemViewModelTypeExpandButton:
      cell.textLabel.text = @"See More Unknown Contacts";
      cell.accessoryType = UITableViewCellAccessoryNone;
      break;
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
  AREventSubItemViewModel *vm = _viewModel.eventSubItemViewModels[indexPath.row];

  switch (vm.type) {
    case AREventSubItemViewModelTypeContact:
    {
      ARContactDetailViewController *vc = [[ARContactDetailViewController alloc] initWithContact:vm.contact date:_date];
      [_navigationController pushViewController:vc animated:YES];
      break;
    }
    case AREventSubItemViewModelTypeNewContact:
      break;
    case AREventSubItemViewModelTypeCollapseButton:
      _viewModel.state = AREventViewModelStateCollapsed;
      [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
      break;
    case AREventSubItemViewModelTypeExpandButton:
      _viewModel.state = AREventViewModelStateExpanded;
      [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

@end
