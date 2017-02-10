//
//  ARNoteTableViewCell.m
//  Anchor
//
//  Created by Austen McDonald on 2/1/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARKeyValueTableViewCell.h"

#import "ARKeyValueViewModel.h"
#import "ARKeySelectorView.h"

@interface ARKeyValueTableViewCell () <UITextViewDelegate>
@end

@implementation ARKeyValueTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.valueTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    _valueTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    _valueTextView.font = [UIFont systemFontOfSize:17];
    _valueTextView.scrollEnabled = NO;
    _valueTextView.delegate = self;
    [self.contentView addSubview:_valueTextView];
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:_valueTextView action:NSSelectorFromString(@"becomeFirstResponder")]];

    self.keySelectorView = [[ARKeySelectorView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_keySelectorView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onTapKeySelector:)];
    [_keySelectorView addGestureRecognizer:tap];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_onLongPress:)];
    [self addGestureRecognizer:longPress];
  }
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];

  CGSize size = self.frame.size;
  CGSize selectorSize = [_keySelectorView sizeThatFits:CGSizeMake(FLT_MAX, FLT_MAX)];

  _keySelectorView.frame = CGRectMake(0, 0, selectorSize.width, selectorSize.height);

  CGSize textSize = [_valueTextView sizeThatFits:CGSizeMake(size.width, FLT_MAX)];
  _valueTextView.frame = CGRectMake(0, 15, size.width, textSize.height);
}

- (void)setViewModel:(ARKeyValueViewModel *)viewModel;
{
  _viewModel = viewModel;

  _keySelectorView.key = _viewModel.key;
  _keySelectorView.canEdit = _viewModel.canEdit;
  _valueTextView.text = _viewModel.value;

  [self setNeedsLayout];
}

+ (CGFloat)heightForViewModel:(ARKeyValueViewModel *)viewModel width:(CGFloat)width
{
  static UITextView *textView;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:17];
  });

  textView.text = viewModel.value;
  CGSize size = [textView sizeThatFits:CGSizeMake(width, FLT_MAX)];

  return ceilf(size.height) + 15;
}

- (void)textViewDidChange:(UITextView *)textView
{
  if (_delegate) {
    [_delegate cell:self viewModel:_viewModel valueDidChange:textView];
  }
}

- (void)_onTapKeySelector:(UITapGestureRecognizer *)recognizer
{
  if (_delegate) {
    [_delegate cell:self didTapKeySelectorForViewModel:_viewModel];
  }
}

- (void)_onLongPress:(UILongPressGestureRecognizer *)recognizer
{
  if (_viewModel.type == ARKeyValueViewModelTypeExisting) {
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(_onDelete:)];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.frame inView:self.superview];
    menu.arrowDirection = UIMenuControllerArrowDown;
    menu.menuItems = @[menuItem];
    [menu setMenuVisible:YES animated:YES];
  }
}

- (void)_onDelete:(id)sender
{
  DDLogDebug(@"Deleting object view view model: %@", _viewModel.object.objectId);

  if (self.delegate) {
    [self.delegate cell:self didDeleteViewModel:_viewModel];
  }
}

@end
