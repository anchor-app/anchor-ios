//
//  ARKeySelectorView.m
//  Anchor
//
//  Created by Austen McDonald on 2/8/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARKeySelectorView.h"

#import <FontAwesomeKit/FontAwesomeKit.h>

const CGFloat kChevronPadding = 5.0;

@interface ARKeySelectorView ()

@property (nonatomic, strong) UILabel *keyLabel;
@property (nonatomic, strong) UIButton *editButton;

@end

@implementation ARKeySelectorView

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    self.keyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.canEdit = NO;

    FAKIonIcons *chevronIcon = [FAKIonIcons chevronDownIconWithSize:12];
    UIImage *chevronImage = [chevronIcon imageWithSize:CGSizeMake(12, 12)];
    [_editButton setImage:chevronImage forState:UIControlStateNormal];

    [self addSubview:_keyLabel];
    [self addSubview:_editButton];
  }
  return self;
}

- (void)setKey:(NSString *)key
{
  _keyLabel.text = key;
  [self setNeedsLayout];
}

- (NSString *)key
{
  return _keyLabel.text;
}

- (CGSize)sizeThatFits:(CGSize)size
{
  CGSize max = CGSizeMake(FLT_MAX, FLT_MAX);
  CGSize labelSize = [_keyLabel sizeThatFits:max];
  CGFloat buttonAndExtras = 0;
  if (_canEdit) {
    CGSize buttonSize = [_editButton sizeThatFits:max];
    buttonAndExtras += kChevronPadding;
    buttonAndExtras += buttonSize.width;
  }
  return CGSizeMake(ceilf(labelSize.width + buttonAndExtras), ceilf(labelSize.height));
}

- (void)layoutSubviews
{
  CGSize max = CGSizeMake(FLT_MAX, FLT_MAX);
  CGSize labelSize = [_keyLabel sizeThatFits:max];
  CGSize buttonSize = [_editButton sizeThatFits:max];

  _keyLabel.frame = CGRectMake(0, 0, labelSize.width, labelSize.height);
  _editButton.frame = CGRectMake(ceilf(_keyLabel.frame.origin.x + _keyLabel.frame.size.width + kChevronPadding), 0, buttonSize.width, buttonSize.height);
}

- (void)setCanEdit:(BOOL)canEdit
{
  _canEdit = canEdit;
  _editButton.hidden = !canEdit;
}

@end
