//
//  AppDelegate.h
//  eghl
//
//  Created by mac on 15/1/21.
//  Copyright (c) 2015年 eghl. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;;

@property (nonatomic, strong) UINavigationController *navPayment;

@end
