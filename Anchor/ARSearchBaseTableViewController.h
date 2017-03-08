//
//  ARSearchBaseTableViewController.h
//  Anchor
//
//  Created by Austen McDonald on 3/3/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARContact;

typedef NS_ENUM(NSInteger, ARSearchViewModelType) {
  ARSearchViewModelTypeContact,
  ARSearchViewModelTypeNewContact,
};

@interface ARSearchViewModel : NSObject

@property (nonatomic, readonly, assign) ARSearchViewModelType type;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *contactId;

- (instancetype)initWithType:(ARSearchViewModelType)type name:(NSString *)name contactId:(NSString *)contactId;

@end

@interface ARSearchBaseTableViewController : UITableViewController

- (void)configureCell:(UITableViewCell *)cell withViewModel:(ARSearchViewModel *)viewModel;

@end
