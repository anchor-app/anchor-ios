//
//  ARFullContact.m
//  Anchor
//
//  Created by Austen McDonald on 1/20/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import "ARFullContact.h"

#import <AFNetworking.h>
#import <Bolts/Bolts.h>
#import "NSURL+QueryDictionary.h"

@interface ARFullContact ()

@property (nonatomic, copy) NSString *redirectURI;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *authenticationAttempts;

@end

@implementation ARFullContact

- (instancetype)init
{
  if (self = [super init]) {
    self.authenticationAttempts = [NSMutableDictionary dictionary];
  }

  return self;
}

- (BFTask *)authenticateWithScope:(NSString *)scope clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret redirectUri:(NSString *)redirectUri
{
  BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];

  // Make sure the user didnt provide us a URI with state= query string already :)
  NSURL *redirectUrl = [NSURL URLWithString:redirectUri];
  NSDictionary *query = [redirectUrl uq_queryDictionary];
  NSAssert(query[@"state"] == nil, @"Do not provide a FullContact redirect string with a state parameter already set.");

  NSURL *url = [NSURL URLWithString:@"https://app.fullcontact.com/oauth/authorize"];

  NSString *state = [[NSProcessInfo processInfo] globallyUniqueString];

  url = [url uq_URLByAppendingQueryDictionary:@{
                                                @"client_id": clientId,
                                                @"redirect_uri": redirectUri,
                                                @"response_type": @"code",
                                                @"scope": scope,
                                                @"state": state,
                                                }];
  DDLogInfo(@"Authenticating with FullContact, starting with URL %@", url);

  _authenticationAttempts[state] = @{
                                     @"task": bfTask,
                                     @"clientId": clientId,
                                     @"clientSecret": clientSecret,
                                     @"redirectUri": redirectUri,
                                     };
  [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];

  return bfTask.task;
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
  NSDictionary *config = _authenticationAttempts[state];
  BFTaskCompletionSource *bfTask = config[@"task"];
  NSString *clientId = config[@"clientId"];
  NSString *clientSecret = config[@"clientSecret"];
  NSString *redirectUri = config[@"redirectUri"];

  if (!code) {
    NSString *desc = [NSString stringWithFormat:@"FullContact redirect URL %@ did not contain the necessary 'code' parameter. Cannot complete authenticaion request.", url];
    [bfTask setError:[NSError errorWithDomain:@"com.rdhjr.anchor" code:500 userInfo:@{ NSLocalizedDescriptionKey: desc }]];
    return;
  }


  // Call FullContact's oauth.exchangeAuthCode method to get an access token and refresh token.
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

  NSDictionary *parameters = @{
                               @"code": code,
                               @"client_id": clientId,
                               @"client_secret": clientSecret,
                               @"redirect_uri": redirectUri,
                               };

  [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [manager POST:@"https://api.fullcontact.com/v3/oauth.exchangeAuthCode" parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
      [bfTask setResult:responseObject];
    } else {
      NSString *desc = [NSString stringWithFormat:@"FullContact returned a strange object on authentication: %@", responseObject];
      [bfTask setError:[NSError errorWithDomain:@"com.rdhjr.anchor" code:500 userInfo:@{ NSLocalizedDescriptionKey: desc }]];
    }
  } failure:^(NSURLSessionTask *operation, NSError *error) {
    [bfTask setError:error];
  }];
}

- (NSString *)_redirectURIWithState:(NSString *)state
{
  NSURL *url = [NSURL URLWithString:_redirectURI];
  url = [url uq_URLByAppendingQueryDictionary:@{ @"state": state }];
  return [url absoluteString];
}

- (BFTask *)refreshAccessTokenUsingRefreshToken:(NSString *)refreshToken clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret
{
  BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

  NSDictionary *parameters = @{
                               @"client_id": clientId,
                               @"client_secret": clientSecret,
                               @"refresh_token": refreshToken,
                               };

  [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [manager POST:@"https://api.fullcontact.com/v3/oauth.refreshToken" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    NSDictionary *dict = (NSDictionary *)responseObject;
    DDLogInfo(@"Successefully refreshed access token: %@", dict);

    [bfTask setResult:dict];
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    DDLogError(@"Error refreshing access token refreshToken=%@: %@", refreshToken, error);
    [bfTask setError:error];
  }];

  return bfTask.task;
}

- (BFTask *)addNewContactWithFullName:(NSString *)fullName accessToken:(NSString *)token
{
  BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  manager.requestSerializer = [AFJSONRequestSerializer serializer];

  NSDictionary *parameters = @{
                               @"contact": @{
                                   @"contactData": @{
                                       @"name": @{
                                           @"givenName": fullName
                                           },
                                       },
                                   },
                               };

  [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token]  forHTTPHeaderField:@"Authorization"];
  [manager POST:@"https://api.fullcontact.com/v3/contacts.create" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    DDLogInfo(@"Created new FullContact contact name=%@", fullName);
    NSDictionary *dict = (NSDictionary *)responseObject;

    [bfTask setResult:dict[@"contact"]];
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    DDLogError(@"Error creating new FullContact contact name=%@: %@", fullName, error);
    [bfTask setError:error];
  }];

  return bfTask.task;
}

@end
