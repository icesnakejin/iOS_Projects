//
//  TaskListsViewController.m
//  GooglePlayer
//
//  Created by Yankun Jin on 3/31/15.
//  Copyright (c) 2015 YankunJin. All rights reserved.
//

#import "TaskListsViewController.h"
#import "GTLUtilities.h"
#import "GTMHTTPFetcherLogging.h"
#import "TasksViewController.h"
#import "SwipeableCell.h"
#import "NavigationCollectionViewCell.h"
#import "creationViewController.h"
#import "DeferTaskViewController.h"

#define KCLIENTID @"195310205871-51i5vfp363o5ihf1eb18uvbvccbos2an.apps.googleusercontent.com"
#define KCLIENTSECRET @"5F9pL76svGIFgf-zchKowJRY"
#define KKETCHAINITENNAME @"GooglePlayer";

static NSString *RevealCellReuseIdentifier = @"RevealCellReuseIdentifier";

// Constants that ought to be defined by the API
NSString *const kTaskStatusCompleted = @"completed";
NSString *const kTaskStatusNeedsAction = @"needsAction";


@interface TaskListsViewController ()<SwipeableCellDelegate, UIPopoverPresentationControllerDelegate, creationDelegate, DeferTaskDelegate>


@property (nonatomic, retain) GTLTasksTaskLists *taskLists;
@property (nonatomic, retain) NSMutableArray* rows;
@property (nonatomic, retain) NSMutableArray* sections;
@property (nonatomic, retain) NSMutableArray* taskListKeys;
@property (nonatomic, retain) GTLServiceTicket *taskListsTicket;
@property (nonatomic, retain) NSError *taskListsFetchError;
@property (nonatomic, retain) GTLTasksTaskList* selectedTaskList;

@property (nonatomic, retain) GTLServiceTicket *editTaskListTicket;

@property (nonatomic, retain) GTLTasksTasks *tasks;
@property (nonatomic, retain) GTLServiceTicket *tasksTicket;
@property (nonatomic, retain) NSError *tasksFetchError;
@property (nonatomic, assign) NSUInteger currentSectionNo;
@property (nonatomic, assign) NSUInteger currentTaskType;
@property (nonatomic, retain) UIAlertView* alertView;
@property (nonatomic, retain) UIPopoverController *createViewPopover;
@property (nonatomic, retain) UIVisualEffectView *backgroundView;

@property (nonatomic, retain) creationViewController* createPage;
@property (nonatomic, retain) DeferTaskViewController* deferVC;
@property (nonatomic, retain) NSIndexPath* selectedIndexPath;

@property (retain) GTLServiceTicket *editTaskTicket;

@end

@implementation TaskListsViewController

- (void)viewDidLoad {
    if ([self isSignedIn]) {
        [self fetchTaskLists:TaskTypeActionNeeded];
        _currentTaskType = 1;
       
        self.preferredContentSize = CGSizeMake(200, 200);
//        [self setContentSizeForViewInPopover:CGSizeMake(200, 200)];
        creationViewController *content = [self.storyboard instantiateViewControllerWithIdentifier:@"creationView"];
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        UIVisualEffectView *visualEffectView;
        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
        
        //[imageView addSubview:visualEffectView];
        _backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _backgroundView.backgroundColor = [UIColor clearColor];
        _backgroundView.frame = self.view.bounds;
        // Setup the popover for use in the detail view.
        //self.createViewPopover = [[UIPopoverController alloc] initWithContentViewController:content];
        //self.createViewPopover.popoverContentSize = CGSizeMake(100., 100.);
        //self.createViewPopover.delegate = self;
        
//        // Setup the popover for use from the navigation bar.
//        self.barButtonItemPopover = [[UIPopoverController alloc] initWithContentViewController:content];
//        self.barButtonItemPopover.popoverContentSize = CGSizeMake(320., 320.);
//        self.barButtonItemPopover.delegate = self;

        
        
    }
}

    // Do any additional setup after loading the view

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) deleteTaskListAtIndexpaths:(NSArray*) indexPaths {
    NSIndexPath* indexPath = indexPaths[0];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([_rows[indexPath.section] count] > 0) [_rows[indexPath.section] removeObjectAtIndex:[indexPath row]];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        

    });
    
    //[UIView animateWithDuration:0 delay:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
        //[self.tableView beginUpdates];
       
//        if ([_rows[indexPath.section] count] == 0) {
//            [_sections removeObjectAtIndex:indexPath.section];
//        }
//        if ([_rows[indexPath.section] count] == 0)
//            [_sections removeObjectAtIndex:indexPath.section];
        
        //[UIView animateWithDuration:0.5f animations:^ {
//        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        //[self.tableView endUpdates];
    //} completion:^(BOOL finished) {
        //[self deleteSelectedTask:indexPath];
    //}];

}

- (BOOL)isSignedIn {
    NSString *name = [self signedInUsername];
    return (name != nil);
}

- (void)showAlertView {
    if (!_alertView) {
        _alertView = [[UIAlertView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
        [_alertView setCenter:self.view.center];
        _alertView.title = @"Loading...";
    }
    //UIAlertView* alertView = [[UIAlertView alloc] init];
    
    [_alertView show];
}

- (void)dismissAlertView {
    [_alertView dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark Fetch Task Lists

- (void)fetchTaskLists:(TaskType)type {
    self.taskLists = nil;
    self.taskListsFetchError = nil;
    self.currentSectionNo = 0;
    
    GTLServiceTasks *service = self.tasksService;
    
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsList];
    [self showAlertView];
    self.taskListsTicket = [service executeQuery:query
                               completionHandler:^(GTLServiceTicket *ticket,
                                                   id taskLists, NSError *error) {
                                   // callback
                                   self.taskLists = taskLists;
                                   self.sections = [NSMutableArray arrayWithArray:self.taskLists.items];
                                   self.rows = [[NSMutableArray alloc] init];
                                   self.taskListKeys = [[NSMutableArray alloc] init];
                                   self.taskListsFetchError = error;
                                   self.taskListsTicket = nil;
                                   //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                                   //dispatch_group_t group = dispatch_group_create();
                                   for (GTLTasksTaskList* list in taskLists) {
                                       [self.taskListKeys addObject:list.identifier];
                                       // Add a task to the group
                                       
                                   }
                                   //dispatch_group_async(group, queue, ^{
                                   [self fetchTasksForSelectedList : type];
                                   //});
                                   //[self.tableView reloadData];
                               }];
}

#pragma mark Fetch Tasks

- (void)fetchTasksForSelectedList:(TaskType) type {
    self.tasks = nil;
    self.tasksFetchError = nil;
    
    GTLServiceTasks *service = self.tasksService;
    
    //GTLTasksTaskList *selectedTasklist = [self selectedTaskList];
    NSString *tasklistID = self.taskListKeys[self.currentSectionNo];
    if (tasklistID) {
        
        
        GTLQueryTasks *query = [GTLQueryTasks queryForTasksListWithTasklist:tasklistID];
        
        switch (type) {
            case TaskTypeActionNeeded:
                query.showCompleted = NO;
                query.showHidden = NO;
                query.showDeleted = NO;
                break;
                
            case TaskTypeDeleted:
                query.showCompleted = NO;
                query.showHidden = NO;
                query.showDeleted = YES;
                break;
                
            case TaskTypeCompleted:
                query.showCompleted = YES;
                query.showHidden = NO;
                query.showDeleted = NO;
                break;
            default:
                break;
        }
        self.tasksTicket = [service executeQuery:query
                               completionHandler:^(GTLServiceTicket *ticket,
                                                   id tasks, NSError *error) {
                                   // callback
                                   //[self createPropertiesForTasks:tasks];
                                   
                                   self.tasks = tasks;
                                   self.tasksFetchError = error;
                                   self.tasksTicket = nil;
                                   if (!_rows)
                                       _rows = [[NSMutableArray alloc] init];
                                
                                   NSMutableArray* oneList = [[NSMutableArray alloc] init];
                                   for (GTLTasksTask* oneTask in tasks) {
                                       switch (_currentTaskType) {
                                           case 0:
                                               if (oneTask.deleted.integerValue == 1) {
                                                   [oneList addObject:oneTask];
                                               }
                                               break;
                                           case 1:
                                               if (oneTask.deleted.integerValue == 0 && [oneTask.status isEqualToString:@"needsAction"]) {
                                                   [oneList addObject:oneTask];
                                               }
                                               break;
                                           case 2:
                                               if ([oneTask.status isEqualToString:@"completed"]) {
                                                   [oneList addObject:oneTask];
                                               }
                                               break;
                                               
                                           default:
                                               break;
                                       }
                                       
                                   }
//                                   if (oneList.count == 0) {
//                                       [_sections removeObjectAtIndex:self.currentSectionNo];
//                                   }
                                   [_rows addObject:oneList];
                                   self.currentSectionNo ++;
                                   if (self.currentSectionNo < [self.taskLists.items count]){
                                       [self fetchTasksForSelectedList:type];
                                   } else if (self.currentSectionNo == [self.taskLists.items count])
                                    
                                   [self.tableView reloadData];
                                   [self dismissAlertView];
                                   //[self updateUI];
                               }];
        //[self updateUI];
    }
}




#pragma mark - TableViewdataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if ( section == SectionTitle )
//        return _sectionTitleRowCount;
    
    return [[_rows objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GTLTasksTask *item = [[_rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *title = item.title;
    SwipeableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    //NSString *item = _objects[indexPath.row];
    //cell.paddingText = @"delete";
    [cell setItem:title RightPaddingText1:@"Defer" RightPaddingText2:@"Delete" LeftPaddingText1:@"Update" LeftPaddingText2:@"Complete" ];
    cell.detailTextLabel.text = item.status;
    cell.delegate = self;
    return cell;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    GTMOAuth2Authentication *auth = self.tasksService.authorizer;
//    NSString* name = auth.userEmail;
    GTLTasksTaskList* list = [_sections objectAtIndex:section];
    NSString *title = list.title;
    //[NSString stringWithFormat:@"Tasks List of: %@", name];
    return title;
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete;
//}
//
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//}
//
//
//- (NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"primer"
//    handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
//    {
//        NSLog( @"M'han tocat primer");
//    }];
//
//    action1.backgroundColor = [UIColor redColor];
//
//    UITableViewRowAction *action2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"seg"
//    handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
//    {
//        NSLog( @"M'han tocat segon");
//    }];
//
//    action2.backgroundColor = [UIColor orangeColor];
//
//    return @[action1,action2];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //_selectedTaskList = [[_taskLists items] objectAtIndex:indexPath.row];
    //[self performSegueWithIdentifier:@"TasksSegueIdentifier" sender:tableView];
    TasksViewController *taskDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"TaskDetailViewControllerIdentifier"];
    taskDetail.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    taskDetail.task = _rows[indexPath.section][indexPath.row];
    taskDetail.taskLists = self.sections;
    taskDetail.tasksService = self.tasksService;
    taskDetail.taskList = _sections[indexPath.section];
    taskDetail.defaultIndexPath = indexPath;
//    CATransition* transition = [CATransition animation];
//    transition.duration = 0.3;
//    transition.type = kCATransitionMoveIn;
//    transition.subtype = kCATransitionFromRight;
//    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    //[self.navigationController pushViewController:taskDetail animated:YES];
    [self presentViewController:taskDetail animated:YES completion:nil];
    //[self p]
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // customize here the cell object before it is displayed.
    
    
        //[cell setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1]];
        //[cell.contentView setBackgroundColor:[UIColor clearColor]];
}

#pragma - mark UICollectionViewDelegateAndDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    // _data is a class member variable that contains one array per section.
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    //NSArray* sectionArray = [_data objectAtIndex:section];
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NavigationCollectionViewCell* newCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell"
                                                                           forIndexPath:indexPath];
    
    //newCell.contentVie = @"test"];
    //newCell.backgroundColor = //[UIColor greenColor];
    if (indexPath.row == 0) {
        [newCell setItem:@"D"];
    }
    
    if (indexPath.row == 1) {
        [newCell setItem:@"A"];
        [newCell setSelected:YES];
    }
    
    if (indexPath.row == 2) {
        [newCell setItem:@"C"];
    }
    
    
    return newCell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _currentTaskType) {
        return;
    }
    
    switch (indexPath.row) {
        case 0:
            [self fetchTaskLists:TaskTypeDeleted];
            break;
        case 1:
            [self fetchTaskLists:TaskTypeActionNeeded];
            break;
        case 2:
            [self fetchTaskLists:TaskTypeCompleted];
        default:
            break;
    }
    _currentTaskType = indexPath.row;
}




#pragma mark Defer a Task

- (void) deferSelectedTask: (NSIndexPath*) indexPath {
    GTLTasksTask *task = [[_rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    //    NSString *taskTitle = task.title;
    
    GTLTasksTaskList *tasklist = [_sections objectAtIndex:indexPath.section];
    
}

#pragma mark Delete a Task

- (void)deleteSelectedTask:(NSIndexPath*) indexPath {
    // Delete a task
    GTLTasksTask *task = [[_rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    NSString *taskTitle = task.title;
    
    GTLTasksTaskList *tasklist = [_sections objectAtIndex:indexPath.section];
    GTLQueryTasks *query = [GTLQueryTasks queryForTasksDeleteWithTasklist:tasklist.identifier
                                                                     task:task.identifier];
    GTLServiceTasks *service = self.tasksService;
    self.editTaskTicket = [service executeQuery:query
                              completionHandler:^(GTLServiceTicket *ticket,
                                                  id item, NSError *error) {
                                  // callback
                                  self.editTaskTicket = nil;
                                  
                                  if (error == nil) {
                                      
                                      [self deleteTaskListAtIndexpaths:@[indexPath]];
                                  } else {
                                      
                                  }
                              }];
}

#pragma mark Change a Task's Complete Status

- (void)completeSelectedTask:(NSIndexPath*) indexPath {
    // Mark a task as completed or incomplete
    GTLTasksTask *selectedTask = [[_rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    GTLTasksTask *patchObject = [GTLTasksTask object];
    
    if ([selectedTask.status isEqual:kTaskStatusCompleted]) {
        // Change the status to not complete
        patchObject.status = kTaskStatusNeedsAction;
        patchObject.completed = [GTLObject nullValue]; // remove the completed date
    } else {
        // Change the status to complete
        patchObject.status = kTaskStatusCompleted;
    }
    
    GTLTasksTaskList *tasklist = [_sections objectAtIndex:indexPath.section] ;
    GTLQueryTasks *query = [GTLQueryTasks queryForTasksPatchWithObject:patchObject
                                                              tasklist:tasklist.identifier
                                                                  task:selectedTask.identifier];
    GTLServiceTasks *service = self.tasksService;
    self.editTaskTicket = [service executeQuery:query
                              completionHandler:^(GTLServiceTicket *ticket,
                                                  id item, NSError *error) {
                                  // callback
                                  self.editTaskTicket = nil;
                                  GTLTasksTask *task = item;
                                  
                                  if (error == nil) {
                                      NSString *displayStatus;
                                      if ([task.status isEqual:kTaskStatusCompleted]) {
                                          displayStatus = @"complete";
                                      } else {
                                          displayStatus = @"incomplete";
                                      }
                                      
                                      [self deleteTaskListAtIndexpaths:@[indexPath]];
                                      //[self fetchTaskLists];
                                  } else {
                                      
                                  }
                              }];
    
}


#pragma mark - segue

- (IBAction) popoverByslide:(id)sender {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"TasksSegueIdentifier"])
    {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        // Get reference to the destination view controller
        TasksViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.taskListKey = [(GTLTasksTaskList*)[self.rows objectAtIndex:indexPath.row] identifier];
        //if (!vc.tasksService) {
        vc.tasksService = self.tasksService;
            
            // Have the service object set tickets to fetch consecutive pages
            // of the feed so we do not need to manually fetch them
//            vc.tasksService.shouldFetchNextPages = YES;
//            
//            // Have the service object set tickets to retry temporary error conditions
//            // automatically
//            vc.tasksService.retryEnabled = YES;
//        }

    }
    
    if ([[segue identifier] isEqualToString:@"addTaskList"]) {
        UINavigationController * nvc = segue.destinationViewController;
        _createPage = (creationViewController*)nvc;
        [_createPage setCreationType:@"addTaskList"];
        [_createPage setTasksService:self.tasksService];
        _createPage.preferredContentSize = CGSizeMake(200, 100);
        _createPage.delegate = self;
        UIPopoverPresentationController * pvc = nvc.popoverPresentationController;
        pvc.delegate = self;
    }
    
    if ([[segue identifier] isEqualToString:@"addTasks"]) {
        UINavigationController * nvc = segue.destinationViewController;
        
        UIPopoverPresentationController * pvc = nvc.popoverPresentationController;
        pvc.delegate = self;
        CGRect rect = self.view.frame ;
        //[pvc setPopoverLayoutMargins:UIEdgeInsetsMake(0, rect.origin.x, 0, 0)];
        //pvc.preferredContentSize = CGSizeMake(200, 200);
        
        _createPage = (creationViewController*)nvc;
        //[_createPage setCreationType:@"addTaskList"];
        [_createPage setCreationType:@"addTasks"];
        [_createPage setTaskLists:self.sections];
        [_createPage setTasksService:self.tasksService];
        _createPage.preferredContentSize = CGSizeMake(200, 200);
        _createPage.delegate = self;
    }
}

#pragma mark == UIPopoverPresentationControllerDelegate ==
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - Managing popovers

//- (IBAction)showPopover:(id)sender
//{
//    // Set the sender to a UIButton.
//    UIButton *tappedButton = (UIButton *)sender;
//    
//     creationViewController* pickerController = [self.storyboard instantiateViewControllerWithIdentifier:@"creationView"];
//    UIView *viewV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//    [viewV setBackgroundColor:[UIColor clearColor]];
//    
//    UIPopoverPresentationController *popOverController = pickerController .popoverPresentationController;
//    //popOverController.popoverContentSize = CGSizeMake(150, 160);
//    //[popOverController setDelegate:self];
//    
//    popOverController.sourceView = self.view;
//    popOverController.sourceRect = tappedButton.frame;
//    popOverController.permittedArrowDirections = UIPopoverArrowDirectionUp;
//    
//    [self presentViewController:popOverController
//                       animated:YES
//                     completion:nil];
//    
//    // Present the popover from the button that was tapped in the detail view.
//    //[self.createViewPopover presentPopoverFromRect:tappedButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    
//    // Set the last button tapped to the current button that was tapped.
//    //self.lastTappedButton = sender;
//}


- (void)cellDidOpen:(UITableViewCell *)cell withIndex:(NSUInteger)index
{
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
    _selectedIndexPath = currentEditingIndexPath;
    switch (index) {
        case 0: {
                        break;
        }
        case 1:
            [self  deleteSelectedTask:currentEditingIndexPath];
            break;
        case 3:
            [self  completeSelectedTask:currentEditingIndexPath];
        default:
        {
            //[self deleteSelectedTask:currentEditingIndexPath];
        }
            break;
    }
    
    //[self.cellsCurrentlyEditing addObject:currentEditingIndexPath];
}

- (void)cellDidClose:(UITableViewCell *)cell
{
    //[self.cellsCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
    _selectedIndexPath = currentEditingIndexPath;
    _deferVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DeferVC"];
    
    _deferVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    _backgroundView.opaque = NO;
//    _backgroundView.alpha = 0.5;
//    _backgroundView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];
    [self.view addSubview:_backgroundView];
    _deferVC.delegate = self;
    [self presentViewController:_deferVC animated:YES completion:nil];
    
    //[self.navigationController pushViewController:deferVC animated:YES];
    //SecondViewController *vc = [[SecondViewController alloc] init];
    //[self addChildViewController:deferVC];
    //[self didMoveToParentViewController:deferVC];

}

- (void)updateSelectedTaskwithDate:(NSDate*) date tz:(NSTimeZone*) zone {
    //NSString *title = _titeField.text;
    //NSString *desc = _decriptionField.text;
    //NSDate* newDueDate = date;
    
        // Rename the selected task
        
        // Rather than update the object with a complete replacement, we'll make
        // a patch object containing just the changes
    GTLTasksTask *task = [[_rows objectAtIndex:_selectedIndexPath.section] objectAtIndex:_selectedIndexPath.row];
        GTLTasksTask *patchObject = [GTLTasksTask object];
        patchObject.title = task.title;
        patchObject.notes = task.notes;
        GTLDateTime* newDate = [GTLDateTime dateTimeWithDate:date timeZone:zone];
        
        //        NSDateComponents* components = [[NSDateComponents alloc] init];
        //        components.year = [_dueField.date];
        
        //newDate.timeZone = _dueField.timeZone;
        patchObject.due = newDate;
    
        GTLTasksTaskList *tasklist = [_sections objectAtIndex:_selectedIndexPath.section];;
        GTLQueryTasks *query = [GTLQueryTasks queryForTasksPatchWithObject:patchObject
                                                                  tasklist:tasklist.identifier
                                                                      task:task.identifier];
        GTLServiceTasks *service = self.tasksService;
        self.editTaskTicket = [service executeQuery:query
                                  completionHandler:^(GTLServiceTicket *ticket,
                                                      id item, NSError *error) {
                                      // callback
                                      self.editTaskTicket = nil;
                                      GTLTasksTask *task = item;
                                      
                                      if (error == nil) {
                                          //                                          [self displayAlert:@"Task Updated"
                                          //                                                      format:@"Renamed task to \"%@\"", task.title];
                                          //                                          [self fetchTasksForSelectedList];
                                          //                                          [taskNameField_ setStringValue:@""];
                                          //_titeField.text = @"";
                                          //_decriptionField.text = @"";
                                          //[self dismissViewControllerAnimated:YES completion:nil];
                                      } else {
                                          //                                          [self displayAlert:@"Error"
                                          //                                                      format:@"%@", error];
                                          //                                          [self updateUI];
                                      }
                                  }];
        //[self updateUI];
    
}




#pragma - DeferTasksDelegate

- (void) didFinishPickDate:(NSDate *)date tz:(NSTimeZone*) zone {
    [_backgroundView removeFromSuperview];
    [self updateSelectedTaskwithDate:date tz:zone];
}

- (void) didDismiss {
    [_backgroundView removeFromSuperview];
}

#pragma - creationDelegate

- (void) didFinishAdd {
    [self fetchTaskLists:_currentTaskType];
}


#pragma - IBOutlet

- (IBAction)doneButonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
