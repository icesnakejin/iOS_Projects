//
//  SwipeableCell.h
//  SwipeableTableCell
//
//  Created by Ellen Shapiro on 1/5/14.
//  Copyright (c) 2014 Designated Nerd Software. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SwipePosition) {
    SwipePositionLeftGoback,
    SwipePositionLeftFountion1,
    SwipePositionLeftFuntion2
};

typedef NS_ENUM(NSUInteger, PanDirection) {
    PanDirectionLeft,
    PanDirectionRight
};


@protocol SwipeableCellDelegate <NSObject>
//- (void)buttonOneActionForItemText:(NSString *)itemText;
//- (void)buttonTwoActionForItemText:(NSString *)itemText;
- (void)cellDidOpen:(UITableViewCell *)cell withIndex:(NSUInteger)index;
- (void)cellDidClose:(UITableViewCell *)cell;
@end


@interface SwipeableCell : UITableViewCell

@property (nonatomic, strong) NSString *itemText;
@property (nonatomic, strong) NSString *paddingText;
@property (nonatomic, assign) BOOL allowSwipe;
@property (nonatomic, weak) id <SwipeableCellDelegate> delegate;


- (void)openCell;
- (void)setItem:(NSString *)itemText RightPaddingText1:(NSString*)rightPaddingText1 RightPaddingText2:(NSString*)rightPaddingText2 LeftPaddingText1:(NSString*)leftPaddingText1 LeftPaddingText2:(NSString*)leftPaddingText2;


@end
