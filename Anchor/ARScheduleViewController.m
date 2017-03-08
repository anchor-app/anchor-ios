//
//  ViewController.m
//  Anchor
//
//  Created by Austen McDonald on 1/9/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import "ARScheduleViewController.h"

#import <FontAwesomeKit/FontAwesomeKit.h>

#import "ARContactDetailViewController.h"
#import "ARContact.h"
#import "AREvent.h"
#import "ARSchedule.h"
#import "ARCalendarManager.h"
#import "ARSettingsViewController.h"
#import "ARDatePagingView.h"
#import "ARSingleSectionDataSource.h"
#import "AREventDataSource.h"
#import "ARSearchViewController.h"

@interface ARScheduleViewController () <UITableViewDelegate, UITableViewDataSource, ARDatePagingViewDelegate, ARSearchViewControllerDelegate>

@property (nonatomic, strong) ARCalendarManager *calendarManager;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ARSchedule *schedule;
@property (nonatomic, strong) NSMutableArray *dataSources;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UINavigationController *settingsController;
@property (nonatomic, strong) UINavigationController *searchController;
@property (nonatomic, strong) ARDatePagingView *datePagingView;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ARScheduleViewController

- (instancetype)initWithDate:(NSDate *)date calendarManager:(ARCalendarManager *)calendarManager
{
  if (self = [super init]) {
    self.calendarManager = calendarManager;
    self.date = date;
  }
  return self;
}

- (void)loadView {
  self.view = [[UIView alloc] initWithFrame:CGRectZero];

  self.loadingView = [[UIView alloc] initWithFrame:CGRectZero];
  _loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _loadingView.backgroundColor = [UIColor colorWithRed:239./255. green:239./255. blue:244./255. alpha:1.0];

  self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
  _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  _activityIndicatorView.color = [UIColor grayColor];
  [_activityIndicatorView setHidden:NO];
  [_loadingView addSubview:_activityIndicatorView];
  [self.view addSubview:_loadingView];

  self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:_tableView];

  self.datePagingView = [[ARDatePagingView alloc] initWithDate:self.date];
  _datePagingView.delegate = self;
  [self.view addSubview:self.datePagingView];
}

- (void)viewDidLayoutSubviews
{
  CGSize size = [self.datePagingView sizeThatFits:self.tableView.frame.size];
  self.datePagingView.frame = CGRectMake(0, self.topLayoutGuide.length, size.width, size.height);
  self.tableView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length + size.height, 0, 0, 0);

  _loadingView.frame = self.view.frame;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.title = @"Schedule";

  [self _setLoading:YES];

  FAKIonIcons *settingsIcon = [FAKIonIcons iosGearOutlineIconWithSize:25];
  UIImage *settingsImage = [settingsIcon imageWithSize:CGSizeMake(25, 25)];
  UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:settingsImage style:UIBarButtonItemStylePlain target:self action:@selector(_handleSettings)];
  self.navigationItem.leftBarButtonItem = settingsButton;

  FAKIonIcons *searchIcon = [FAKIonIcons iosSearchIconWithSize:25];
  UIImage *searchImage = [searchIcon imageWithSize:CGSizeMake(25, 25)];
  UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithImage:searchImage style:UIBarButtonItemStylePlain target:self action:@selector(_handleSearch)];
  self.navigationItem.rightBarButtonItem = searchButton;

}

- (void)_handleSettings
{
  if (!_settingsController) {
    ARSettingsViewController *s = [[ARSettingsViewController alloc] init];
    _settingsController = [[UINavigationController alloc] initWithRootViewController:s];
  }
  [self presentViewController:_settingsController animated:YES completion:nil];
}

- (void)_handleSearch
{
  if (!_searchController) {
    ARSearchViewController *s = [[ARSearchViewController alloc] init];
    s.delegate = self;
    _searchController = [[UINavigationController alloc] initWithRootViewController:s];

    s.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(_handleSearchCancel)];
  }
  [self presentViewController:_searchController animated:YES completion:nil];
}

- (void)_handleSearchCancel
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return _dataSources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_dataSources[section] tableView:tableView numberOfRowsInSection:0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [_dataSources[indexPath.section] tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return [_dataSources[section] tableView:tableView titleForHeaderInSection:0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [_dataSources[indexPath.section] tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)setDate:(NSDate *)date
{
  NSCalendar *calendar = [NSCalendar currentCalendar];
  if (!_date || ![calendar isDate:date equalToDate:_date toUnitGranularity:NSCalendarUnitDay]) {
    _date = date;

    [self _setLoading:YES];

    // Kick off request to fetch schedule.
    [[_calendarManager asyncFetchScheduleWithDate:_date] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
      if (t.error) {
        DDLogError(@"Loading schedule for date %@ failed: %@", _date, t.error);
        return nil;
      }
      DDLogInfo(@"Loaded schedule for date %@: events(%lu) contacts(%lu)", _date, (unsigned long)_schedule.events.count, (unsigned long)_schedule.contacts.count);

      dispatch_async(dispatch_get_main_queue(), ^{
        self.schedule = t.result;
        [self _setLoading:NO];
      });
      return nil;
    }];
  }
}

- (void)_setLoading:(BOOL)loading
{
  if (loading) {
    [_tableView setHidden:YES];
    [_activityIndicatorView startAnimating];
  } else {
    [_tableView setContentOffset:CGPointMake(0, -_tableView.contentInset.top) animated:NO];
    [_tableView setHidden:NO];
    [_activityIndicatorView stopAnimating];
  }
}

- (void)datePagingView:(ARDatePagingView *)view didChangeToDate:(NSDate *)date
{
  self.date = date;
}

- (void)setSchedule:(ARSchedule *)schedule
{
  if (_schedule != schedule) {
    _schedule = schedule;

    // Generate the next set of datasources.
    _dataSources = [NSMutableArray arrayWithArray:_.array(_schedule.events).map(^id(AREvent * event) {
      AREventDataSource *ds = [[AREventDataSource alloc] initWithEvent:event date:_date navigationController:self.navigationController];
      return ds;
    }).unwrap];

    [_tableView reloadData];
  }
}

- (void)searchViewController:(ARSearchViewController *)viewController didSelectContactId:(NSString *)contactId forViewModel:(ARSearchViewModel *)viewModel
{
  // Dismiss search controller.
  [self dismissViewControllerAnimated:YES completion:nil];

  PFQuery *query = [PFQuery queryWithClassName:@"Contact"];
  [query getObjectInBackgroundWithId:contactId block:^(PFObject *contact, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      ARContactDetailViewController *vc = [[ARContactDetailViewController alloc] initWithContact:(ARContact *)contact date:_date];
      [self.navigationController pushViewController:vc animated:YES];
    });
  }];
}

@end
