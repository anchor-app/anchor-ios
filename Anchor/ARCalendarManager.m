//
//  ARCalendarManager.m
//  Anchor
//
//  Created by Austen McDonald on 1/9/17.
//  Copyright © 2017 Overlord. All rights reserved.
//

#import "ARCalendarManager.h"

#import <Bolts/Bolts.h>
#import <EventKit/EventKit.h>

#import "Contact.h"
#import "AREvent.h"
#import "Schedule.h"

@interface ARCalendarManager ()

@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) NSCalendar *calendar;

@end

@implementation ARCalendarManager {
  dispatch_queue_t _queue;
}

- (instancetype)init
{
  if (self = [super init]) {
    _queue = dispatch_queue_create("com.rdhjr.anchor.calendar_manager", NULL);

    self.calendar = [NSCalendar currentCalendar];
    [self.calendar setLocale:[NSLocale currentLocale]];
    [self.calendar setTimeZone:[NSTimeZone localTimeZone]];

    self.eventStore = [[EKEventStore alloc] init];

    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError* error) {
      if (!granted) {
        DDLogError(@"Calendar access not granted: %@", error);
      } else {
        DDLogDebug(@"Calendar access granted");
      }
     }];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_eventStoreChanged:)
                                                 name:EKEventStoreChangedNotification
                                               object:self.eventStore];


  }

  return self;
}

- (BOOL)_validateEmail:(NSString *)string
{
  NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,63}";
  NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

  return [emailTest evaluateWithObject:string];
}

- (NSDictionary<NSString *, NSArray<NSString *> *> *)_eventEmailsIndex:(NSArray<EKEvent *> *)events
{
  NSMutableDictionary<NSString *, NSArray<NSString *> *> *index = [NSMutableDictionary dictionary];
  for (EKEvent *event in events) {
    NSMutableArray<NSString *> *emails = [NSMutableArray array];
    for (EKParticipant *participant in event.attendees) {
      if (participant.isCurrentUser) {
        continue;
      }
      NSString *maybeEmail = participant.URL.resourceSpecifier;
      // Drop optional 'mailto:' text.
      NSString *prefix = @"mailto:";
      if ([maybeEmail hasPrefix:prefix]) {
        maybeEmail = [maybeEmail substringFromIndex:[prefix length]];
      }
      if (![self _validateEmail:maybeEmail]) {
        DDLogWarn(@"Cannot find an email in URL '%@' for event %@", participant.URL, event);
        continue;
      }
      [emails addObject:maybeEmail];
    }
    index[event.eventIdentifier] = emails;
  }

  return index;
}

- (NSDictionary<NSString *, Contact *> *)_indexForContacts:(NSArray<Contact *> *)contacts
{
  NSMutableDictionary *index = [NSMutableDictionary dictionary];

  for (Contact *contact in contacts) {
    for (NSString *email in contact.emails) {
      index[email] = contact;
    }
  }

  return index;
}

- (BFTask *)_asyncFetchEventsForDate:(NSDate *)date
{
  BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];

  dispatch_async(_queue, ^() {
    NSDateComponents *dateComponents = [_calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    NSDate *startDate = [_calendar dateFromComponents:dateComponents];
    NSDate *endDate = [startDate dateByAddingTimeInterval:60*60*24];

    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate
                                                                      endDate:endDate
                                                                    calendars:nil];

    // This call takes a while, that's part of the reason we're on a different queue.
    NSArray<EKEvent *> *events = [self.eventStore eventsMatchingPredicate:predicate];

    [task setResult:events];
  });
  return task.task;
}

- (BFTask *)_asyncFetchContactsWithEmails:(NSArray<NSString *> *)emails
{
  BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];

  // Find the Contact objects for all participants if they exists.
  PFQuery *queryByEmails = [PFQuery queryWithClassName:NSStringFromClass([Contact class])];
  //queryByEmails.cachePolicy = kPFCachePolicyCacheElseNetwork;
  [queryByEmails whereKey:@"emails" containedIn:emails];
  [[queryByEmails findObjectsInBackground]
     continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
       if (t.error) {
         [task setError:t.error];
         return nil;
       }

       // Build an index of email -> contact, for each email the contact has.
       NSArray<Contact *> *contacts = t.result;

       NSDictionary<NSString *, Contact *> *index = [self _indexForContacts:contacts];
       [task setResult:index];
       return nil;
     }];

  return task.task;
}

- (BFTask *)asyncFetchScheduleWithDate:(NSDate *)date
{
  BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];

  __block NSDictionary<NSString *, NSArray<NSString *> *> *eventEmailsIndex;
  __block NSArray<EKEvent *> *underlyingEvents;

  // 1. Fetch the list of calendar events from the local device.
  [[[self _asyncFetchEventsForDate:date] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
    // 2. With those events, fetch all the Contact objects from the server with corresponding emails.
    underlyingEvents = t.result;

    DDLogDebug(@"Fetched %lu events for %@", underlyingEvents.count, date);

    eventEmailsIndex = [self _eventEmailsIndex:underlyingEvents];

    // To make querying the server faster, get all the remote Contact objects represented
    // by the emails we have for this set of events.
    NSMutableSet<NSString *> *emails = [NSMutableSet set];
    for (NSString *eventId in eventEmailsIndex) {
      NSArray *es = eventEmailsIndex[eventId];
      [emails addObjectsFromArray:es];
    }

    return [self _asyncFetchContactsWithEmails:[emails allObjects]];
  }] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
    if (t.error) {
      DDLogError(@"Error: batch fetching contacts for emails failed: %@", t.error.localizedDescription);
      return nil;
    }

    // 3. Build a Schedule object full of AREvent objects and a list of all Contacts.
    NSDictionary<NSString *, Contact *> *emailContactIndex = t.result;
    NSMutableSet<Contact *> *contacts = [NSMutableSet set];

    NSMutableArray<AREvent *> *events = [NSMutableArray array];
    for (EKEvent *event in underlyingEvents) {
      NSArray<NSString *> *emailsInEvent = eventEmailsIndex[event.eventIdentifier];
      NSMutableDictionary<NSString *, id> *eventContacts = [NSMutableDictionary dictionary];
      for (NSString *email in emailsInEvent) {
        // If we found a Contact object for this email, record that, otherwise
        // mark that email with a reference to NSNull so we can see downstream that
        // we didnt find one.
        Contact *contact = emailContactIndex[email];
        if (contact) {
          [contacts addObject:contact];
          eventContacts[email] = contact;
        } else {
          eventContacts[email] = [NSNull null];
        }
      }

     AREvent *e = [AREvent eventWithParticipants:eventContacts underlyingEvent:event];
      [events addObject:e];
    }

    [task setResult:[Schedule scheduleWithEvents:events contacts:[contacts allObjects]]];

    return nil;
  }];

  return task.task;
}

- (void)_eventStoreChanged:(NSNotification *)notification
{

}

@end
