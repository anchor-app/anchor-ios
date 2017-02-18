//
//  ARKeyValueTableViewCell.h
//  Anchor
//
//  Created by Austen McDonald on 2/1/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARKeyValueTableViewCell;
@class ARKeySelectorView;
@class ARKeyValueViewModel;

@protocol ARKeyValueTableViewCellDelegate

- (void)cell:(ARKeyValueTableViewCell *)cell viewModelDidChange:(ARKeyValueViewModel *)viewModel key:(NSString *)key value:(NSString *)value;
- (void)cell:(ARKeyValueTableViewCell *)cell didDeleteViewModel:(ARKeyValueViewModel *)viewModel;
- (void)cell:(ARKeyValueTableViewCell *)cell didTapKeySelectorForViewModel:(ARKeyValueViewModel *)viewModel;

@end

@interface ARKeyValueTableViewCell : UITableViewCell

+ (CGFloat)heightForViewModel:(ARKeyValueViewModel *)viewModel width:(CGFloat)width;

@property (nonatomic, strong) ARKeyValueViewModel *viewModel;
@property (nonatomic, strong) ARKeySelectorView *keySelectorView;
@property (nonatomic, strong) UITextView *valueTextView;

@property (nonatomic, weak) id<ARKeyValueTableViewCellDelegate> delegate;

@end
