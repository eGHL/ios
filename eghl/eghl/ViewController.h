//
//  ViewController.h
//  eghl
//
//  Created by mac on 15/1/21.
//  Copyright (c) 2015年 eghl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGHLPayment.h"
#import "ShowViewController.h"

@interface ViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) PaymentRequestPARAM *paypram;
@property (strong, nonatomic) EGHLPayment *eghlpay;

@end





