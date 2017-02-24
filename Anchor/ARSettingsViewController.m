//
//  ARSettingsViewController.m
//  Anchor
//
//  Created by Austen McDonald on 1/17/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import "ARSettingsViewController.h"

#import <AFMInfoBanner/AFMInfoBanner.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <MessageUI/MessageUI.h>

#import "AppDelegate.h"
#import "ARUser.h"
#import "ARFullContact.h"
#import "ARLogViewerViewController.h"
#import "ARIntegrationsSettingsViewController.h"

NS_ENUM(NSInteger) {
  SectionLogin,
  SectionIntegrations,
  SectionCache,
  SectionLogs,
  SectionCount,
};

NS_ENUM(NSInteger) {
  RowIntegrations,
  RowIntegrationsCount,
};

NS_ENUM(NSInteger) {
  RowLogin,
  RowLoginCount,
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

@interface ARSettingsViewController () <PFLogInViewControllerDelegate, MFMailComposeViewControllerDelegate>

@end

@implementation ARSettingsViewController

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

  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_handleDone)];
}

- (void)_handleDone
{
  [self dismissViewControllerAnimated:YES completion:nil];
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
      case SectionIntegrations:
    {
      return RowIntegrationsCount;
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

- (void)_configureIntegrationsCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
  cell.textLabel.textAlignment = NSTextAlignmentCenter;
  cell.textLabel.text = @"Manage Integrations";
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)_configureCacheSectionCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
  cell.textLabel.textAlignment = NSTextAlignmentCenter;
  cell.accessoryType = UITableViewCellAccessoryNone;
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
  cell.accessoryType = UITableViewCellAccessoryNone;
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
  NSString *identifier = @"ARSettingsViewControllerCell";
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
      case SectionIntegrations:
    {
      [self _configureIntegrationsCell:cell forRow:indexPath.row];
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

        [AFMInfoBanner showAndHideWithText:@"Successfully logged out" style:AFMInfoBannerStyleInfo];
        [self.tableView reloadData];
      } else {
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        logInViewController.delegate = self;
        [self.navigationController presentViewController:logInViewController animated:YES completion:nil];
      }
      break;
    }
      case SectionIntegrations:
    {
      [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

      ARIntegrationsSettingsViewController *vc = [[ARIntegrationsSettingsViewController alloc] init];
      [self.navigationController pushViewController:vc animated:YES];
      break;
    }
      case SectionLogs:
    {
      switch (indexPath.row) {
          case RowLogsView:
        {
          NSData *logData = [self _logData];
          NSString *logString = [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding];

          ARLogViewerViewController *vc = [[ARLogViewerViewController alloc] initWithLogs:logString];
          [self.navigationController pushViewController:vc animated:YES];
          break;
        }
          case RowLogsEmail:
        {
          [self _emailLogs];
          break;
        }
      }
      break;
    }
    case SectionCache:
    {
      [self _clearCache];
      [AFMInfoBanner showAndHideWithText:@"Cleared Local Caches" style:AFMInfoBannerStyleInfo];
      break;
    }
  }

  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSData *)_logData
{
  NSMutableArray *logFiles = [NSMutableArray array];

  // TODO: invert this dependency w/ some kind of provider map solution.
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  DDFileLogger *logger = appDelegate.fileLogger;
  NSArray *sortedLogFileInfos = [logger.logFileManager sortedLogFileInfos];
  for (DDLogFileInfo *info in sortedLogFileInfos) {
    NSData *fileData = [NSData dataWithContentsOfFile:info.filePath];
    [logFiles addObject:fileData];
  }

  return _.array(logFiles).reduce([NSMutableData data], ^id (NSMutableData *memo, NSData *file) {
    [memo appendData:file];
    return memo;
  });
}

- (void)_emailLogs
{
  if ([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    [mailViewController setSubject:@"Anchor ⚓️ Log Data" ];

    NSData *allLogData = [self _logData];
    [mailViewController addAttachmentData:allLogData mimeType:@"text/plain" fileName:@"logs.txt"];

    [self presentViewController:mailViewController animated:YES completion:nil];
  } else {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Looks like email is not set up on this device." preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
  }
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
  [logInController dismissViewControllerAnimated:YES completion:nil];

  [AFMInfoBanner showAndHideWithText:@"Successfully logged in" style:AFMInfoBannerStyleInfo];
  [self.tableView reloadData];
}

- (void)_clearCache
{
  [PFQuery clearAllCachedResults];
  DDLogInfo(@"Cleared local caches");
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
