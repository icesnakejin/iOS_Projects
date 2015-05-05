//
//  DeferTaskViewController.m
//  GooglePlayer
//
//  Created by Yankun Jin on 4/25/15.
//  Copyright (c) 2015 YankunJin. All rights reserved.
//

#import "DeferTaskViewController.h"

@interface DeferTaskViewController ()

@property (nonatomic, weak) IBOutlet UIDatePicker* datePicker;

@end

@implementation DeferTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismiss)];
    
    [self.view addGestureRecognizer:tap];

    // Do any additional setup after loading the view.
    //[self.view setFrame:CGRectMake(0, 0, 200, 200)];
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

- (void) dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_delegate && [_delegate respondsToSelector:@selector(didDismiss)]) {
        [_delegate didDismiss];
    }
}

- (IBAction)cancelButtonCanceled:(id)sender {
    [self dismiss];
}

- (IBAction) doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_delegate && [_delegate respondsToSelector:@selector(didFinishPickDate:tz:)]) {
        [_delegate didFinishPickDate:_datePicker.date tz:_datePicker.timeZone];
    }
}


@end
