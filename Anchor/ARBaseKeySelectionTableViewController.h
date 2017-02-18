//
//  ARBaseKeySelectionTableViewController.h
//  Anchor
//
//  Created by Austen McDonald on 2/14/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ARKeySelectionViewModelType) {
  ARKeySelectionViewModelTypeKey,
  ARKeySelectionViewModelTypeNewKey,
};

@interface ARKeySelectionViewModel : NSObject

@property (nonatomic, readonly, assign) ARKeySelectionViewModelType type;
@property (nonatomic, readonly, strong) NSString *key;

- (instancetype)initWithType:(ARKeySelectionViewModelType)type key:(NSString *)key;

@end

@interface ARBaseKeySelectionTableViewController : UITableViewController

- (void)configureCell:(UITableViewCell *)cell withViewModel:(ARKeySelectionViewModel *)viewModel;

@end
