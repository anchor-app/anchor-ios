//
//  LSLogViewer.m
//  LSLogViewer
//
//  Created by Leszek S on 04.09.2015.
//  Copyright (c) 2015 Leszek S. All rights reserved.
//

#import "LSLogViewer.h"

#import <MessageUI/MessageUI.h>
#import "asl.h"

@interface LSLogViewer () <MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL loadingLogs;
@end

@implementation LSLogViewer

#pragma mark - public

+ (void)showViewer
{
    [[self sharedInstance] showInOwnWindow];
}

+ (void)hideViewer
{
    [[self sharedInstance] hideOwnWindow];
}

+ (void)registerThreeFingerTripleTapGesture
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showViewer)];
    [recognizer setNumberOfTouchesRequired:3];
    [recognizer setNumberOfTapsRequired:3];
    
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    if (!mainWindow)
        mainWindow = [[[UIApplication sharedApplication] delegate] window];
    [mainWindow addGestureRecognizer:recognizer];
}

#pragma mark - private

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)showInOwnWindow
{
    if (!self.window)
    {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.windowLevel = UIWindowLevelAlert;
        self.window.rootViewController = self;
    }
    [self.window makeKeyAndVisible];
    [self refreshLogs];
}

- (void)hideOwnWindow
{
    self.window.hidden = YES;
}

#pragma mark - view controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textView.text = @"LOADING...";
    self.searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"SEARCH" attributes:@{ NSForegroundColorAttributeName: [UIColor greenColor] }];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self refreshLogs];
}

- (void)hideKeyboard
{
    [self.view endEditing:YES];
}

- (void)refreshLogs
{
    if (self.loadingLogs)
        return;
    
    self.loadingLogs = YES;
    self.reloadButton.enabled = NO;
    [self asyncReadDeviceLogsWithCompletionBlock:^(NSString *logs) {
        self.textView.text = logs;
        self.reloadButton.enabled = YES;
        self.loadingLogs = NO;
        [self scrollToBottom];
    }];
}

- (void)scrollToBottom
{
    if (self.textView.text.length > 0)
    {
        NSRange range = NSMakeRange(self.textView.text.length - 1, 1);
        [self.textView scrollRangeToVisible:range];
    }
}

- (IBAction)searchAction:(id)sender
{
    NSString *search = self.searchField.text;
    NSString *text = self.textView.text;
    
    NSRange currentRange = self.textView.selectedRange;
    NSRange range = [text rangeOfString:search options:NSCaseInsensitiveSearch];
    
    if (currentRange.location != NSNotFound && currentRange.location + 1 <= [text length])
    {
        range = [text rangeOfString:search options:NSCaseInsensitiveSearch range:NSMakeRange(currentRange.location + 1, [text length] - currentRange.location - 1)];
    }
    
    if (range.location == NSNotFound)
    {
        range = [text rangeOfString:search options:NSCaseInsensitiveSearch];
    }
    
    if (range.location != NSNotFound)
    {
        [self.textView select:self.textView];
        self.textView.selectedRange = range;
        [self.textView scrollRangeToVisible:range];
    }
}

- (IBAction)searchBackwardAction:(id)sender
{
    NSString *search = self.searchField.text;
    NSString *text = self.textView.text;
    
    NSRange currentRange = self.textView.selectedRange;
    NSRange range = [text rangeOfString:search options:NSCaseInsensitiveSearch | NSBackwardsSearch];
    
    if (currentRange.location != NSNotFound && (NSInteger)currentRange.location - 1 >= 0)
    {
        range = [text rangeOfString:search options:NSCaseInsensitiveSearch | NSBackwardsSearch range:NSMakeRange(0, currentRange.location - 1)];
    }
    
    if (range.location == NSNotFound)
    {
        range = [text rangeOfString:search options:NSCaseInsensitiveSearch | NSBackwardsSearch];
    }
    
    if (range.location != NSNotFound)
    {
        [self.textView select:self.textView];
        self.textView.selectedRange = range;
        [self.textView scrollRangeToVisible:range];
    }
}

- (IBAction)refreshAction:(id)sender
{
    [self refreshLogs];
}

- (IBAction)emailAction:(id)sender
{
    NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString *title = [NSString stringWithFormat:@"Logs - %@", name];
    NSString *message = [NSString stringWithFormat:@"<pre>%@</pre>", self.textView.text];
    [self composeEmailWithTitle:title message:message];
}

- (IBAction)closeAction:(id)sender
{
    [self hideOwnWindow];
}

- (IBAction)searchEditingDidBegin:(id)sender
{
    self.searchField.attributedPlaceholder = nil;
}

- (IBAction)searchEditingDidEnd:(id)sender
{
    self.searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"SEARCH" attributes:@{ NSForegroundColorAttributeName: [UIColor greenColor] }];
}

#pragma mark - sending email

- (void)composeEmailWithTitle:(NSString *)title message:(NSString *)message
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailViewController = [MFMailComposeViewController new];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:title];
        [mailViewController setMessageBody:message isHTML:YES];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Can't send email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultFailed)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed to send email!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - logs reading

- (void)asyncReadDeviceLogsWithCompletionBlock:(void (^)(NSString *logs))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *logs = [self readDeviceLogs];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock)
                completionBlock(logs);
        });
    });
}

- (NSString *)readDeviceLogs
{
    aslmsg q, m;
    int i;
    const char *key, *val;
    NSMutableString *logs = [NSMutableString stringWithString:@""];
    
    q = asl_new(ASL_TYPE_QUERY);
    
    aslresponse r = asl_search(NULL, q);
    while (NULL != (m = asl_next(r)))
    {
        NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
        
        for (i = 0; (NULL != (key = asl_key(m, i))); i++)
        {
            NSString *keyString = [NSString stringWithUTF8String:(char *)key];
            
            val = asl_get(m, key);
            
            NSString *string = val != NULL ? [NSString stringWithUTF8String:val] : nil;
            [tmpDict setValue:string forKey:keyString];
        }
        
        NSString *line = [NSString stringWithFormat:@"%@ %@[%@] %@\n", [NSDate dateWithTimeIntervalSince1970:[tmpDict[@"Time"] intValue]], tmpDict[@"Sender"], tmpDict[@"PID"], tmpDict[@"Message"]];
        
        [logs appendString:line];
    }
    asl_release(r);
    
    return logs;
}

@end