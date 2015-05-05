//
//  creationViewController.m
//  GooglePlayer
//
//  Created by Yankun Jin on 4/24/15.
//  Copyright (c) 2015 YankunJin. All rights reserved.
//

#import "creationViewController.h"
#import "GTLTasksTaskList.h"
#import "GTLTasksTask.h"
#import "GTLQueryTasks.h"



@interface creationViewController ()

@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, retain) GTLTasksTaskList* selectedList;
@property (nonatomic, retain) GTLServiceTicket *editTaskTicket;
@property (nonatomic, retain) GTLServiceTicket *editTaskListTicket;



@end

@implementation creationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([_creationType isEqualToString:@"addTaskList"]) {
        [_picker setHidden:YES];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma IBOutlet

-(IBAction) doneButtonTouched {
    
    if ([_creationType isEqualToString:@"addTasks"]) {
        [self addATask];
    } else if ([_creationType isEqualToString:@"addTaskList"]) {
        [self addATaskList];
    }
    
    
}

#pragma mark Add a Task List

- (void)addATaskList {
    NSString *title = _textField.text;
    if ([title length] > 0) {
        // Make a new task list
        GTLTasksTaskList *tasklist = [GTLTasksTaskList object];
        tasklist.title = title;
        
        GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsInsertWithObject:tasklist];
        
        GTLServiceTasks *service = self.tasksService;
        self.editTaskListTicket = [service executeQuery:query
                                      completionHandler:^(GTLServiceTicket *ticket,
                                                          id item, NSError *error) {
                                          // callback
                                          self.editTaskListTicket = nil;
                                          GTLTasksTaskList *tasklist = item;
                                          
                                          if (error == nil) {
                                              _textField.text = @"";
                                              [self dismissViewControllerAnimated:YES completion:nil];
                                              if (_delegate && [_delegate respondsToSelector:@selector(didFinishAdd)]) {
                                                  [_delegate didFinishAdd];
                                              }
//                                              [self displayAlert:@"Task List Added"
//                                                          format:@"Added task list \"%@\"", tasklist.title];
//                                              [self fetchTaskLists];
//                                              [taskListNameField_ setStringValue:@""];
                                          } else {
//                                              [self displayAlert:@"Error"
//                                                          format:@"%@", error];
//                                              [self updateUI];
                                          }
                                      }];
        //[self updateUI];
    } else
        [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)addATask {
    NSString *title = _textField.text;
    if ([title length] > 0) {
        // Make a new task
        GTLTasksTask *task = [GTLTasksTask object];
        task.title = title;
        
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
                                          _textField.text = @"";
                                          
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                          if (_delegate && [_delegate respondsToSelector:@selector(didFinishAdd)]) {
                                              [_delegate didFinishAdd];
                                          }
                                      } else {
//                                          [self displayAlert:@"Error"
//                                                      format:@"%@", error];
                                          //[self updateUI];
                                      }
                                  }];
        //[self updateUI];
    } else
        [self dismissViewControllerAnimated:YES completion:nil];
}




@end
