//
//  AppDelegate.m
//  Carnegie
//
//  Created by Austen McDonald on 1/9/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import "AppDelegate.h"

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "CNGECalendarManager.h"
#import "ScheduleViewController.h"

NSString *CNGEDefaultsUserId = @"CNGEDefaultsUserId";

@interface AppDelegate () <PFLogInViewControllerDelegate>

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) CNGECalendarManager *calendarManager;

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
  DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
  fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
  fileLogger.logFileManager.maximumNumberOfLogFiles = 7;

  [DDLog addLogger:fileLogger];

  _calendarManager = [[CNGECalendarManager alloc] init];

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

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
  DDLogInfo(@"User logged in: %@", user);
  
  [logInController dismissViewControllerAnimated:YES completion:nil];
}

@end
