//
//  TaskServiceManager.h
//  GooglePlayer
//
//  Created by Yankun Jin on 4/1/15.
//  Copyright (c) 2015 YankunJin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTLTasks.h"

//NSString *const kKeychainItemName = @"GooglePlayer";
//
//NSString *const kclientID = @"195310205871-51i5vfp363o5ihf1eb18uvbvccbos2an.apps.googleusercontent.com";
//NSString *const kclientSecret = @"5F9pL76svGIFgf-zchKowJRY";


@interface TaskServiceManager : NSObject

@property (nonatomic, retain) GTLServiceTasks* tasksService;
+(instancetype)shared;

@end
