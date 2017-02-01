//
//  SettingsViewController.m
//  Anchor
//
//  Created by Austen McDonald on 1/17/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import "SettingsViewController.h"

#import <AFMInfoBanner/AFMInfoBanner.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <LSLogViewer/LSLogViewer.h>
#import <MessageUI/MessageUI.h>

#import "AppDelegate.h"
#import "ARUser.h"
#import "ARFullContact.h"

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

        [AFMInfoBanner showAndHideWithText:@"Successfully logged out" style:AFMInfoBannerStyleInfo];
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
      [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
      
      switch (indexPath.row) {
        case RowFullContactAuth:
        {
          ARUser *user = (ARUser *)[PFUser currentUser];
          [user fetch];

          if (!user.fullContactClientId || !user.fullContactClientSecret) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"You don't have a FullContact application client ID and/or secret attached to your Anchor user." preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];

            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];

            break;
          }
          // TODO: invert this dependency w/ some kind of provider map solution.
          AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
          [appDelegate.fullContact authenticateWithScope:@"contacts.read" completion:^(NSString *accessToken, NSString *refreshToken, NSError *error) {
            if (error) {
              DDLogError(@"Error authenticating with FullContact: %@", error);
              [AFMInfoBanner showAndHideWithText:@"Error authenticating with FullContact" style:AFMInfoBannerStyleError];
            } else {
              user.fullContactAccessToken = accessToken;
              user.fullContactResetToken = refreshToken;
              [user saveEventually];

              DDLogInfo(@"Successfully acquired FullContact accessToken(%@) refreshToken(%@)", accessToken, refreshToken);
              [AFMInfoBanner showAndHideWithText:@"Authenticated with FullContact" style:AFMInfoBannerStyleInfo];
            }
          }];
          break;
        }
      }
      break;
    }
      case SectionLogs:
    {
      switch (indexPath.row) {
          case RowLogsView:
        {
          [LSLogViewer showViewer];
          break;
        }
          case RowLogsEmail:
        {
          [self _emailLogs];
          break;
        }
      }
    }
    case SectionCache:
    {
      [self _clearCache];
    }
  }

  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSMutableArray *)_logData
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
  return logFiles;
}

- (void)_emailLogs
{
  if ([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    [mailViewController setSubject:@"Anchor ⚓️ Log Data" ];

    NSMutableData *allLogData = _.array([self _logData]).reduce([NSMutableData data], ^id (NSMutableData *memo, NSData *file) {
      [memo appendData:file];
      return memo;
    });
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

  [AFMInfoBanner showAndHideWithText:@"Cleared Local Caches" style:AFMInfoBannerStyleInfo];
  DDLogInfo(@"Cleared local caches");
}

@end
