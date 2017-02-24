//
//  ARFullContact.m
//  Anchor
//
//  Created by Austen McDonald on 1/20/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import "ARFullContact.h"

#import <AFNetworking.h>
#import "NSURL+QueryDictionary.h"

@interface ARFullContact ()

@property (nonatomic, copy) NSString *redirectURI;

@property (nonatomic, strong) NSMutableDictionary<NSString *, ARFullContactAuthenticationCompletionBlock> *authenticationAttempts;

@end

@implementation ARFullContact

- (instancetype)initWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret redirectURI:(NSString *)redirectURI
{
  if (self = [super init]) {
    self.clientId = clientId;
    self.clientSecret = clientSecret;
    self.redirectURI = redirectURI;

    self.authenticationAttempts = [NSMutableDictionary dictionary];

    // Make sure the user didnt provide us a URI with state= query string already :)
    NSURL *url = [NSURL URLWithString:self.redirectURI];
    NSDictionary *query = [url uq_queryDictionary];
    NSAssert(query[@"state"] == nil, @"Do not provide a FullContact redirect string with a state parameter already set.");
  }

  return self;
}

- (void)authenticateWithScope:(NSString *)scope completion:(ARFullContactAuthenticationCompletionBlock)completion
{
  NSURL *url = [NSURL URLWithString:@"https://app.fullcontact.com/oauth/authorize"];

  NSString *state = [[NSProcessInfo processInfo] globallyUniqueString];

  url = [url uq_URLByAppendingQueryDictionary:@{
                                                @"client_id": _clientId,
                                                @"redirect_uri": _redirectURI,
                                                @"response_type": @"code",
                                                @"scope": scope,
                                                @"state": state,
                                                }];
  DDLogInfo(@"Authenticating with FullContact, starting with URL %@", url);

  _authenticationAttempts[state] = completion;
  [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (void)handleAuthenticationCallback:(NSURL *)url
{
  NSDictionary *query = [url uq_queryDictionary];
  NSString *state = query[@"state"];
  NSString *code = query[@"code"];

  if (!state) {
    DDLogError(@"Couldn't find a state parameter value in URL %@. Cannot proceed with FullContact authentication request.", url);
    return;
  }
  if (!_authenticationAttempts[state]) {
    DDLogError(@"Couldn't find a valid authentication attempt to match URL %@. Cannot proceed with FullContact authentication request.", url);
    return;
  }
  ARFullContactAuthenticationCompletionBlock block = _authenticationAttempts[state];

  if (!code) {
    NSString *desc = [NSString stringWithFormat:@"FullContact redirect URL %@ did not contain the necessary 'code' parameter. Cannot complete authenticaion request.", url];
    block(nil, nil, [NSError errorWithDomain:@"com.rdhjr.anchor" code:500 userInfo:@{ NSLocalizedDescriptionKey: desc }]);
    return;
  }


  // Call FullContact's oauth.exchangeAuthCode method to get an access token and refresh token.
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

  NSDictionary *parameters = @{
                               @"code": code,
                               @"client_id": _clientId,
                               @"client_secret": _clientSecret,
                               @"redirect_uri": _redirectURI,
                               };

  [manager POST:@"https://api.fullcontact.com/v3/oauth.exchangeAuthCode" parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
      NSDictionary *dict = (NSDictionary *)responseObject;
      NSString *accessToken = dict[@"access_token"];
      NSString *refreshToken = dict[@"refresh_token"];
      block(accessToken, refreshToken, nil);
    } else {
      NSString *desc = [NSString stringWithFormat:@"FullContact returned a strange object on authentication: %@", responseObject];
      block(nil, nil, [NSError errorWithDomain:@"com.rdhjr.anchor" code:500 userInfo:@{ NSLocalizedDescriptionKey: desc }]);
    }
  } failure:^(NSURLSessionTask *operation, NSError *error) {
    block(nil, nil, error);
  }];
}

- (NSString *)_redirectURIWithState:(NSString *)state
{
  NSURL *url = [NSURL URLWithString:_redirectURI];
  url = [url uq_URLByAppendingQueryDictionary:@{ @"state": state }];
  return [url absoluteString];
}

@end
