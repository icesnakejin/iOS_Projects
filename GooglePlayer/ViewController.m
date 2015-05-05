//
//  ViewController.m
//  GooglePlayer
//
//  Created by Yankun Jin on 3/30/15.
//  Copyright (c) 2015 YankunJin. All rights reserved.
//

#import "ViewController.h"
#import "GTLUtilities.h"
#import "GTMHTTPFetcherLogging.h"
#import "TaskListsViewController.h"

// Keychain item name for saving the user's authentication information
NSString *const kKeychainItemName = @"GooglePlayer";

NSString *const kclientID = @"195310205871-51i5vfp363o5ihf1eb18uvbvccbos2an.apps.googleusercontent.com";
NSString *const kclientSecret = @"5F9pL76svGIFgf-zchKowJRY";



@interface ViewController ()

@property (nonatomic, retain) GTLServiceTasks *tasksService;

@property (nonatomic,retain) GTLTasksTaskLists *taskLists;
@property (nonatomic,retain) GTLServiceTicket *taskListsTicket;
@property (nonatomic,retain) NSError *taskListsFetchError;

@property (nonatomic,retain) GTLServiceTicket *editTaskListTicket;

@property (nonatomic,retain) GTLTasksTasks *tasks;
@property (nonatomic,retain) GTLServiceTicket *tasksTicket;
@property (nonatomic,retain) NSError *tasksFetchError;

@property (nonatomic,retain) GTLServiceTicket *editTaskTicket;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tasksService = [[GTLServiceTasks alloc] init];
    
    _tasksService.shouldFetchNextPages = YES;
    
    // Have the service object set tickets to retry temporary error conditions
    // automatically
    _tasksService.retryEnabled = YES;
    
    // Load the OAuth token from the keychain, if it was previously saved
    NSString *clientID = kclientID;
    NSString *clientSecret = kclientSecret;
    
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                              clientID:clientID
                                                          clientSecret:clientSecret];
    self.tasksService.authorizer = auth;

//    aTasksTicket =  [service executeQuery:query
//                        completionHandler:^(GTLServiceTicket *ticket,
//                                            id tasks, NSError *error) {
//                            // callback
//                            [self doSomethingWithTasks: tasks];
//                        }];
    // Do any additional setup after loading the view, typically from a nib.
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Fetch Task Lists

- (void)fetchTaskLists {
    self.taskLists = nil;
    self.taskListsFetchError = nil;
    
    GTLServiceTasks *service = self.tasksService;
    
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsList];
    
    self.taskListsTicket = [service executeQuery:query
                               completionHandler:^(GTLServiceTicket *ticket,
                                                   id taskLists, NSError *error) {
                                   // callback
                                   self.taskLists = taskLists;
                                   self.taskListsFetchError = error;
                                   self.taskListsTicket = nil;
                                   
                                   [self updateUI];
                               }];
    [self updateUI];
}


#pragma mark - private

- (NSString *)signedInUsername {
    // Get the email address of the signed-in user
    GTMOAuth2Authentication *auth = self.tasksService.authorizer;
    BOOL isSignedIn = auth.canAuthorize;
    if (isSignedIn) {
        return auth.userEmail;
    } else {
        return nil;
    }
}

- (BOOL)isSignedIn {
    NSString *name = [self signedInUsername];
    return (name != nil);
}

#pragma mark Sign In

- (void)runSigninThenInvokeSelector:(SEL)signInDoneSel {
    // Applications should have client ID and client secret strings
    // hardcoded into the source, but the sample application asks the
    // developer for the strings
    
    
    // Show the OAuth 2 sign-in controller
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[GTMOAuth2ViewControllerTouch class]];
    GTMOAuth2ViewControllerTouch * viewController;
    
    viewController = [GTMOAuth2ViewControllerTouch controllerWithScope:kGTLAuthScopeTasks
                                                             clientID:kclientID
                                                         clientSecret:kclientSecret
                                                     keychainItemName:kKeychainItemName
                                                       completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
                                                           // callback
                                                           [viewController dismissViewControllerAnimated:YES completion:nil];
                                                           if (error == nil) {
                                                               self.tasksService.authorizer = auth;
                                                               if (signInDoneSel) {
                                                                   [self performSelector:signInDoneSel];
                                                               }
                                                           } else {
                                                               self.taskListsFetchError = error;
                                                               //[self updateUI];
                                                               NSLog(@"error");
                                                           }
                                                           

                                                       }];
    //[GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kclientID clientSecret:kclientSecret];
    [self presentViewController:viewController animated:YES completion:nil];
    //[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark UI

- (void)updateUI {
    BOOL isSignedIn = [self isSignedIn];
    NSString *username = [self signedInUsername];
    [_signedInButton_ setTitle:(isSignedIn ? @"Sign Out" : @"Sign In") forState:UIControlStateNormal];
    [_signedInField_ setText:(isSignedIn ? username : @"No")];
    
    //
    // Task lists table
    //
}


#pragma mark IBActions

- (IBAction)signInClicked:(id)sender {
    if (![self isSignedIn]) {
        // Sign in
        [self runSigninThenInvokeSelector:@selector(updateUI)];
    } else {
        // Sign out
        GTLServiceTasks *service = self.tasksService;
        
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
        service.authorizer = nil;
        [self updateUI];
    }
}

- (IBAction)getTaskListsClicked:(id)sender {
    if (![self isSignedIn]) {
        [self runSigninThenInvokeSelector:@selector(fetchTaskLists)];
    } else {
        [self fetchTaskLists];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"TaskListSegueIdentifier"])
    {
        // Get reference to the destination view controller
        TaskListsViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.tasksService = self.tasksService;
    }
}



@end
