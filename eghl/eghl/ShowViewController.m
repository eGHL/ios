//
//  ShowViewController.m
//  eghl
//
//  Created by mac on 15/1/27.
//  Copyright (c) 2015年 eghl. All rights reserved.
//

#import "ShowViewController.h"
typedef enum {
    tagAVResult = 900,
    tagAVExitPayment
}tagForAlerView;

@interface ShowViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) EGHLPayment *eghlpay;
@end

@implementation ShowViewController
@synthesize paypram;

-(id)initWithValue:(PaymentRequestPARAM *)payment
{
    self = [super init];
    
    if (self) {
        paypram = payment;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    UIButton * button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setImage:[UIImage imageNamed:@"navigationItemBack"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.04 green:0.38 blue:1 alpha:1.0] forState:UIControlStateNormal];

    [button addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setClipsToBounds:YES];
    
    [button setTitle:@"Back" forState:UIControlStateNormal];
    [button sizeToFit];

    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;

    /* ------------------
     * [OPTIONAL]
     * setup first Loading message
     * ------------------ */
    UILabel * messageLabel = [[UILabel alloc] init];
    messageLabel.text = @"Redirecting to Payment Gateway...";
    messageLabel.textColor = [UIColor whiteColor];
//        self.loadingMessageLabel.backgroundColor = [UIColor blackColor];
    [messageLabel sizeToFit];
    
    CGRect frame = messageLabel.frame;
    frame.size.height = 200;
    messageLabel.frame = frame;

    self.eghlpay.loadingMessageLabel = messageLabel;
    // ------------------
    
    [self.view addSubview:self.eghlpay];
    
    [self.eghlpay EGHLRequestSale:paypram successBlock:^(NSString* SuccessData) {
        NSLog(@"respdata:%@",SuccessData);
    } failedBlock:^(NSString *errorCode, NSString *errorData) {
        NSLog(@"errordata:%@",errorData);
    }];
}

- (EGHLPayment *)eghlpay {
    if (!_eghlpay) {
        _eghlpay = [[EGHLPayment alloc] init];
        _eghlpay.delegate = self;
    }
    return _eghlpay;
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    self.eghlpay.frame = self.view.frame;
}


- (void)QueryResult:(PaymentRespPARAM *)result
{
    /*************************************
     Query current transaction status.
     TxnStatus:
     0 = transaction success
     1 = transaction failed
     2 = sale pending, retry query
     TxnExists:
     0 – Transaction being queried exists in Payment Gateway.
     1 – Transaction being queried does not exist in Payment Gateway.
     TxnStatus will be -1
     2 – There was some kind of internal error occurred during query processing. Merchant System can retry sending query request
     TxnStatus will be -2
     **************************************/
    NSString * resultString = [NSString stringWithFormat:@"TxnExists:%@\nQueryDesc:%@\nTransactionType:%@\nPymtMethod:%@\nServiceID:%@\nPaymentID:%@\nOrderNumber:%@\nAmount:%@\nCurrencyCode:%@\nTxnID:%@\nIssuingBank:%@\nAuthCode:%@\nTxnStatus:%@\nBankRefNo:%@\nTxnMessage:%@\nHashValue:%@\nSessionID:%@", result.TxnExists,result.QueryDesc,result.TransactionType,result.PymtMethod,result.ServiceID,result.PaymentID,result.OrderNumber,result.Amount,result.CurrencyCode,result.TxnID,result.IssuingBank,result.AuthCode, result.TxnStatus,result.BankRefNo,result.TxnMessage,result.HashValue,result.SessionID];
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Payment Status" message:resultString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    av.tag = tagAVResult;
    [av show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)backButtonPressed:(id)sender{
    UIAlertView * alertExit = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to quit" message:@"Pressing BACK button will close and abandon the payment session." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Exit", nil];
    
    [alertExit setTag:tagAVExitPayment];
    [alertExit show];
}

#pragma mark - UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([alertView tag]) {
        case tagAVExitPayment:
        {
            if (buttonIndex == 1) {
//                [self.navigationController popViewControllerAnimated:YES];
                [self.eghlpay finalizeTransaction];
            }
        }
            break;
            
        case tagAVResult:
            [self.navigationController popViewControllerAnimated:NO];
            break;
        default:
            break;
    }
}

@end
