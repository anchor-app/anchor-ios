//
//  ARAnnotationTableViewCell.h
//  Anchor
//
//  Created by Austen McDonald on 2/1/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARAnnotation;

@interface ARAnnotationTableViewCell : UITableViewCell

@property (nonatomic, strong) ARAnnotation *annotation;

@end
