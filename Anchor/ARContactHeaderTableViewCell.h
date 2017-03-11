//
//  ARContactHeaderTableViewCell.h
//  Anchor
//
//  Created by Austen McDonald on 1/30/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARContactHeaderTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSString *photoURL;
@property (nonatomic, strong) UITextField *textField;

@end
