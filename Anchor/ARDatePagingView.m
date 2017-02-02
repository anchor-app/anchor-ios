//
//  ARDatePagingView.m
//  Anchor
//
//  Created by Austen McDonald on 2/1/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARDatePagingView.h"

#import <FontAwesomeKit/FontAwesomeKit.h>

@interface ARDatePagingView ()

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;

@end

@implementation ARDatePagingView

- (instancetype)initWithDate:(NSDate *)date
{
  if (self = [super initWithFrame:CGRectZero]) {
    _date = date;

    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    self.timeFormatter = [[NSDateFormatter alloc] init];
    [_timeFormatter setDateStyle:NSDateFormatterShortStyle];
    [_timeFormatter setTimeStyle:NSDateFormatterNoStyle];

    self.backgroundColor = [UIColor grayColor];

    FAKIonIcons *leftIcon = [FAKIonIcons chevronLeftIconWithSize:25];
    UIImage *leftImage = [leftIcon imageWithSize:CGSizeMake(25, 25)];

    FAKIonIcons *rightIcon = [FAKIonIcons chevronRightIconWithSize:25];
    UIImage *rightImage = [rightIcon imageWithSize:CGSizeMake(25, 25)];

    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_leftButton setImage:leftImage forState:UIControlStateNormal];
    [_leftButton addTarget:self action:@selector(_onButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_leftButton];

    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightButton setImage:rightImage forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(_onButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightButton];

    self.label = [[UILabel alloc] initWithFrame:CGRectZero];
    _label.text = [_timeFormatter stringFromDate:_date];
    [self addSubview:_label];
  }
  return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
  return CGSizeMake(size.width, 44);
}

- (void)layoutSubviews
{
  CGSize size = self.frame.size;
  _leftButton.frame = CGRectMake(0, 0, size.height, size.height);
  _rightButton.frame = CGRectMake(self.frame.size.width - size.height, 0, size.height, size.height);

  _label.frame = CGRectMake(size.height, 0, self.frame.size.width - size.height*2, size.height);
}

- (void)setDate:(NSDate *)date
{
  _date = date;

  _label.text = [self.timeFormatter stringFromDate:self.date];

  if (_delegate) {
    [_delegate datePagingView:self didChangeToDate:self.date];
  }
}

- (void)_onButton:(id)sender
{
  NSTimeInterval oneDay = 24*60*60;

  if (sender == _leftButton) {
    self.date = [_date dateByAddingTimeInterval:-oneDay];
  }

  if (sender == _rightButton) {
    self.date = [_date dateByAddingTimeInterval:oneDay];
  }
}

@end
