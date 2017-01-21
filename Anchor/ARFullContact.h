//
//  ARFullContact.h
//  Anchor
//
//  Created by Austen McDonald on 1/20/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ARFullContactAuthenticationCompletionBlock)(NSString *accessToken, NSString *refreshToken, NSError *error);

/**
 Helper to connect to the FullContact API, version 3. See https://api.fullcontact.com/v3/docs/
 */
@interface ARFullContact : NSObject


/**
 Construct a new ARFullContact API manager. This method needs configuration values you created
 when you register your application with FullContact

 @param clientId String with client identifier, from FullContact. It is recommended you do not ship this string with the app, but instead pull it from the server in some way. In this app, we use `ARUser.fullContactClientId`
 @param clientSecret String with client secret, from FullContact. It is recommended you do not ship this string with the app, but instead pull it from the server in some way. In this app, we use `ARUser.fullContactClientSecret`.
 @param redirectURI String with the same URI you specified when you registered the FullContact app. Be sure this iOS app is registering this URL scheme in its Info.plist.
 @return A new ARFullContact.
 */
- (instancetype)initWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret redirectURI:(NSString *)redirectURI;

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
 
 Second, it will take the code it receives from the redirect URL to retrieve a token pair from FullContact. Then it will call the provided completion block.

 @param scope Comma delimited string specifying access scopes, see https://api.fullcontact.com/v3/docs/scopes/
 @param completion Block to run when authentication operation completes.
 */
- (void)authenticateWithScope:(NSString *)scope completion:(ARFullContactAuthenticationCompletionBlock)completion;

@end
