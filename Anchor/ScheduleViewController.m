//
//  ViewController.m
//  Anchor
//
//  Created by Austen McDonald on 1/9/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import "ScheduleViewController.h"

#import <FontAwesomeKit/FontAwesomeKit.h>

#import "ARContactDetailViewController.h"
#import "Contact.h"
#import "Event.h"
#import "Schedule.h"
#import "CNGECalendarManager.h"
#import "SettingsViewController.h"

@interface ScheduleViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CNGECalendarManager *calendarManager;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) Schedule *schedule;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDateFormatter *startTimeFormatter;
@property (nonatomic, strong) UINavigationController *settingsController;

@end

@implementation ScheduleViewController

- (instancetype)initWithDate:(NSDate *)date calendarManager:(CNGECalendarManager *)calendarManager
{
  if (self = [super init]) {
    self.date = date;
    self.calendarManager = calendarManager;

    self.startTimeFormatter = [[NSDateFormatter alloc] init];
    [self.startTimeFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.startTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
  }
  return self;
}

- (void)loadView {
  self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;

  self.view = self.tableView;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.title = @"Schedule";

  FAKIonIcons *settingsIcon = [FAKIonIcons iosGearOutlineIconWithSize:25];
  UIImage *settingsImage = [settingsIcon imageWithSize:CGSizeMake(25, 25)];
  UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:settingsImage style:UIBarButtonItemStylePlain target:self action:@selector(_handleSettings)];
  self.navigationItem.leftBarButtonItem = settingsButton;

  // Kick off request to fetch schedule.
  [[self.calendarManager asyncFetchScheduleWithDate:self.date] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
    if (t.error) {
      DDLogError(@"Loading schedule for date %@ failed: %@", self.date, t.error);
      return nil;
    }
    DDLogInfo(@"Loaded schedule for date %@: events(%lu) contacts(%lu)", self.date, self.schedule.events.count, (unsigned long)self.schedule.contacts.count);

    dispatch_async(dispatch_get_main_queue(), ^{
      self.schedule = t.result;
      [self.tableView reloadData];
    });
    return nil;
  }];
}

- (void)_handleSettings
{
  if (!_settingsController) {
    SettingsViewController *s = [[SettingsViewController alloc] init];
    _settingsController = [[UINavigationController alloc] initWithRootViewController:s];
  }
  [self presentViewController:_settingsController animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return _schedule.events.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  Event *e = [_schedule.events objectAtIndex:section];
  return e.participants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *identifier = @"ScheduleViewControllerContactCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }

  Event *event = [_schedule.events objectAtIndex:indexPath.section];
  NSString *email = [event emailAtIndex:indexPath.row];
  id contactOrNull = [event contactOrNullAtIndex:indexPath.row];

  if ([contactOrNull isEqual:[NSNull null]]) {
    cell.textLabel.text = email;
    cell.accessoryType = UITableViewCellAccessoryNone;
  } else {
    Contact *contact = (Contact *)contactOrNull;
    cell.textLabel.text = contact.fullName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }

  return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  Event *e = [_schedule.events objectAtIndex:section];

  NSTimeInterval duration = [e.underlyingEvent.endDate timeIntervalSinceDate:e.underlyingEvent.startDate];
  NSString *title = [NSString stringWithFormat:@"%@ (%ld min) %@",
                     [self.startTimeFormatter stringFromDate:e.underlyingEvent.startDate],
                     (long)(duration / 60),
                     e.underlyingEvent.title];
  return title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  Event *event = [_schedule.events objectAtIndex:indexPath.section];
  id contactOrNull = [event contactOrNullAtIndex:indexPath.row];

  if (![contactOrNull isEqual:[NSNull null]]) {
    Contact *contact = (Contact *)contactOrNull;
    ARContactDetailViewController *vc = [[ARContactDetailViewController alloc] initWithContact:contact];
    [self.navigationController pushViewController:vc animated:YES];
  }
}

@end
