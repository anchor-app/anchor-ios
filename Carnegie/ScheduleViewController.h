//
//  ViewController.h
//  Carnegie
//
//  Created by Austen McDonald on 1/9/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CNGECalendarManager;

@interface ScheduleViewController : UIViewController

- (instancetype)initWithDate:(NSDate *)date calendarManager:(CNGECalendarManager *)calendarManager;

@end

