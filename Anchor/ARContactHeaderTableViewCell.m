//
//  ARContactHeaderTableViewCell.m
//  Anchor
//
//  Created by Austen McDonald on 1/30/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARContactHeaderTableViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface ARContactHeaderTableViewCell ()

@property (nonatomic, assign) BOOL isCustomEditing;

@end

@implementation ARContactHeaderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    _textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:_textField];

    // Initially, just use the UITextField as a label and not an editable field.
    _textField.userInteractionEnabled = NO;
  }
  return self;
}

- (void)setEditing:(BOOL)editing
{
  // Hijack the meaning of UITableViewCell.editing for our own purposes.

  _isCustomEditing = editing;
  _textField.userInteractionEnabled = editing;
}

- (BOOL)isEditing
{
  return _isCustomEditing;
}

- (void)setFullName:(NSString *)fullName
{
  _fullName = [fullName copy];
  _textField.text = fullName;
}

- (void)setPhotoURL:(NSString *)photoURL
{
  _photoURL = [photoURL copy];
  [self.imageView sd_setImageWithURL:[NSURL URLWithString:_photoURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    [self setNeedsLayout];
  }];
}

@end
