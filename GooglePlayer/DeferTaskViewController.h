//
//  DeferTaskViewController.h
//  GooglePlayer
//
//  Created by Yankun Jin on 4/25/15.
//  Copyright (c) 2015 YankunJin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DeferTaskDelegate <NSObject>

-(void) didFinishPickDate:(NSDate *)date tz:(NSTimeZone*) zone;
-(void) didDismiss;

@end

@interface DeferTaskViewController : UIViewController

@property (nonatomic, weak) id<DeferTaskDelegate> delegate;

@end
