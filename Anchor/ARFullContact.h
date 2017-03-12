//
//  ARFullContact.h
//  Anchor
//
//  Created by Austen McDonald on 1/20/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFTask;

/**
 Helper to connect to the FullContact API, version 3. See https://api.fullcontact.com/v3/docs/
 */
@interface ARFullContact : NSObject


/**
 Construct a new ARFullContact API manager.

 @return A new ARFullContact.
 */
- (instancetype)init;

/**
 Call this method when you receive a callback to the URL you specified when you initialized the class.
 Be sure to call this on the same instance as the one you called `authenticateWithCompletion:` on.

 @param url URL opened by FullContact in its callback sequence.
 */
- (void)handleAuthenticationCallback:(NSURL *)url;

/**
 Authenticate against the FullContact v3.0 OAuth API (see https://api.fullcontact.com/v3/docs/authentication/), objtaining an access token and refresh token. This is a two step process.

 First, this will redirect the user to Safari to login with their FullContact credentials and when the
 login is complete, it expects this app to respond to the callback URL provided in the initializer.
 When responding to that URL, call `handleAuthenticationCallback:` on the same instance you called `authenticateWithCompletion:`.
 
 Second, it will take the code it receives from the redirect URL to retrieve a token pair from FullContact.

 @param clientId String with client identifier, from FullContact. It is recommended you do not ship this string with the app, but instead pull it from the server in some way. In this app, we use `ARUser.fullContactClientId`
 @param clientSecret String with client secret, from FullContact. It is recommended you do not ship this string with the app, but instead pull it from the server in some way. In this app, we use `ARUser.fullContactClientSecret`.
 @param redirectUri String with the same URI you specified when you registered the FullContact app. Be sure this iOS app is registering this URL scheme in its Info.plist.
 @param scope Comma delimited string specifying access scopes, see https://api.fullcontact.com/v3/docs/scopes/
 */
- (BFTask *)authenticateWithScope:(NSString *)scope clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret redirectUri:(NSString *)redirectUri;

/**
 Reset the access token according to https://api.fullcontact.com/v3/docs/authentication/
 
 @param refreshToken String with refresh token, acquired from a previous authentication.
 @param clientId String with client identifier, from FullContact. It is recommended you do not ship this string with the app, but instead pull it from the server in some way. In this app, we use `ARUser.fullContactClientId`
 @param clientSecret String with client secret, from FullContact. It is recommended you do not ship this string with the app, but instead pull it from the server in some way. In this app, we use `ARUser.fullContactClientSecret`.
 */
- (BFTask *)refreshAccessTokenUsingRefreshToken:(NSString *)refreshToken clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;

/**
 Create a FullContact contact with the provided data. Does not create an Anchor Contact.
 */
- (BFTask *)addNewContactWithFullName:(NSString *)fullName accessToken:(NSString *)token;

@end
