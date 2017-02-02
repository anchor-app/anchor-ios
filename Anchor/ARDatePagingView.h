//
//  ARDatePagingView.h
//  Anchor
//
//  Created by Austen McDonald on 2/1/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARDatePagingView;

@protocol ARDatePagingViewDelegate

- (void)datePagingView:(ARDatePagingView *)view didChangeToDate:(NSDate *)date;

@end

@interface ARDatePagingView : UIView

- (instancetype)initWithDate:(NSDate *)date;

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, weak) id<ARDatePagingViewDelegate> delegate;

@end
