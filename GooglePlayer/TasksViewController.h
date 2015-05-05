//
//  TasksViewController.h
//  GooglePlayer
//
//  Created by Yankun Jin on 4/12/15.
//  Copyright (c) 2015 YankunJin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GTLTasks.h"


@interface TasksViewController : UIViewController


@property (nonatomic, weak) IBOutlet UIButton* done;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, retain) NSString* taskListKey;
@property (nonatomic, retain) GTLTasksTask* task;
@property (nonatomic, retain) GTLTasksTaskList* taskList;

@property (nonatomic, retain) GTLServiceTasks *tasksService;
@property (nonatomic, retain) NSArray* taskLists;
@property (nonatomic, retain) NSIndexPath* defaultIndexPath;


@end
