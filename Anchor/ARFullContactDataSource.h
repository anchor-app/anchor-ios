//
//  ARFullContactDataSource.h
//  Anchor
//
//  Created by Austen McDonald on 2/21/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARSingleSectionDataSource.h"

@interface ARFullContactDataSource : ARSingleSectionDataSource

@property (nonatomic, weak) id<ARDataSourceDelegate> delegate;

@end
