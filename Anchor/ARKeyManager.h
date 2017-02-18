//
//  ARKeyManager.h
//  Anchor
//
//  Created by Austen McDonald on 2/14/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ARKeyValueViewModel;
@class ARKeySelectionViewController;

@interface ARKeyManager : NSObject

- (ARKeySelectionViewController *)keySelectionViewControllerForViewModel:(ARKeyValueViewModel *)viewModel;

- (void)updateKeyCacheWithKey:(NSString *)key;

@end
