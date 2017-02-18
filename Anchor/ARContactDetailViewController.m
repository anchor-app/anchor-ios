//
//  ARContactDetailViewController.m
//  Anchor
//
//  Created by Austen McDonald on 1/30/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARContactDetailViewController.h"

#import <FontAwesomeKit/FontAwesomeKit.h>

#import "ARContactHeaderDataSource.h"
#import "ARKeyValueDataSource.h"
#import "ARAnnotation.h"
#import "ARContact.h"
#import "ARNote.h"
#import "ARSingleSectionDataSource.h"
#import "ARNoteViewModel.h"
#import "ARAnnotationViewModel.h"
#import "ARKeyManager.h"
#import "AppDelegate.h"

@interface ARContactDetailViewController () <ARDataSourceDelegate>

@property (nonatomic, strong) ARContact *contact;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSArray<ARSingleSectionDataSource *> *dataSources;

@property (nonatomic, strong) ARKeyValueDataSource *notesDatasource;
@property (nonatomic, strong) ARKeyValueDataSource *annotationsDataSource;

@end

@implementation ARContactDetailViewController

- (instancetype)initWithContact:(ARContact *)contact date:(NSDate *)date
{
  if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    self.contact = contact;
    self.date = date;


    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ARKeyManager *keyManager = appDelegate.keyManager;

    self.notesDatasource = [[ARKeyValueDataSource alloc] initWithViewModels:@[] keyManager:keyManager viewController:self];
    _notesDatasource.delegate = self;

    self.annotationsDataSource = [[ARKeyValueDataSource alloc] initWithViewModels:@[] keyManager:keyManager viewController:self];
    _annotationsDataSource.delegate = self;

    [[[[contact.notes query] findObjectsInBackground] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
      NSArray<ARNote *> *notes = t.result;
      NSCalendar* calendar = [NSCalendar currentCalendar];

      // Sort the notes.
      notes = [notes sortedArrayUsingComparator:^NSComparisonResult(ARNote *obj1, ARNote *obj2) {
        return [calendar compareDate:obj2.date toDate:obj1.date toUnitGranularity:NSCalendarUnitDay];
      }];

      NSMutableArray<ARNoteViewModel *> *noteViewModels = [NSMutableArray arrayWithArray:_.array(notes).map(^(ARNote *note) {
        return [[ARNoteViewModel alloc] initWithType:ARKeyValueViewModelTypeExisting object:note parentObject:_contact relation:_contact.notes];
      }).unwrap];

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
        [noteViewModels insertObject:[[ARNoteViewModel alloc] initWithType:ARKeyValueViewModelTypeNew object:todayNote parentObject:_contact relation:_contact.notes] atIndex:0];
      }

      _notesDatasource.viewModels = noteViewModels;

      return [[contact.annotations query] findObjectsInBackground];
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
      NSArray<ARAnnotation *> *annotations = t.result;
      NSMutableArray<ARAnnotationViewModel *> *annotationViewModels = [_.array(annotations).map(^id(ARAnnotation *a) {
        return [[ARAnnotationViewModel alloc] initWithType:ARKeyValueViewModelTypeExisting object:a parentObject:_contact relation:_contact.annotations];
      }).unwrap mutableCopy];

      _annotationsDataSource.viewModels = annotationViewModels;

      dispatch_async(dispatch_get_main_queue(), ^{
        [self dataSourceDataChanged:_annotationsDataSource];
      });

      return nil;
    }];

    self.dataSources = @[
                         [[ARContactHeaderDataSource alloc] initWithContact:self.contact],
                         _notesDatasource,
                         _annotationsDataSource,
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

- (void)dataSourceCellsHeightChanged:(ARSingleSectionDataSource *)dataSource
{
  [self.tableView beginUpdates];
  [self.tableView endUpdates];
}

- (void)dataSourceDataChanged:(ARSingleSectionDataSource *)dataSource
{
  // Make sure we always have a new annotation at the end of the list.
  ARAnnotationViewModel *lastVM = (ARAnnotationViewModel *)_annotationsDataSource.viewModels.lastObject;
  if (!lastVM || lastVM.type != ARKeyValueViewModelTypeNew) {
    // Always insert an empty one.
    NSMutableArray *vms = [_annotationsDataSource.viewModels mutableCopy];
    [vms addObject:[[ARAnnotationViewModel alloc] initWithType:ARKeyValueViewModelTypeNew object:[ARAnnotation annotationForContact:_contact withKey:nil value:nil] parentObject:_contact relation:_contact.annotations]];

    _annotationsDataSource.viewModels = vms;
  }

  // TODO: something cleaner here.
  [self.tableView reloadData];
}

@end
