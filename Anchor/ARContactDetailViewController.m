//
//  ARContactDetailViewController.m
//  Anchor
//
//  Created by Austen McDonald on 1/30/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARContactDetailViewController.h"

#import "ARContactHeaderDataSource.h"
#import "ARNotesDataSource.h"
#import "ARAnnotationsDataSource.h"
#import "ARContact.h"
#import "ARNote.h"
#import "ARSingleSectionDataSource.h"

@interface ARContactDetailViewController () <ARNotesDataSourceDelegate>

@property (nonatomic, strong) ARContact *contact;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSArray<ARSingleSectionDataSource *> *dataSources;

@property (nonatomic, strong) ARNotesDataSource *notesDatasource;

@end

@implementation ARContactDetailViewController

- (instancetype)initWithContact:(ARContact *)contact date:(NSDate *)date
{
  if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    self.contact = contact;
    self.date = date;

    NSArray *notes = @[];
    self.notesDatasource = [[ARNotesDataSource alloc] initWithNotes:notes];
    _notesDatasource.delegate = self;
    [[[contact.notes query] findObjectsInBackground] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
      NSArray<ARNote *> *notes = t.result;
      NSCalendar* calendar = [NSCalendar currentCalendar];

      // If there's not already a note for this day, then add one.
      BOOL hasToday = NO;
      for (ARNote *note in notes) {
        if ([calendar isDate:note.date equalToDate:_date toUnitGranularity:NSCalendarUnitDay]) {
          hasToday = YES;
          break;
        }
      }
      if (!hasToday) {
        ARNote *todayNote = [ARNote noteForContact:_contact withText:@"" date:_date];
        notes = [notes arrayByAddingObject:todayNote];
      }

      // Sort the notes.
      notes = [notes sortedArrayUsingComparator:^NSComparisonResult(ARNote *obj1, ARNote *obj2) {
        return [calendar compareDate:obj2.date toDate:obj1.date toUnitGranularity:NSCalendarUnitDay];
      }];

      _notesDatasource.notes = notes;

      dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
      });
      return nil;
    }];

    self.dataSources = @[
                         [[ARContactHeaderDataSource alloc] initWithContact:self.contact],
                         _notesDatasource
                         ];
  }
  return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.dataSources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  ARSingleSectionDataSource *dataSource = self.dataSources[section];
  return [dataSource tableView:tableView numberOfRowsInSection:0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  ARSingleSectionDataSource *dataSource = self.dataSources[indexPath.section];
  return [dataSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  ARSingleSectionDataSource *dataSource = self.dataSources[indexPath.section];
  return [dataSource tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)dataSourceCellsHeightChanged:(ARNotesDataSource *)dataSource
{
  [self.tableView beginUpdates];
  [self.tableView endUpdates];
}

@end
