//
//  AREventDataSource.h
//  Anchor
//
//  Created by Austen McDonald on 2/13/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARSingleSectionDataSource.h"

@class AREvent;
@class UINavigationController;

@interface AREventDataSource : ARSingleSectionDataSource

- (instancetype)initWithEvent:(AREvent *)event date:(NSDate *)date navigationController:(UINavigationController *)navigationController;

@end
