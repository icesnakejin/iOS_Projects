//
//  SwipeableCell.m
//  SwipeableTableCell
//
//  Created by Ellen Shapiro on 1/5/14.
//  Copyright (c) 2014 Designated Nerd Software. All rights reserved.
//

#import "SwipeableCell.h"

@interface SwipeableCell() <UIGestureRecognizerDelegate>

//@property (nonatomic, weak) IBOutlet UIButton *button1;
//@property (nonatomic, weak) IBOutlet UIButton *button2;
@property (nonatomic, weak) IBOutlet UIView *myContentView;
@property (nonatomic, weak) IBOutlet UIView *myPaddingView;
@property (nonatomic, weak) IBOutlet UILabel *myTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *myStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *myPaddingTextLabel;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingtLayoutConstraintConstant;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewWeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *paddingViewRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *paddingViewLeftConstraint;
@property (nonatomic, retain) NSString* rightPaddingText1;
@property (nonatomic, retain) NSString* rightPaddingText2;
@property (nonatomic, retain) NSString* leftPaddingText1;
@property (nonatomic, retain) NSString* leftPaddingText2;
@property (nonatomic, assign) PanDirection currentDirection;


@end

static CGFloat const kBounceValue = 5.0f;

@implementation SwipeableCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
    self.panRecognizer.delegate = self;
    [self.myContentView addGestureRecognizer:self.panRecognizer];
    //[self.myContentView setBackgroundColor:[UIColor redColor]];
    //[self.myPaddingView setBackgroundColor:[UIColor grayColor]];
    //[self.myPaddingTextLabel setBackgroundColor:[UIColor yellowColor]];
    
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self resetConstraintContstantsToZero:NO inDirection:_currentDirection  notifyDelegateDidClose:NO];
}

- (void)openCell
{
    [self setConstraintsToShowAllButtons:NO inDirection:_currentDirection  notifyDelegateDidOpen:NO functionIndex:5];
}

//- (IBAction)buttonClicked:(id)sender
//{
//    if (sender == self.button1) {
//        [self.delegate buttonOneActionForItemText:self.itemText];
//    } else if (sender == self.button2) {
//        [self.delegate buttonTwoActionForItemText:self.itemText];
//    } else {
//        NSLog(@"Clicked unknown button!");
//    }
//}

- (void)setItem:(NSString *)itemText
                RightPaddingText1:(NSString*)rightPaddingText1
                RightPaddingText2:(NSString*)rightPaddingText2
                LeftPaddingText1:(NSString*)leftPaddingText1
                LeftPaddingText2:(NSString*)leftPaddingText2
{
    //Update the instance variable
    _itemText = itemText;
    _leftPaddingText1 = leftPaddingText1;
    _leftPaddingText2 = leftPaddingText2;
    _rightPaddingText1 = rightPaddingText1;
    _rightPaddingText2 = rightPaddingText2;
    
    //Set the text to the custom label.
    self.myTextLabel.text = _itemText;
}

- (void)setPaddingText:(NSString *)itemText
{
    //Update the instance variable
    _paddingText = itemText;
    
    //Set the text to the custom label.
    self.myPaddingTextLabel.text = _paddingText;
}

- (CGFloat)buttonTotalWidth
{
    return self.contentView.frame.size.width;
}

- (void)panThisCell:(UIPanGestureRecognizer *)recognizer
{
    CGPoint currentPoint = [recognizer translationInView:self.myContentView];
    CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
    if (deltaX >= 0)
        [self panThisCellRight:recognizer];
    else [self panThisCellLeft:recognizer];
        
}

- (void)panThisCellLeft:(UIPanGestureRecognizer*)recognizer {
//    if (!self.allowSwipe) {
//        return;
//    }
    _currentDirection = PanDirectionLeft;
    CGPoint velocity = [recognizer velocityInView:self.myContentView];
    if (fabs(velocity.y) > fabs(velocity.x) + 10) {
        return;
    }
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.panStartPoint = [recognizer translationInView:self.myContentView];
            self.startingtLayoutConstraintConstant = self.contentViewRightConstraint.constant;
            self.paddingViewLeftConstraint.constant = self.startingtLayoutConstraintConstant;
            self.paddingViewRightConstraint.constant = self.startingtLayoutConstraintConstant;
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [recognizer translationInView:self.myContentView];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            BOOL panningLeft = NO;
            if (currentPoint.x < self.panStartPoint.x) {  //1
                panningLeft = YES;
            }
            
            if (self.startingtLayoutConstraintConstant == 0) { //2
                //The cell was closed and is now opening
                if (!panningLeft) {
                    CGFloat constant = MAX(-deltaX, 0); //3
                    if (constant == 0) { //4
                        //[self resetConstraintContstantsToZero:YES inDirection:PanDirectionLeft notifyDelegateDidClose:NO]; //5
                    } else {
                        self.contentViewRightConstraint.constant = constant; //6
                        self.contentViewLeftConstraint.constant = 0;
                        self.paddingViewLeftConstraint.constant = self.contentView.frame.size.width - constant;
                    }
                } else {
                    CGFloat constant = MIN(-deltaX, [self buttonTotalWidth]); //7
                    if (constant == [self buttonTotalWidth]) { //8
                        [self setConstraintsToShowAllButtons:YES inDirection:PanDirectionLeft  notifyDelegateDidOpen:NO functionIndex:5]; //9
                    } else {
                        CGFloat halfOfButtonOne = [self buttonTotalWidth] / 2; //2
                        CGFloat quarterOfButtonOne = [self buttonTotalWidth] / 4;
                        if (self.contentViewRightConstraint.constant >= halfOfButtonOne) { //3
                            //Open all the way
                            self.myPaddingView.backgroundColor = [UIColor clearColor];
                            

                            self.myPaddingTextLabel.text = _leftPaddingText1;
                            
                            UIGraphicsBeginImageContext(self.contentView.frame.size);
                            [[UIImage imageNamed:@"heart1.png"] drawInRect:self.contentView.bounds];
                            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            self.myPaddingView.backgroundColor = [UIColor grayColor];
                            //[self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES functionIndex:0];
                        } else if (self.contentViewRightConstraint.constant >= quarterOfButtonOne) { //3
                            //Open all the way
                            self.myPaddingView.backgroundColor = [UIColor blueColor];
                            self.myPaddingTextLabel.text = _leftPaddingText2;
                            
                            //[self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES functionIndex:1];
                        } else {
                            self.myPaddingView.backgroundColor = [UIColor grayColor];
                            self.myPaddingTextLabel.text = @"";
                        }
                        self.contentViewRightConstraint.constant = constant; //10
                        self.contentViewLeftConstraint.constant = 0;
                        self.paddingViewLeftConstraint.constant = self.contentView.frame.size.width + deltaX;
                    }
                }
            }else {
                //The cell was at least partially open.
                CGFloat adjustment = self.startingtLayoutConstraintConstant - deltaX; //11
                if (!panningLeft) {
                    CGFloat constant = MAX(adjustment, 0); //12
                    if (constant == 0) { //13
                        [self resetConstraintContstantsToZero:YES inDirection:PanDirectionLeft notifyDelegateDidClose:NO]; //14
                    } else {
                        CGFloat halfOfButtonOne = [self buttonTotalWidth] / 2; //2
                        CGFloat quarterOfButtonOne = [self buttonTotalWidth] / 4;
                        if (self.contentViewRightConstraint.constant >= halfOfButtonOne) { //3
                            //Open all the way
                            self.myPaddingView.backgroundColor = [UIColor clearColor];
                            
                            
                            self.myPaddingTextLabel.text = _leftPaddingText1;
                            
                            UIGraphicsBeginImageContext(self.contentView.frame.size);
                            [[UIImage imageNamed:@"heart1.png"] drawInRect:self.contentView.bounds];
                            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            self.myPaddingView.backgroundColor = [UIColor grayColor];
                            //[self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES functionIndex:0];
                        } else if (self.contentViewRightConstraint.constant >= quarterOfButtonOne) { //3
                            //Open all the way
                            self.myPaddingView.backgroundColor = [UIColor blueColor];
                            self.myPaddingTextLabel.text = _leftPaddingText2;
                            
                            //[self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES functionIndex:1];
                        } else {
                            self.myPaddingView.backgroundColor = [UIColor grayColor];
                            self.myPaddingTextLabel.text = @"";
                        }

                        self.contentViewRightConstraint.constant = constant; //10
                        self.contentViewLeftConstraint.constant = 0;
                        self.paddingViewLeftConstraint.constant = self.contentView.frame.size.width + deltaX;
                    }
                } else {
                    CGFloat constant = MIN(adjustment, [self buttonTotalWidth]); //16
                    if (constant == [self buttonTotalWidth]) { //17
                        [self setConstraintsToShowAllButtons:YES inDirection:PanDirectionLeft notifyDelegateDidOpen:NO functionIndex:5]; //18
                    } else {
                        CGFloat halfOfButtonOne = [self buttonTotalWidth] / 2; //2
                        CGFloat quarterOfButtonOne = [self buttonTotalWidth] / 4;
                        if (self.contentViewRightConstraint.constant >= halfOfButtonOne) { //3
                            //Open all the way
                            self.myPaddingView.backgroundColor = [UIColor clearColor];
                            
                            
                            self.myPaddingTextLabel.text = _leftPaddingText1;
                            
                            UIGraphicsBeginImageContext(self.contentView.frame.size);
                            [[UIImage imageNamed:@"heart1.png"] drawInRect:self.contentView.bounds];
                            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            self.myPaddingView.backgroundColor = [UIColor grayColor];
                            //[self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES functionIndex:0];
                        } else if (self.contentViewRightConstraint.constant >= quarterOfButtonOne) { //3
                            //Open all the way
                            self.myPaddingView.backgroundColor = [UIColor blueColor];
                            self.myPaddingTextLabel.text = _leftPaddingText2;
                            
                            //[self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES functionIndex:1];
                        } else {
                            self.myPaddingView.backgroundColor = [UIColor grayColor];
                            self.myPaddingTextLabel.text = @"";
                        }

                        self.contentViewRightConstraint.constant = constant; //10
                        self.contentViewLeftConstraint.constant = 0;
                        self.paddingViewLeftConstraint.constant = self.contentView.frame.size.width + deltaX;
                    }
                }
            }
            
            self.contentViewLeftConstraint.constant = -self.contentViewRightConstraint.constant; //20
            //self.contentViewWeightConstraint.constant = self.contentView.frame.size.width - self.contentViewRightConstraint.constant;
            
            self.paddingViewRightConstraint.constant = 0;
        }
            break;
            
        case UIGestureRecognizerStateEnded:
            if (self.startingtLayoutConstraintConstant == 0) { //1
                //We were opening
                CGFloat halfOfButtonOne = [self buttonTotalWidth] / 2; //2
                CGFloat quarterOfButtonOne = [self buttonTotalWidth] / 4;
                if (self.contentViewRightConstraint.constant >= halfOfButtonOne) { //3
                    //Open all the way
                    //self.myPaddingView.backgroundColor = [UIColor redColor];
                    [self setConstraintsToShowAllButtons:YES inDirection:PanDirectionLeft notifyDelegateDidOpen:YES functionIndex:2];
                } else if (self.contentViewRightConstraint.constant >= quarterOfButtonOne) { //3
                    //Open all the way
                    //self.myPaddingView.backgroundColor = [UIColor blueColor];
                    [self setConstraintsToShowAllButtons:YES inDirection:PanDirectionLeft notifyDelegateDidOpen:YES functionIndex:3];
                }else {
                    //Re-close
                    [self resetConstraintContstantsToZero:YES inDirection:PanDirectionLeft  notifyDelegateDidClose:NO];
                }
                
            } else {
                //We were closing
                CGFloat buttonOnePlusHalfOfButton2 = 40; //4
                if (self.contentViewRightConstraint.constant >= buttonOnePlusHalfOfButton2) { //5
                    //Re-open all the way
                    [self setConstraintsToShowAllButtons:YES inDirection:PanDirectionLeft notifyDelegateDidOpen:YES functionIndex:5];
                } else {
                    //Close
                    [self resetConstraintContstantsToZero:YES inDirection:PanDirectionLeft notifyDelegateDidClose:NO];
                }
            }
            break;
            
        case UIGestureRecognizerStateCancelled:
            if (self.startingtLayoutConstraintConstant == 0) {
                //We were closed - reset everything to 0
                [self resetConstraintContstantsToZero:YES inDirection:PanDirectionLeft notifyDelegateDidClose:NO];
            } else {
                //We were open - reset to the open state
                [self setConstraintsToShowAllButtons:YES inDirection:PanDirectionLeft notifyDelegateDidOpen:YES functionIndex:5];
            }
            break;
            
        default:
            break;
    }
}

- (void)panThisCellRight:(UIPanGestureRecognizer*)recognizer {
//    if (!self.allowSwipe) {
//        return;
//    }
    CGPoint velocity = [recognizer velocityInView:self.myContentView];
    if (fabs(velocity.y) > fabs(velocity.x) + 10) {
        return;
    }
    _currentDirection = PanDirectionRight;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.panStartPoint = [recognizer translationInView:self.myContentView];
            self.startingtLayoutConstraintConstant = self.contentViewLeftConstraint.constant;
            self.paddingViewLeftConstraint.constant = self.startingtLayoutConstraintConstant;
            self.paddingViewRightConstraint.constant = self.startingtLayoutConstraintConstant;
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [recognizer translationInView:self.myContentView];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            BOOL panningRight = NO;
            if (currentPoint.x > self.panStartPoint.x) {  //1
                panningRight = YES;
            }
            
            if (self.startingtLayoutConstraintConstant == 0) { //2
                //The cell was closed and is now opening
                if (!panningRight) {
                    CGFloat constant = MAX(deltaX, 0); //3
                    if (constant == 0) { //4
//                        [self resetConstraintContstantsToZero:YES inDirection:PanDirectionRight notifyDelegateDidClose:NO]; //5
//                        self.contentViewRightConstraint.constant = 0;
//                        self.contentViewLeftConstraint.constant = 0;
//                        self.paddingViewRightConstraint = 0;
//                        //self.paddingViewLeftConstraint = 0;
                        
                        self.startingtLayoutConstraintConstant = self.contentViewLeftConstraint.constant;
                        
                    } else {
                        CGFloat halfOfButtonOne = [self buttonTotalWidth] / 2; //2
                        CGFloat quarterOfButtonOne = [self buttonTotalWidth] / 4;
                        if (self.contentViewLeftConstraint.constant >= halfOfButtonOne) { //3
                            //Open all the way
                        self.myPaddingView.backgroundColor = [UIColor clearColor];
                        self.myPaddingTextLabel.text = _rightPaddingText1;
                        UIGraphicsBeginImageContext(self.contentView.frame.size);
                        [[UIImage imageNamed:@"heart1.png"] drawInRect:self.contentView.bounds];
                        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        self.myPaddingView.backgroundColor = [UIColor grayColor];
                                                        //[self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES functionIndex:0];
                        } else if (self.contentViewLeftConstraint.constant >= quarterOfButtonOne) { //3
                            //Open all the way
                            //self.myImageView = nil;
                            self.myPaddingView.backgroundColor = [UIColor redColor];
                            self.myPaddingTextLabel.text = _rightPaddingText2;
                            //[self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES functionIndex:1];
                        } else {
                            self.myPaddingView.backgroundColor = [UIColor grayColor];
                            self.myPaddingTextLabel.text = @"";
                        }

                        self.contentViewLeftConstraint.constant = constant; //6
                        self.contentViewRightConstraint.constant = 0;
                        self.paddingViewRightConstraint.constant = self.contentView.frame.size.width - constant;
                    }
                } else {
                    CGFloat constant = MIN(deltaX, [self buttonTotalWidth]); //7
                    if (constant == [self buttonTotalWidth]) { //8
                        [self setConstraintsToShowAllButtons:YES inDirection:panningRight notifyDelegateDidOpen:NO functionIndex:5]; //9
                    } else {
                        CGFloat halfOfButtonOne = [self buttonTotalWidth] / 2; //2
                        CGFloat quarterOfButtonOne = [self buttonTotalWidth] / 4;
                        if (self.contentViewLeftConstraint.constant >= halfOfButtonOne) { //3
                            //Open all the way
                            //if (_myImageView == nil) {
                                self.myPaddingView.backgroundColor = [UIColor clearColor];
                                self.myPaddingTextLabel.text = _rightPaddingText1;
                            UIGraphicsBeginImageContext(self.contentView.frame.size);
                            [[UIImage imageNamed:@"heart1.png"] drawInRect:self.contentView.bounds];
                            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            self.myPaddingView.backgroundColor = [UIColor grayColor];
                                                            //}
                            
                            //[self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES functionIndex:0];
                        } else if (self.contentViewLeftConstraint.constant >= quarterOfButtonOne) { //3
                            //Open all the way
                            self.myPaddingView.backgroundColor = [UIColor redColor];
                            self.myPaddingTextLabel.text = _rightPaddingText2;
                            //[self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES functionIndex:1];
                        } else {
                            self.myPaddingView.backgroundColor = [UIColor grayColor];
                            self.myPaddingTextLabel.text = @"";
                        }
                        self.contentViewLeftConstraint.constant = constant; //10
                        self.contentViewRightConstraint.constant = 0;
                        self.paddingViewRightConstraint.constant = self.contentView.frame.size.width - self.contentViewLeftConstraint.constant;
                    }
                }
            }else {
                //The cell was at least partially open.
                CGFloat adjustment = deltaX - self.startingtLayoutConstraintConstant ; //11
                if (!panningRight) {
                    CGFloat constant = MAX(adjustment, 0); //12
                    if (constant == 0) { //13
                        [self resetConstraintContstantsToZero:YES inDirection:panningRight  notifyDelegateDidClose:NO]; //14
                    } else
                    {
                        CGFloat halfOfButtonOne = [self buttonTotalWidth] / 2; //2
                        CGFloat quarterOfButtonOne = [self buttonTotalWidth] / 4;
                        if (self.contentViewLeftConstraint.constant >= halfOfButtonOne) { //3
                            //Open all the way
                            self.myPaddingView.backgroundColor = [UIColor clearColor];
                            self.myPaddingTextLabel.text = _rightPaddingText1;
                            UIGraphicsBeginImageContext(self.contentView.frame.size);
                            [[UIImage imageNamed:@"heart1.png"] drawInRect:self.contentView.bounds];
                            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            self.myPaddingView.backgroundColor = [UIColor grayColor];
                            //[self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES functionIndex:0];
                        } else if (self.contentViewLeftConstraint.constant >= quarterOfButtonOne) { //3
                            //Open all the way
                            //self.myImageView = nil;
                            self.myPaddingView.backgroundColor = [UIColor redColor];
                            self.myPaddingTextLabel.text = _rightPaddingText2;
                            //[self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES functionIndex:1];
                        } else {
                            self.myPaddingView.backgroundColor = [UIColor grayColor];
                            self.myPaddingTextLabel.text = @"";
                        }
                        
                        self.contentViewLeftConstraint.constant = constant; //6
                        self.contentViewRightConstraint.constant = 0;
                        self.paddingViewRightConstraint.constant = self.contentView.frame.size.width - constant;
                    }
                } else {
                    CGFloat constant = MIN(deltaX, [self buttonTotalWidth]); //7
                    if (constant == [self buttonTotalWidth]) { //8
                        [self setConstraintsToShowAllButtons:YES inDirection:panningRight notifyDelegateDidOpen:NO functionIndex:5]; //9
                    } else {
                        CGFloat halfOfButtonOne = [self buttonTotalWidth] / 2; //2
                        CGFloat quarterOfButtonOne = [self buttonTotalWidth] / 4;
                        if (self.contentViewLeftConstraint.constant >= halfOfButtonOne) { //3
                            //Open all the way
                            //if (_myImageView == nil) {
                            self.myPaddingView.backgroundColor = [UIColor clearColor];
                            self.myPaddingTextLabel.text = _rightPaddingText1;
                            UIGraphicsBeginImageContext(self.contentView.frame.size);
                            [[UIImage imageNamed:@"heart1.png"] drawInRect:self.contentView.bounds];
                            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            self.myPaddingView.backgroundColor = [UIColor grayColor];
                            //}
                            
                            //[self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES functionIndex:0];
                        } else if (self.contentViewLeftConstraint.constant >= quarterOfButtonOne) { //3
                            //Open all the way
                            self.myPaddingView.backgroundColor = [UIColor redColor];
                            self.myPaddingTextLabel.text = _rightPaddingText2;
                            //[self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES functionIndex:1];
                        } else {
                            self.myPaddingView.backgroundColor = [UIColor grayColor];
                            self.myPaddingTextLabel.text = @"";
                        }
                        self.contentViewLeftConstraint.constant = constant; //10
                        self.contentViewRightConstraint.constant = 0;
                        self.paddingViewRightConstraint.constant = self.contentView.frame.size.width - self.contentViewLeftConstraint.constant;
                    }
                }
            }
            
            self.contentViewRightConstraint.constant = -self.contentViewLeftConstraint.constant; //20
            //self.contentViewWeightConstraint.constant = self.contentView.frame.size.width - self.contentViewRightConstraint.constant;
            
            self.paddingViewLeftConstraint.constant = 0;
        }
            break;
            
        case UIGestureRecognizerStateEnded:
            if (self.startingtLayoutConstraintConstant == 0) { //1
                //We were opening
                CGFloat halfOfButtonOne = [self buttonTotalWidth] / 2; //2
                CGFloat quarterOfButtonOne = [self buttonTotalWidth] / 4;
                if (self.contentViewLeftConstraint.constant >= halfOfButtonOne) { //3
                    //Open all the way
                    //self.myPaddingView.backgroundColor = [UIColor redColor];
                    [self resetConstraintContstantsToZero:YES inDirection:PanDirectionRight notifyDelegateDidClose:YES];
                } else if (self.contentViewLeftConstraint.constant > quarterOfButtonOne) { //3
                    //Open all the way
                    //self.myPaddingView.backgroundColor = [UIColor blueColor];
                    [self setConstraintsToShowAllButtons:YES inDirection:PanDirectionRight notifyDelegateDidOpen:YES functionIndex:1];
                }else {
                    //Re-close
                    [self resetConstraintContstantsToZero:YES inDirection:PanDirectionRight notifyDelegateDidClose: NO];
                }
                
            } else {
                //We were closing
                CGFloat buttonOnePlusHalfOfButton2 = 40; //4
                if (self.contentViewLeftConstraint.constant >= buttonOnePlusHalfOfButton2) { //5
                    //Re-open all the way
                    [self setConstraintsToShowAllButtons:YES inDirection:PanDirectionRight   notifyDelegateDidOpen:YES functionIndex:5];
                } else {
                    //Close
                    [self resetConstraintContstantsToZero:YES inDirection:PanDirectionRight  notifyDelegateDidClose:NO];
                }
            }
            break;
            
        case UIGestureRecognizerStateCancelled:
            if (self.startingtLayoutConstraintConstant == 0) {
                //We were closed - reset everything to 0
                [self resetConstraintContstantsToZero:YES inDirection:PanDirectionRight notifyDelegateDidClose:NO];
            } else {
                //We were open - reset to the open state
                [self setConstraintsToShowAllButtons:YES inDirection:PanDirectionRight  notifyDelegateDidOpen:YES functionIndex:5];
            }
            break;
            
        default:
            break;
    }
}


- (void)updateConstraintsIfNeeded:(BOOL)animated duration:(float) duration completion:(void (^)(BOOL finished))completion;
{
    duration = animated ? duration : 0;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:completion];
}


- (void)resetConstraintContstantsToZero:(BOOL)animated inDirection:(PanDirection) direction notifyDelegateDidClose:(BOOL)notifyDelegate
{

    if (notifyDelegate) {
        [self.delegate cellDidClose:self];
    }
    
    if (direction == PanDirectionLeft) {
        if (self.startingtLayoutConstraintConstant == 0 &&
            self.contentViewRightConstraint.constant == 0) {
            //Already all the way closed, no bounce necessary
            return;
        }
        
        self.contentViewRightConstraint.constant = -kBounceValue;
        self.contentViewLeftConstraint.constant = kBounceValue;
        self.paddingViewLeftConstraint.constant = 320 - self.contentViewRightConstraint.constant;
        
        [self updateConstraintsIfNeeded:animated duration:0.1 completion:^(BOOL finished) {
            self.contentViewRightConstraint.constant = 0;
            self.contentViewLeftConstraint.constant = 0;
            self.paddingViewRightConstraint.constant = 0;
            self.paddingViewLeftConstraint.constant = 0;
            [self updateConstraintsIfNeeded:animated duration:0.1 completion:^(BOOL finished) {
                self.startingtLayoutConstraintConstant = self.contentViewRightConstraint.constant;
            }];
        }];

    }
    
    if (direction == PanDirectionRight) {
        if (self.startingtLayoutConstraintConstant == 0 &&
            self.contentViewLeftConstraint.constant == 0) {
            //Already all the way closed, no bounce necessary
            return;
        }
        
        self.contentViewLeftConstraint.constant = -kBounceValue;
        self.contentViewRightConstraint.constant = kBounceValue;
        self.paddingViewRightConstraint.constant = self.contentViewLeftConstraint.constant;
        
        [self updateConstraintsIfNeeded:animated duration:0.1 completion:^(BOOL finished) {
            self.contentViewRightConstraint.constant = 0;
            self.contentViewLeftConstraint.constant = 0;
            self.paddingViewRightConstraint.constant = 0;
            self.paddingViewLeftConstraint.constant = 0;
            [self updateConstraintsIfNeeded:animated duration:0.1 completion:^(BOOL finished) {
                self.startingtLayoutConstraintConstant = self.contentViewLeftConstraint.constant;
            }];
        }];
    }
    
}


- (void)setConstraintsToShowAllButtons:(BOOL)animated inDirection:(PanDirection)direction notifyDelegateDidOpen:(BOOL)notifyDelegate functionIndex:(NSUInteger) index
{
    if (notifyDelegate) {
        [self.delegate cellDidOpen:self withIndex:index];
    }
    
    if (direction == PanDirectionLeft) {
        //1
        if (self.startingtLayoutConstraintConstant == [self buttonTotalWidth] &&
            self.contentViewRightConstraint.constant == [self buttonTotalWidth]) {
            return;
        }
        //2
        //    self.contentViewLeftConstraint.constant = -[self buttonTotalWidth] - kBounceValue;
        //    self.contentViewRightConstraint.constant = [self buttonTotalWidth] + kBounceValue;
        //    self.paddingViewLeftConstraint.constant = self.contentView.frame.size.width - self.contentViewRightConstraint.constant;
        
        //[self updateConstraintsIfNeeded:animated duration:0.3 completion:^(BOOL finished) {
        //3
        self.contentViewLeftConstraint.constant = -[self buttonTotalWidth];
        self.contentViewRightConstraint.constant = [self buttonTotalWidth];
        self.paddingViewLeftConstraint.constant = self.contentView.frame.size.width - self.contentViewRightConstraint.constant;
        
        [self updateConstraintsIfNeeded:animated duration:0.3 completion:^(BOOL finished) {
            //4
            self.startingtLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
        //}];
    }else if (direction == PanDirectionRight) {
        //1
        if (self.startingtLayoutConstraintConstant == [self buttonTotalWidth] &&
            self.contentViewLeftConstraint.constant == [self buttonTotalWidth]) {
            return;
        }
        //2
        //    self.contentViewLeftConstraint.constant = -[self buttonTotalWidth] - kBounceValue;
        //    self.contentViewRightConstraint.constant = [self buttonTotalWidth] + kBounceValue;
        //    self.paddingViewLeftConstraint.constant = self.contentView.frame.size.width - self.contentViewRightConstraint.constant;
        
        //[self updateConstraintsIfNeeded:animated duration:0.3 completion:^(BOOL finished) {
        //3
        self.contentViewRightConstraint.constant = -[self buttonTotalWidth];
        self.contentViewLeftConstraint.constant = [self buttonTotalWidth];
        self.paddingViewRightConstraint.constant = 0;
        
        [self updateConstraintsIfNeeded:animated duration:0.3 completion:^(BOOL finished) {
            //4
            self.startingtLayoutConstraintConstant = self.contentViewLeftConstraint.constant;
        }];
        //}];
    }
    
   
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//#pragma mark - PanGestureEndAnimation
//
//- (void) panGestureEndedAnimation :(SwipePosition)position {
//    if (position == SwipePositionLeftGoback) {
//        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
//    }
//    
//    if (position = SwipePositionLeftFountion1) {
//        _delegate cellDidOpen:<#(UITableViewCell *)#> withIndex:<#(NSUInteger)#>
//    }
//    
//
//}

@end
