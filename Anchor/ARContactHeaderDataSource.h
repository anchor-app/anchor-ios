//
//  ARContactHeaderDataSource.h
//  Anchor
//
//  Created by Austen McDonald on 1/30/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ARSingleSectionDataSource.h"

@class ARContact;

@interface ARContactHeaderDataSource : ARSingleSectionDataSource

- (instancetype)initWithContact:(ARContact *)contact;

@end
