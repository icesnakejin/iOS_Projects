//
//  NavigationCollectionViewCell.m
//  GooglePlayer
//
//  Created by Yankun Jin on 4/16/15.
//  Copyright (c) 2015 YankunJin. All rights reserved.
//

#import "NavigationCollectionViewCell.h"

@interface NavigationCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UILabel* title;

@end

@implementation NavigationCollectionViewCell

- (void) setItem:(NSString *)title {
    _title.text = title;
}

@end
