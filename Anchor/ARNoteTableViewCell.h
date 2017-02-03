//
//  ARNoteTableViewCell.h
//  Anchor
//
//  Created by Austen McDonald on 2/1/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARNote;
@class ARNoteTableViewCell;

@protocol ARNoteTableViewCellDelegate

- (void)cell:(ARNoteTableViewCell *)cell note:(ARNote *)note textViewDidChange:(UITextView *)textView;

@end

@interface ARNoteTableViewCell : UITableViewCell

+ (CGFloat)heightForNote:(ARNote *)note width:(CGFloat)width;

@property (nonatomic, strong) ARNote *note;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, weak) id<ARNoteTableViewCellDelegate> delegate;

@end
