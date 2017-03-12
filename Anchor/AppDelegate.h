//
//  AppDelegate.h
//  Anchor
//
//  Created by Austen McDonald on 1/9/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDFileLogger;
@class ARFullContact;
@class ARKeyManager;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) DDFileLogger *fileLogger;
@property (nonatomic, strong) ARKeyManager *keyManager;


/**
 FullContact v3 API manager.
 */
@property (nonatomic, strong) ARFullContact *fullContact;

@property (nonnull, readonly, copy) NSString *redirectUri;

@end

