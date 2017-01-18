//
//  SettingsViewController.m
//  Carnegie
//
//  Created by Austen McDonald on 1/17/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import "SettingsViewController.h"

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

NS_ENUM(NSInteger) {
  SectionLogin,
  SectionFullContact,
  SectionCache,
  SectionLogs,
  SectionCount,
};

NS_ENUM(NSInteger) {
  RowLogin,
  RowLoginCount,
};

NS_ENUM(NSInteger) {
  RowFullContactAuth,
  RowFullContactSync,
  RowFullContactCount,
};

NS_ENUM(NSInteger) {
  RowCacheClear,
  RowCacheCount,
};

NS_ENUM(NSInteger) {
  RowLogsView,
  RowLogsEmail,
  RowLogsCount,
};

@interface SettingsViewController () <PFLogInViewControllerDelegate>

@end

@implementation SettingsViewController

- (instancetype)init
{
  if (self = [super initWithStyle:UITableViewStyleGrouped]) {
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.title = @"Settings";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section) {
      case SectionLogin:
    {
      return RowLoginCount;
    }
      case SectionFullContact:
    {
      return RowFullContactCount;
    }
      case SectionCache:
    {
      return RowCacheCount;
    }
      case SectionLogs:
    {
      return RowLogsCount;
    }
  }
  return 0;
}

- (void)_configureLoginSectionCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
  cell.textLabel.textAlignment = NSTextAlignmentCenter;
  switch (row) {
      case RowLogin:
    {
      if (PFUser.currentUser) {
        cell.textLabel.text = PFUser.currentUser.username;
      } else {
        cell.textLabel.text = @"Login";
      }
      break;
    }
  }
}

- (void)_configureFullContactSectionCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
  cell.textLabel.textAlignment = NSTextAlignmentCenter;
  switch (row) {
      case RowFullContactAuth:
    {
      cell.textLabel.text = @"Authorize Full Contact";
      break;
    }
      case RowFullContactSync:
    {
      cell.textLabel.text = @"Sync Contacts";
      break;
    }
  }
}

- (void)_configureCacheSectionCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
  cell.textLabel.textAlignment = NSTextAlignmentCenter;
  switch (row) {
      case RowCacheClear:
    {
      cell.textLabel.text = @"Clear Local Caches";
      break;
    }
  }
}

- (void)_configureLogsSectionCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
  cell.textLabel.textAlignment = NSTextAlignmentCenter;
  switch (row) {
      case RowLogsView:
    {
      cell.textLabel.text = @"View Logs";
      break;
    }
      case RowLogsEmail:
    {
      cell.textLabel.text = @"Email Logs";
      break;
    }
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *identifier = @"SettingsViewControllerCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }

  switch (indexPath.section) {
      case SectionLogin:
    {
      [self _configureLoginSectionCell:cell forRow:indexPath.row];
      break;
    }
      case SectionFullContact:
    {
      [self _configureFullContactSectionCell:cell forRow:indexPath.row];
      break;
    }
      case SectionCache:
    {
      [self _configureCacheSectionCell:cell forRow:indexPath.row];
      break;
    }
      case SectionLogs:
    {
      [self _configureLogsSectionCell:cell forRow:indexPath.row];
      break;
    }
  }
    
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch (indexPath.section) {
      case SectionLogin:
    {
      if (PFUser.currentUser) {
        [PFUser logOut];
        [self.tableView reloadData];
      } else {
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        logInViewController.delegate = self;
        [self.navigationController presentViewController:logInViewController animated:YES completion:nil];
      }
      break;
    }
      case SectionFullContact:
    {
//      AMFullContact *fullContact = [[AMFullContact alloc] initWithClientId:clientId clientSecret:clientSecret redirectURI:redirect];
//      [fullContact authenticateWithCompletion:^(NSString *accessToken, NSString *refreshToken, NSError *error) {
//
//      }];
      break;
    }
  }
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
  [logInController dismissViewControllerAnimated:YES completion:nil];
  [self.tableView reloadData];
}

@end
