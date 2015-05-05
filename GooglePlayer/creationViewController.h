//
//  creationViewController.h
//  GooglePlayer
//
//  Created by Yankun Jin on 4/24/15.
//  Copyright (c) 2015 YankunJin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLServiceTasks.h"

@protocol creationDelegate <NSObject>

@optional
- (void) didFinishAdd;
@end

@interface creationViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, retain) NSString* creationType;
@property (nonatomic, retain) NSArray* taskLists;
@property (nonatomic, retain) GTLServiceTasks *tasksService;
@property (nonatomic, weak) id<creationDelegate> delegate;
//@property (nonatomic, retain) NSArray* taskLists;

@end
