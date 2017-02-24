//
//  ARFullContactDataSource.m
//  Anchor
//
//  Created by Austen McDonald on 2/21/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARFullContactDataSource.h"

#import <AFMInfoBanner/AFMInfoBanner.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "ARUser.h"
#import "AppDelegate.h"
#import "ARFullContact.h"

typedef NS_ENUM(NSInteger) {
  ARFullContactDataSourceRowClientId,
  ARFullContactDataSourceRowClientSecret,
  ARFullContactDataSourceRowAuth,
  ARFullContactDataSourceRowSync,
  ARFullContactDataSourceRowLogout,
} ARFullContactDataSourceRowType;

const NSInteger ARFullContactDataSourceTextFieldTag = 42;
const NSString *ARFullContactDataSourceTextFieldId = @"ARFullContactDataSourceTextFieldId";
NSString *ARFullContactDataSourceTextFieldIdClientId = @"ARFullContactDataSourceTextFieldIdClientId";
NSString *ARFullContactDataSourceTextFieldIdClientSecret = @"ARFullContactDataSourceTextFieldIdClientSecret";

@interface ARFullContactDataSource ()

@property (nonatomic, strong) NSArray *rows;

@end

@implementation ARFullContactDataSource

- (instancetype)init
{
  if (self = [super init]) {
    self.rows = [self _rowsForCurrentState];
  }
  return self;
}

- (NSArray *)_rowsForCurrentState
{
  NSMutableArray *result = [NSMutableArray array];

  ARUser *user = (ARUser *)[PFUser currentUser];

  [result addObject:@(ARFullContactDataSourceRowClientId)];
  [result addObject:@(ARFullContactDataSourceRowClientSecret)];

  if (user.fullContactAccessToken) {
    [result addObject:@(ARFullContactDataSourceRowSync)];
    [result addObject:@(ARFullContactDataSourceRowLogout)];
  } else {
    [result addObject:@(ARFullContactDataSourceRowAuth)];
  }

  return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _rows.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return @"FullContact";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  ARUser *user = (ARUser *)[PFUser currentUser];

  NSString *identifier = @"ARFullContactDataSource";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height)];
    field.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    field.textAlignment = NSTextAlignmentCenter;
    field.font = [UIFont fontWithName:@"Menlo-Regular" size:12];
    field.tag = ARFullContactDataSourceTextFieldTag;
    [field addTarget:self action:@selector(_onTextFieldChange:) forControlEvents:UIControlEventEditingChanged];
    [cell.contentView addSubview:field];
  }

  NSNumber *row = _rows[indexPath.row];
  ARFullContactDataSourceRowType type = (ARFullContactDataSourceRowType)row.integerValue;

  switch (type) {
    case ARFullContactDataSourceRowClientId:
    {
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      UITextField *tf = [cell viewWithTag:ARFullContactDataSourceTextFieldTag];
      objc_setAssociatedObject(tf, (__bridge const void *)(ARFullContactDataSourceTextFieldId), ARFullContactDataSourceTextFieldIdClientId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
      tf.hidden = NO;
      tf.placeholder = @"Client App ID";
      tf.text = user.fullContactClientId;
      break;
    }
    case ARFullContactDataSourceRowClientSecret:
    {
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      UITextField *tf = [cell viewWithTag:ARFullContactDataSourceTextFieldTag];
      objc_setAssociatedObject(tf, (__bridge const void *)(ARFullContactDataSourceTextFieldId), ARFullContactDataSourceTextFieldIdClientSecret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
      tf.hidden = NO;
      tf.placeholder = @"Client App Secret";
      tf.text = user.fullContactClientSecret;
      break;
    }
    case ARFullContactDataSourceRowAuth:
      cell.selectionStyle = UITableViewCellSelectionStyleDefault;
      [cell viewWithTag:ARFullContactDataSourceTextFieldTag].hidden = YES;
      cell.textLabel.textAlignment = NSTextAlignmentCenter;
      cell.textLabel.text = @"Authorize FullContact";
      break;
    case ARFullContactDataSourceRowSync:
      cell.selectionStyle = UITableViewCellSelectionStyleDefault;
      [cell viewWithTag:ARFullContactDataSourceTextFieldTag].hidden = YES;
      cell.textLabel.textAlignment = NSTextAlignmentCenter;
      cell.textLabel.text = @"Sync Contacts";
      break;
    case ARFullContactDataSourceRowLogout:
      cell.selectionStyle = UITableViewCellSelectionStyleDefault;
      [cell viewWithTag:ARFullContactDataSourceTextFieldTag].hidden = YES;
      cell.textLabel.textAlignment = NSTextAlignmentCenter;
      cell.textLabel.text = @"Logout of FullContact";
      break;
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  NSNumber *row = _rows[indexPath.row];
  ARFullContactDataSourceRowType type = (ARFullContactDataSourceRowType)row.integerValue;

  switch (type) {
    case ARFullContactDataSourceRowClientId:
      break;
    case ARFullContactDataSourceRowClientSecret:
      break;
    case ARFullContactDataSourceRowAuth:
      [self _handleAuth];
      break;
    case ARFullContactDataSourceRowSync:
      [self _handleSync];
      break;
    case ARFullContactDataSourceRowLogout:
      [self _handleLogout];
      break;
  }
}

- (void)_handleAuth
{
  ARUser *user = (ARUser *)[PFUser currentUser];

  if (!user.fullContactClientId.length || !user.fullContactClientSecret.length) {
    [AFMInfoBanner showAndHideWithText:@"You need a FullContact client ID and secret." style:AFMInfoBannerStyleError];
  } else {
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

        dispatch_async(dispatch_get_main_queue(), ^{
          self.rows = [self _rowsForCurrentState];
          [_delegate dataSourceDataChanged:self];
        });
      }
    }];
  }
}

- (void)_handleSync
{
  DDLogInfo(@"Syncing FullContact contacts...");
  [PFCloud callFunctionInBackground:@"sync" withParameters:nil block:^(NSString *message, NSError * _Nullable error) {
    if (error) {
      DDLogError(@"Error syncing FullContact contacts: %@", error);
      [AFMInfoBanner showAndHideWithText:@"Error Syncing Contacts" style:AFMInfoBannerStyleError];
    } else {
      [AFMInfoBanner showAndHideWithText:message style:AFMInfoBannerStyleInfo];
    }
  }];
}

- (void)_handleLogout
{
  DDLogInfo(@"Logging out of FullContact...");
  ARUser *user = (ARUser *)[PFUser currentUser];
  user.fullContactResetToken = nil;
  user.fullContactAccessToken = nil;
  user.fullContactClientId = nil;
  user.fullContactClientSecret = nil;
  [user saveEventually];

  [AFMInfoBanner showAndHideWithText:@"Successfully logged out of FullContact." style:AFMInfoBannerStyleInfo];

  self.rows = [self _rowsForCurrentState];
  [_delegate dataSourceDataChanged:self];
}

- (void)_onTextFieldChange:(UITextField *)sender
{
  ARUser *user = (ARUser *)[PFUser currentUser];

  NSString *type = objc_getAssociatedObject(sender, (__bridge const void *)(ARFullContactDataSourceTextFieldId));

  if ([type isEqualToString:ARFullContactDataSourceTextFieldIdClientId]) {
    user.fullContactClientId = sender.text;
  } else if ([type isEqualToString:ARFullContactDataSourceTextFieldIdClientSecret]) {
    user.fullContactClientSecret = sender.text;
  }

  [user saveEventually];
}

@end
