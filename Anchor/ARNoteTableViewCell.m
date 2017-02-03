//
//  ARNoteTableViewCell.m
//  Anchor
//
//  Created by Austen McDonald on 2/1/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARNoteTableViewCell.h"

#import "ARNote.h"

@interface ARNoteTableViewCell () <UITextViewDelegate>

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;

@end

@implementation ARNoteTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.timeFormatter = [[NSDateFormatter alloc] init];
    [_timeFormatter setDateStyle:NSDateFormatterShortStyle];
    [_timeFormatter setTimeStyle:NSDateFormatterNoStyle];

    self.textView = [[UITextView alloc] initWithFrame:CGRectZero];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    _textView.font = [UIFont systemFontOfSize:17];
    _textView.scrollEnabled = NO;
    _textView.delegate = self;
    [self.contentView addSubview:_textView];
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:_textView action:NSSelectorFromString(@"becomeFirstResponder")]];

    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _dateLabel.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:_dateLabel];
  }
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];

  CGSize size = self.frame.size;

  _dateLabel.frame = CGRectMake(0, 0, size.width, 12);

  CGSize textSize = [_textView sizeThatFits:CGSizeMake(size.width, FLT_MAX)];
  _textView.frame = CGRectMake(0, 15, size.width, textSize.height);
}

- (void)setNote:(ARNote *)note
{
  _note = note;

  _dateLabel.text = [_timeFormatter stringFromDate:_note.date];
  _textView.text = note.text;

  [self setNeedsLayout];
}

+ (CGFloat)heightForNote:(ARNote *)note width:(CGFloat)width
{
  static UITextView *textView;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:17];
  });

  textView.text = note.text;
  CGSize size = [textView sizeThatFits:CGSizeMake(width, FLT_MAX)];

  return ceilf(size.height) + 15;
}

- (void)textViewDidChange:(UITextView *)textView
{
  if (_delegate) {
    [_delegate cell:self note:_note textViewDidChange:textView];
  }
}

@end
