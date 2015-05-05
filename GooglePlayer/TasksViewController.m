//
//  TasksViewController.m
//  GooglePlayer
//
//  Created by Yankun Jin on 4/12/15.
//  Copyright (c) 2015 YankunJin. All rights reserved.
//

#import "TasksViewController.h"

#import "TaskListsViewController.h"
#import "SWRevealTableViewCell.h"
#import "GTLUtilities.h"
#import "GTMHTTPFetcherLogging.h"



#define KCLIENTID @"195310205871-51i5vfp363o5ihf1eb18uvbvccbos2an.apps.googleusercontent.com"
#define KCLIENTSECRET @"5F9pL76svGIFgf-zchKowJRY"
#define KKETCHAINITENNAME @"GooglePlayer";

static NSString *RevealCellReuseIdentifier = @"RevealCellReuseIdentifier1";

@interface TasksViewController ()<SWRevealTableViewCellDataSource, SWRevealTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

//@property (nonatomic, retain) GTLTasksTaskLists *taskLists;
@property (nonatomic, retain) NSMutableArray* rows;
@property (nonatomic, retain) GTLServiceTicket *taskListsTicket;
@property (nonatomic, retain) NSError *taskListsFetchError;

@property (nonatomic, retain) GTLServiceTicket *editTaskListTicket;

@property (nonatomic, retain) GTLTasksTasks *tasks;
@property (nonatomic, retain) GTLServiceTicket *tasksTicket;
@property (nonatomic, retain) NSError *tasksFetchError;
@property (nonatomic, weak) IBOutlet UITextField* titeField;
@property (nonatomic, weak) IBOutlet UIDatePicker* dueField;
@property (nonatomic, weak) IBOutlet UITextView* decriptionField;
@property (nonatomic, weak) IBOutlet UIPickerView* listField;
@property (nonatomic, retain) GTLTasksTaskList* selectedList;
@property (retain) GTLServiceTicket *editTaskTicket;



@end

@implementation TasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _titeField.text = _task.title;
    //NSDate* dueDate = _task.due.date;
    if (_task.due) {
        [_dueField setDate:_task.due.date];
        [_dueField setTimeZone:_task.due.timeZone];
    }
    
    if (_task.notes)
        _decriptionField.text = _task.notes;
    //To make the border look very close to a UITextField
    [_decriptionField.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [_decriptionField.layer setBorderWidth:0.5];
    
    //The rounded corner part, where you specify your view's corner radius:
    _decriptionField.layer.cornerRadius = 5;
    _decriptionField.clipsToBounds = YES;
    [_listField selectRow:_defaultIndexPath.section inComponent:0 animated:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    // Do any additional setup after loading the view.
    //[self fetchTasksForSelectedList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Fetch Tasks

- (void)fetchTasksForSelectedList {
    self.tasks = nil;
    self.tasksFetchError = nil;
    
    GTLServiceTasks *service = self.tasksService;
    
    //GTLTasksTaskList *selectedTasklist = [self selectedTaskList];
     NSString *tasklistID = self.taskListKey;
    if (tasklistID) {
       
        
        GTLQueryTasks *query = [GTLQueryTasks queryForTasksListWithTasklist:tasklistID];
        query.showCompleted = YES;
        query.showHidden = YES;
        query.showDeleted = YES;
        
        self.tasksTicket = [service executeQuery:query
                               completionHandler:^(GTLServiceTicket *ticket,
                                                   id tasks, NSError *error) {
                                   // callback
                                   //[self createPropertiesForTasks:tasks];
                                   
                                   self.tasks = tasks;
                                   self.tasksFetchError = error;
                                   self.tasksTicket = nil;
                                   _rows = [[NSMutableArray alloc] init];
                                   for (GTLTasksTask* oneTask in tasks)
                                       [_rows addObject:oneTask];
                                   
                                   [self.tableView reloadData];
                                   //[self updateUI];
                               }];
        //[self updateUI];
    }
}

#pragma UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    if ( section == SectionTitle )
    //        return _sectionTitleRowCount;
    
    return [_rows count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWRevealTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RevealCellReuseIdentifier];
    if ( cell == nil )
    {
        cell = [[SWRevealTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RevealCellReuseIdentifier];
    }
    
    cell.delegate = self;
    cell.dataSource = self;
    
    cell.cellRevealMode = SWCellRevealModeReversedWithAction;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    // Configure the cell...
   
    GTLTasksTask *item = [_rows objectAtIndex:indexPath.row];
    NSString *title = item.title;
    cell.detailTextLabel.text = item.status;
    cell.textLabel.text = title;
    cell.backgroundColor = [UIColor grayColor];
    //cell.imageView.image = [[UIImage imageNamed:@"ipod.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //cell.imageView.tintColor = [UIColor darkGrayColor];
    
    return cell;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    GTMOAuth2Authentication *auth = self.tasksService.authorizer;
    NSString* name = auth.userEmail;
    NSString *title = [NSString stringWithFormat:@"Tasks List of: %@", name];
    return title;
}

#pragma mark - SWRevealTableViewCell delegate

- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell willMoveToPosition:(SWCellRevealPosition)position
{
    if ( position == SWCellRevealPositionCenter )
        return;
    
    for ( SWRevealTableViewCell *cell in [self.tableView visibleCells] )
    {
        if ( cell == revealTableViewCell )
            continue;
        
        [cell setRevealPosition:SWCellRevealPositionCenter animated:YES];
    }
}



- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell didMoveToPosition:(SWCellRevealPosition)position
{
    //    if (position > SWCellRevealPositionCenter) {
    //         NSIndexPath *indexPath = [self.tableView indexPathForCell:revealTableViewCell];
    //        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //    }
}


#pragma mark - SWRevealTableViewCell data source

- (NSArray*)leftButtonItemsInRevealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell
{
    SWCellButtonItem *item1 = [SWCellButtonItem itemWithTitle:@"Delete" handler:^(SWCellButtonItem *item, SWRevealTableViewCell *cell)
                               {
                                   NSLog( @"Select Tapped");
                                   NSIndexPath* indexPath = [self.tableView indexPathForCell:revealTableViewCell];
                                   [self deleteTaskListAtIndexpaths:@[indexPath]];
                                   return YES;
                               }];
    
    item1.backgroundColor = [UIColor redColor];
    item1.tintColor = [UIColor whiteColor];
    item1.width = 50;
    
    SWCellButtonItem *item2 = [SWCellButtonItem itemWithTitle:@"Archive" handler:^(SWCellButtonItem *item, SWRevealTableViewCell *cell)
                               {
                                   NSLog( @"Snap Tapped");
                                   return YES;
                               }];
    
    item2.backgroundColor = [UIColor greenColor];
    item2.image = [UIImage imageNamed:@"heart.png"];
    item2.width = 50;
    item2.tintColor = [UIColor whiteColor];
    
    NSLog( @"Providing left Items");
    return @[item1,item2];
}

#pragma mark - private

- (void) deleteTaskListAtIndexpaths:(NSArray*) indexPaths {
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.tableView beginUpdates];
        [_rows removeObjectAtIndex:[(NSIndexPath*)indexPaths[0] row]];
        //[UIView animateWithDuration:0.5f animations:^ {
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    } completion:^(BOOL finished) {
        // completion code
    }];
//    } completion:^(BOOL finished) {
//        [self.tableView reloadData];
//    }];
}

- (IBAction)updateSelectedTask:(id)sender {
    NSString *title = _titeField.text;
    NSString *desc = _decriptionField.text;
    NSDate* newDueDate = _dueField.date;
    if ([title length] > 0) {
        // Rename the selected task
        
        // Rather than update the object with a complete replacement, we'll make
        // a patch object containing just the changes
        GTLTasksTask *patchObject = [GTLTasksTask object];
        patchObject.title = title;
        patchObject.notes = desc;
        GTLDateTime* newDate = [GTLDateTime dateTimeWithDate:_dueField.date timeZone:_dueField.timeZone];

//        NSDateComponents* components = [[NSDateComponents alloc] init];
//        components.year = [_dueField.date];
        
        //newDate.timeZone = _dueField.timeZone;
        patchObject.due = newDate;
        GTLTasksTask *task = _task;
        GTLTasksTaskList *tasklist = _taskList;
        if (_taskList != _selectedList) {
            [_task setHidden:[NSNumber numberWithInt:1]];
            [self deleteSelectedTask];
            [self addATask:patchObject];
            //[patchObject setHidden:[NSNumber numberWithInt:1]];
        }

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
                                          _titeField.text = @"";
                                          _decriptionField.text = @"";
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      } else {
//                                          [self displayAlert:@"Error"
//                                                      format:@"%@", error];
//                                          [self updateUI];
                                      }
                                  }];
        //[self updateUI];
    }
}

- (void)addATask:(GTLTasksTask *) task {
    
        // Make a new task
        //GTLTasksTask *task = task;
        //task.title = title;
        
        GTLTasksTaskList *tasklist = _selectedList;
        GTLQueryTasks *query = [GTLQueryTasks queryForTasksInsertWithObject:task
                                                                   tasklist:tasklist.identifier];
        GTLServiceTasks *service = self.tasksService;
        self.editTaskTicket = [service executeQuery:query
                                  completionHandler:^(GTLServiceTicket *ticket,
                                                      id item, NSError *error) {
                                      // callback
                                      self.editTaskTicket = nil;
                                      GTLTasksTask *task = item;
                                      
                                      if (error == nil) {
                                          //                                          [self displayAlert:@"Task Added"
                                          //                                                      format:@"Added task \"%@\"", task.title];
                                          //[self fetchTasksForSelectedList];
                                          //_textField.text = @"";
                                          
//                                          [self dismissViewControllerAnimated:YES completion:nil];
//                                          if (_delegate && [_delegate respondsToSelector:@selector(didFinishAdd)]) {
//                                              [_delegate didFinishAdd];
//                                          }
                                      } else {
                                          //                                          [self displayAlert:@"Error"
                                          //                                                      format:@"%@", error];
                                          //[self updateUI];
                                      }
                                  }];
        //[self updateUI];
}

#pragma mark Delete a Task

- (void)deleteSelectedTask {
    // Delete a task
    GTLTasksTask *task = _task;
    //    NSString *taskTitle = task.title;
    
    GTLTasksTaskList *tasklist = _taskList;
    GTLQueryTasks *query = [GTLQueryTasks queryForTasksDeleteWithTasklist:tasklist.identifier
                                                                     task:task.identifier];
    GTLServiceTasks *service = self.tasksService;
    self.editTaskTicket = [service executeQuery:query
                              completionHandler:^(GTLServiceTicket *ticket,
                                                  id item, NSError *error) {
                                  // callback
                                  self.editTaskTicket = nil;
                                  
                                  if (error == nil) {
                                      
                                      //[self deleteTaskListAtIndexpaths:@[indexPath]];
                                  } else {
                                      
                                  }
                              }];
}




# pragma mark - IBOutlet

- (IBAction)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissKeyboard {
    [_decriptionField resignFirstResponder];
    [_titeField resignFirstResponder];
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component

{
    return  _taskLists.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    _selectedList = (GTLTasksTaskList*)_taskLists[row];
    return [(GTLTasksTaskList*)_taskLists[row] title];
}





@end
