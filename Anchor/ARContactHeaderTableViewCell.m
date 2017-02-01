//
//  ARContactHeaderTableViewCell.m
//  Anchor
//
//  Created by Austen McDonald on 1/30/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARContactHeaderTableViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>

@implementation ARContactHeaderTableViewCell

- (void)setFullName:(NSString *)fullName
{
  _fullName = [fullName copy];
  self.textLabel.text = fullName;
}

- (void)setPhotoURL:(NSString *)photoURL
{
  _photoURL = [photoURL copy];
  [self.imageView sd_setImageWithURL:[NSURL URLWithString:_photoURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    [self setNeedsLayout];
  }];
}

@end
