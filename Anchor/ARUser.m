//
//  ARUser.m
//  Anchor
//
//  Created by Austen McDonald on 1/20/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import "ARUser.h"

@implementation ARUser

@dynamic fullContactClientId;
@dynamic fullContactClientSecret;
@dynamic fullContactResetToken;
@dynamic fullContactAccessToken;

+ (void)load
{
  [self registerSubclass];
}

@end
