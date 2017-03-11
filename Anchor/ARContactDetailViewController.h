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

/**
 Create a new detail view controller for viewing Contacts.
 If you provide a contact that is not saved (ie contact.createdAt == nil) then it will
 allow the user to edit some basic values of the contact and save it both to Anchor and
 FullContact
 
 @param contact ARContact object to display.
 @param date The date to attach to a new note, if one for that date does not already exist.
 */
- (instancetype)initWithContact:(ARContact *)contact date:(NSDate *)date;

@end
