//
//  CardPageViewController.h
//  eGHL Example
//
//  Created by Arif Jusoh on 14/09/2018.
//  Copyright © 2018 GHL ePayments Sdn Bhd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardPageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *eghlView;
@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;
@property (weak, nonatomic) IBOutlet UISwitch *customerConsent;
@end
