//
//  ARAnnotationTableViewCell.m
//  Anchor
//
//  Created by Austen McDonald on 2/1/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARAnnotationTableViewCell.h"

#import "ARAnnotation.h"

@implementation ARAnnotationTableViewCell

- (void)setAnnotation:(ARAnnotation *)annotation
{
  _annotation = annotation;

  self.textLabel.text = _annotation.value;
}
@end
