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
@dynamic teamId;

+ (void)load
{
  [self registerSubclass];
}

- (void)setPermissionsForObject:(PFObject *)object
{
  PFACL *acl = [PFACL ACLWithUser:self];

  if (self.teamId) {
    [acl setReadAccess:true forRoleWithName:self.teamId];
    [acl setWriteAccess:true forRoleWithName:self.teamId];
  }

  object.ACL = acl;
}

@end
