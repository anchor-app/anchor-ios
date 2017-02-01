//
//  ARAnnotationsDataSource.h
//  Anchor
//
//  Created by Austen McDonald on 2/1/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UITableViewController.h>

#import "ARSingleSectionDataSource.h"

@class ARAnnotation;

@interface ARAnnotationsDataSource : ARSingleSectionDataSource

- (instancetype)initWithAnnotations:(NSArray<ARAnnotation *> *)annotations;

@property (nonatomic, copy) NSArray<ARAnnotation *> *annnotations;

@end
