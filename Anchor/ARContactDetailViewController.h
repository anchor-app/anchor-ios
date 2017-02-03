//
//  ARContactDetailViewController.h
//  Anchor
//
//  Created by Austen McDonald on 1/30/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARContact;

@interface ARContactDetailViewController : UITableViewController

- (instancetype)initWithContact:(ARContact *)contact date:(NSDate *)date;

@end
