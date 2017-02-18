//
//  ARKeyManager.m
//  Anchor
//
//  Created by Austen McDonald on 2/14/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARKeyManager.h"

#import "ARKeySelectionViewController.h"
#import "ARKeyValueViewModel.h"
#import "ARContact.h"
#import "ARAnnotation.h"

@interface ARKeyManager ()

@property (nonatomic, strong) NSMutableSet<NSString *> *keys;

@end

@implementation ARKeyManager

- (instancetype)init
{
  if (self = [super init]) {
    self.keys = [NSMutableSet set];
    
    PFQuery *query = [PFQuery queryWithClassName:[ARAnnotation parseClassName]];
    [[query findObjectsInBackground]
     continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
       if (t.error) {
         return nil;
       }

       NSArray<ARAnnotation *> *annotations = t.result;

       dispatch_async(dispatch_get_main_queue(), ^{
         for (ARAnnotation *a in annotations) {
           if (a.key) {
             // If something goes wrong, you don't want this to crash.
             [_keys addObject:a.key];
          }
         }
       });

       return nil;
     }];
  }
  return self;
}

- (void)updateKeyCacheWithKey:(NSString *)key
{
  [_keys addObject:key];
}

- (ARKeySelectionViewController *)keySelectionViewControllerForViewModel:(ARKeyValueViewModel *)viewModel
{
  return [[ARKeySelectionViewController alloc] initWithViewModel:viewModel keys:[_keys allObjects]];
}

@end
