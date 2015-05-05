//
//  TaskListsViewController.h
//  GooglePlayer
//
//  Created by Yankun Jin on 3/31/15.
//  Copyright (c) 2015 YankunJin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GTLTasks.h"
#import "GTMOAuth2ViewControllerTouch.h"

typedef NS_ENUM(NSUInteger, TaskType) {
    TaskTypeDeleted,
    TaskTypeActionNeeded,
    TaskTypeCompleted
};

@interface TaskListsViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton* done;
@property (nonatomic, weak) IBOutlet UIButton* AddTask;
@property (nonatomic, weak) IBOutlet UIButton* AddTaskList;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;

@property (nonatomic, retain) GTLServiceTasks *tasksService;

@end
