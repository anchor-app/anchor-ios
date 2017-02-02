//
//  AppDelegate.m
//  Anchor
//
//  Created by Austen McDonald on 1/9/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import "AppDelegate.h"

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "ARFullContact.h"
#import "ARUser.h"
#import "ARCalendarManager.h"
#import "ScheduleViewController.h"

NSString *CNGEDefaultsUserId = @"CNGEDefaultsUserId";

@interface AppDelegate () <PFLogInViewControllerDelegate>

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) ARCalendarManager *calendarManager;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Initialize Parse.
  [Parse enableLocalDatastore];
  [Parse initializeWithConfiguration:
   [ParseClientConfiguration
    configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
      configuration.applicationId = @"n8v4zJnqB3QQmcOQ0cvUDRlWOVSVzANTC9PNUUjd";
      configuration.clientKey = @"2TiAeZRQTAyr6OX8K0VsVuCSCTbVdjArUNPSQ9bS";
      configuration.server = @"https://pg-app-8hnin3szjcye8hhjecih9pxrjckzb2.scalabl.cloud/1/";
    }]];

  // Set up logging.
  [DDLog addLogger:[DDTTYLogger sharedInstance]];
  self.fileLogger = [[DDFileLogger alloc] init];
  self.fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
  self.fileLogger.logFileManager.maximumNumberOfLogFiles = 7;

  [DDLog addLogger:self.fileLogger];


  _calendarManager = [[ARCalendarManager alloc] init];

  UIViewController *scheduleController = [[ScheduleViewController alloc] initWithDate:[NSDate date] calendarManager:_calendarManager];
  _navigationController = [[UINavigationController alloc] initWithRootViewController:scheduleController];

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.rootViewController = _navigationController;
  [self.window makeKeyAndVisible];

  if (![PFUser currentUser]) {
    PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
    logInViewController.delegate = self;
    [_navigationController presentViewController:logInViewController animated:YES completion:nil];
  }

  return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
  if ([url.scheme isEqualToString:@"anchor-fullcontact"]) {
    if (!_fullContact) {
      DDLogError(@"Could not find instance of ARFullContact API manager while redirecting to handle authentication. This probably means app died in the background. Someone should fix this edge case.");
    }
    [_fullContact handleAuthenticationCallback:url];
    return YES;
  }
  return NO;
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
  DDLogInfo(@"User logged in: %@", user);
  
  [logInController dismissViewControllerAnimated:YES completion:nil];
}

- (ARFullContact *)fullContact
{
  if (!_fullContact) {
    ARUser *user = (ARUser *)[PFUser currentUser];
    if (user.fullContactClientId && user.fullContactClientSecret) {
      self.fullContact = [[ARFullContact alloc] initWithClientId:user.fullContactClientId
                                                    clientSecret:user.fullContactClientSecret
                                                     redirectURI:@"anchor-fullcontact://redirect"];
    }
  }
  return _fullContact;
}

@end
