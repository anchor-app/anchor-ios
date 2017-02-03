//
//  ARLogViewerViewController.m
//  Anchor
//
//  Created by Austen McDonald on 2/3/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARLogViewerViewController.h"

@interface ARLogViewerViewController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation ARLogViewerViewController

- (instancetype)initWithLogs:(NSString *)logs
{
  if (self = [super init]) {
    self.title = @"Logs";

    self.textView = [[UITextView alloc] initWithFrame:CGRectZero];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _textView.font = [UIFont fontWithName:@"Menlo" size:11];
    _textView.text = logs;
    _textView.editable = NO;
  }
  return self;
}

- (void)loadView
{
  self.view = _textView;
}

@end
