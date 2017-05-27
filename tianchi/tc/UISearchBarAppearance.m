//
//  UISearchBarAppearance.m
//  tc
//
//  Created by Sasori on 16/8/15.
//  Copyright © 2016年 Sasori. All rights reserved.
//

#import "UISearchBarAppearance.h"
#import <UIKit/UIKit.h>

@implementation UISearchBarAppearance

+ (void)setupSearchBar {
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

@end
