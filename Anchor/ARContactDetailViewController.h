//
//  ARContactDetailViewController.h
//  Anchor
//
//  Created by Austen McDonald on 1/30/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Contact;

@interface ARContactDetailViewController : UITableViewController

- (instancetype)initWithContact:(Contact *)contact;

@end
