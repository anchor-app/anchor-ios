//
//  ViewController.h
//  Anchor
//
//  Created by Austen McDonald on 1/9/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARCalendarManager;

@interface ARScheduleViewController : UIViewController

- (instancetype)initWithDate:(NSDate *)date calendarManager:(ARCalendarManager *)calendarManager;

@end

