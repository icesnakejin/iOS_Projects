//
//  TaskServiceManager.m
//  GooglePlayer
//
//  Created by Yankun Jin on 4/1/15.
//  Copyright (c) 2015 YankunJin. All rights reserved.
//

#import "TaskServiceManager.h"


#import "GTMOAuth2ViewControllerTouch.h"



@implementation TaskServiceManager

+(instancetype)shared {
    static TaskServiceManager* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TaskServiceManager  alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tasksService = [[GTLServiceTasks alloc] init];
        
        _tasksService.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        _tasksService.retryEnabled = YES;
        
        // Load the OAuth token from the keychain, if it was previously saved
//        NSString *clientID = kclientID;
//        NSString *clientSecret = kclientSecret;
//        
//        GTMOAuth2Authentication *auth;
//        auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
//                                                                     clientID:clientID
//                                                                 clientSecret:clientSecret];
//        self.tasksService.authorizer = auth;

    }
    return self;
}


@end
