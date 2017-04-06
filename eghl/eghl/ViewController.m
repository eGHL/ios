//
//  ViewController.m
//  eghl
//
//  Created by mac on 15/1/21.
//  Copyright (c) 2015年 eghl. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"

typedef enum {
    tagSegmentedPaymentMethod = 900,
    tagSegmentedBank,
    tagSegmentedToken,
    tagACCards
}tagForUI;

@interface ViewController () <UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UITextField *Amount;
@property (strong, nonatomic) IBOutlet UITextField *Merchant;
@property (strong, nonatomic) IBOutlet UITextField *Email;
@property (strong, nonatomic) IBOutlet UITextField *Customer;
@property (strong, nonatomic) IBOutlet UITextField *ServiceID;
@property (strong, nonatomic) IBOutlet UITextField *Password;
@property (strong, nonatomic) IBOutlet UITextField *Currency;

@property (strong, nonatomic) IBOutlet UISegmentedControl *TokenSegCon;
@property (strong, nonatomic) IBOutlet UISegmentedControl *PayMethod;
@property (strong, nonatomic) IBOutlet UISegmentedControl *Bank;
@property (strong, nonatomic) IBOutlet UISwitch *HostSwitch;

@property (weak, nonatomic) IBOutlet UIButton *SaleReq;
@property (weak, nonatomic) IBOutlet UIButton *QueryReq;
@property (weak, nonatomic) IBOutlet UIButton *Reversal;

@property (nonatomic, strong) NSString * paymentID;

@property (nonatomic,strong) NSArray * listOfCard;
@property (nonatomic,strong) NSString * preCheckoutID;
@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.paypram = [[PaymentRequestPARAM alloc]init];
    self.eghlpay = [[EGHLPayment alloc]init];

    [self setupData];
    [self setupUI];

}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)paymentID {
    if (!_paymentID) {
        [self generateNewPaymentID];
    }
    
    return _paymentID;
}

- (void)generateNewPaymentID {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMdd"];
    NSString * dateString = [df stringFromDate:[NSDate date]];
    
    int value =arc4random_uniform(9999999 + 1);
    
    _paymentID = [NSString stringWithFormat:@"AJ%@%@%d", self.paypram.ServiceID, dateString,value];
}

#pragma mark - Setup
- (void)setupUI {
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
    self.TokenSegCon.selectedSegmentIndex = 1;
    self.TokenSegCon.tag = tagSegmentedToken;
    [self.TokenSegCon addTarget:self action:@selector(didClicksegmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    
    self.PayMethod.selectedSegmentIndex = 0;
    self.PayMethod.tag = tagSegmentedPaymentMethod;
    [self.PayMethod addTarget:self action:@selector(didClicksegmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    
    self.Bank.selectedSegmentIndex = 0;
    self.Bank.tag = tagSegmentedBank;
    [self.Bank addTarget:self action:@selector(didClicksegmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    
    [self.HostSwitch setOn:NO];
    [self.HostSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    [self.SaleReq addTarget:self action:@selector(SaleReqBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.QueryReq addTarget:self action:@selector(QueryReqBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.Reversal addTarget:self action:@selector(ReversalReqBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupTextFieldValue];
}

- (void) setupTextFieldValue {
    self.Amount.text    = self.paypram.Amount;
    self.Merchant.text  = self.paypram.MerchantName;
    self.Email.text     = self.paypram.CustEmail;
    self.Customer.text  = self.paypram.CustName;
    self.ServiceID.text = self.paypram.ServiceID;
    self.Password.text  = self.paypram.Password;
    self.Currency.text  = self.paypram.CurrencyCode;
}

#pragma mark data
- (void)setupData {
    self.paypram.Amount = @"1.00";
    self.paypram.CustEmail = @"somebody@somesite.com";
    self.paypram.CustName = @"Somebody";
    self.paypram.CurrencyCode = @"MYR";
    
    [self setupServiceForRealHost:NO];
    
    //    paypram.CardExp = @"1020";
    //    paypram.CardHolder = @"YAM TEE YEN";
    //    paypram.CardNo = @"5401190420329107";
    
    self.paypram.MerchantReturnURL = @"https://test2pay.ghl.com/IPGSimulatorJeff/RespFrmGW.aspx";
    self.paypram.MerchantCallBackURL = @"https://test2pay.ghl.com/IPGSimulatorJeff/RespFrmGW.aspx";
    
    self.paypram.CustPhone = @"0123456789";
    self.paypram.LanguageCode = @"EN";
    self.paypram.PaymentDesc = @"Buy something 会心";
    self.paypram.PageTimeout = @"600";

    self.paypram.PymtMethod = @"ANY";
    
    /* SDK Timer
     * seconds
     self.paypram.sdkTimeOut = 60*1; // 1 minutes
     */
}

#pragma mark - UISwitch
- (void)switchAction:(id)sender{
    [self setupServiceForRealHost:[(UISwitch*)sender isOn]];
}

- (void)setupServiceForRealHost:(BOOL)realHost {
    self.paypram.realHost = realHost;

    if (realHost) {
        self.paypram.MerchantName = @"eGHL Payment";
        self.paypram.Password = @"Gh1eG3H1";
        self.paypram.ServiceID = @"GHL";
        
        [self setupTextFieldValue];
    } else {
        self.paypram.MerchantName = @"eGHL Payment Testing";
        self.paypram.Password = @"ghl12345";
        self.paypram.ServiceID = @"GHL";

        
        [self setupTextFieldValue];
    }
}

#pragma mark - UISegmentedControl Delegate
- (void)didClicksegmentedControlAction:(UISegmentedControl *)seg {
    switch ((tagForUI)seg.tag) {
        case tagSegmentedBank:
            self.paypram.IssuingBank = [seg titleForSegmentAtIndex:seg.selectedSegmentIndex];
            break;
            
        case tagSegmentedPaymentMethod:
            self.paypram.PymtMethod = [seg titleForSegmentAtIndex:seg.selectedSegmentIndex];
            break;
            
        case tagSegmentedToken:{
            switch (seg.selectedSegmentIndex) {
                case 0:{
                    self.paypram.TokenType = @"OCP";
                    self.paypram.Token = @"duo9LGT7JC8b uGkGhvdHg==";
                }
                    break;
                    
                case 1:
                default:{
                    self.paypram.TokenType = @"";
                    self.paypram.Token = @"";
                }
                    
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Action
- (void)SaleReqBtn:(UIButton *)btnSale {
    [self.view endEditing:YES];
    
    [self generateNewPaymentID];
    self.paypram.PaymentID = self.paymentID;
    self.paypram.OrderNumber = self.paymentID;

    NSLog(@"Amount:%@ Merchant:%@ Email:%@ Customer:%@ ServiceID:%@ Password:%@ Currency:%@ TokenType:%@ Token:%@ PayMethod:%@ Bank:%@ PaymentID:%@ OrderNumber:%@",
          self.paypram.Amount,self.paypram.MerchantName,self.paypram.CustEmail,self.paypram.CustName,self.paypram.ServiceID,self.paypram.Password,self.paypram.CurrencyCode,self.paypram.TokenType,self.paypram.Token,self.paypram.PymtMethod,self.paypram.IssuingBank,self.paypram.PaymentID,self.paypram.OrderNumber);
    ShowViewController *Payviewcontroller = [[ShowViewController alloc] initWithValue:self.paypram];
    [self.navigationController pushViewController:Payviewcontroller animated:YES];
}
- (void)QueryReqBtn:(UIButton *)btnSale {
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
    [self.view endEditing:YES];

    self.paypram.PaymentID = self.paymentID;
    self.paypram.OrderNumber = self.paymentID;
    
    [self.eghlpay EGHLRequestQuery:self.paypram successBlock:^(PaymentRespPARAM* ParamData) {
        NSLog(@"TxnExists:%@,QueryDesc:%@,TransactionType:%@,PymtMethod:%@,ServiceID:%@,PaymentID:%@,OrderNumber:%@,Amount:%@ \
              CurrencyCode:%@,TxnID:%@,IssuingBank:%@,AuthCode:%@,TxnStatus:%@,BankRefNo:%@,TxnMessage:%@,HashValue:%@,SessionID:%@",\
              ParamData.TxnExists,ParamData.QueryDesc,ParamData.TransactionType,ParamData.PymtMethod,ParamData.ServiceID,ParamData.PaymentID,ParamData.OrderNumber,ParamData.Amount,ParamData.CurrencyCode,ParamData.TxnID,ParamData.IssuingBank,ParamData.AuthCode,\
              ParamData.TxnStatus,ParamData.BankRefNo,ParamData.TxnMessage,ParamData.HashValue,ParamData.SessionID);
    } failedBlock:^(NSString *errorCode, NSString *errorData) {
        NSLog(@"respdata:%@",errorData);
    }];
}

- (void)ReversalReqBtn:(UIButton *)btnSale {
    [self.view endEditing:YES];

    self.paypram.PaymentID = self.paymentID;
    self.paypram.OrderNumber = self.paymentID;
    
    [self.eghlpay EGHLRequestReversal:self.paypram successBlock:^(PaymentRespPARAM* ParamData) {
        NSLog(@"TxnExists:%@,QueryDesc:%@,TransactionType:%@,PymtMethod:%@,ServiceID:%@,PaymentID:%@,OrderNumber:%@,Amount:%@ \
              CurrencyCode:%@,TxnID:%@,IssuingBank:%@,AuthCode:%@,TxnStatus:%@,BankRefNo:%@,TxnMessage:%@,HashValue:%@,SessionID:%@",\
              ParamData.TxnExists,ParamData.QueryDesc,ParamData.TransactionType,ParamData.PymtMethod,ParamData.ServiceID,ParamData.PaymentID,ParamData.OrderNumber,ParamData.Amount,ParamData.CurrencyCode,ParamData.TxnID,ParamData.IssuingBank,ParamData.AuthCode,\
              ParamData.TxnStatus,ParamData.BankRefNo,ParamData.TxnMessage,ParamData.HashValue,ParamData.SessionID);
    } failedBlock:^(NSString *errorCode, NSString *errorData) {
        NSLog(@"respdata:%@",errorData);
    }];
}

#pragma mark - Master Pass
- (IBAction)masterPassButtonPressed:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.paypram.ServiceID = @"om2";
    self.paypram.Password = @"om212345";
    
    self.paypram.TokenType = @"MPE";
    
    self.paypram.Token = @"somebodyLoginID"; // Comsumer's login ID to merchant System
    self.paypram.PaymentDesc = @"Testing MasterPass 会心";
    self.paypram.Amount = @"10.00";
    
    self.paypram.CurrencyCode = @"MYR";
    
    /**
     Lightbox Paramter reference
     https://developer.mastercard.com/page/masterpass-lightbox-parameters
     */
    self.paypram.mpLightboxParameter = @{
                                         @"merchantCheckoutId":@"", //id from masterpass
                                         @"failureCallback":@"", // http://...
                                         @"callbackUrl":@"", // http://...
                                         @"cancelCallback":@"", // http://...

                                         };
    //---------------
    
    [self.eghlpay eGHLMPERequest:self.paypram successBlock:^(PaymentRespPARAM* paramData) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
	    self.paypram.PaymentID = self.paymentID;
    	self.paypram.OrderNumber = self.paymentID;

        if (paramData.PreCheckoutId && paramData.Cards.count > 0) {
            self.listOfCard = paramData.Cards;
            self.preCheckoutID = paramData.PreCheckoutId;
            UIActionSheet * ac = [[UIActionSheet alloc] init];
            ac.title = @"Select Card";
            ac.delegate = self;
            ac.tag = tagACCards;
            
            for (NSDictionary * cardDict in self.listOfCard) {
                [ac addButtonWithTitle:[self displayFormatForLastFour:cardDict[@"LastFour"]]];
            }
            
            [ac addButtonWithTitle:@"CANCEL"];
            [ac setCancelButtonIndex:ac.numberOfButtons - 1];
            
            UIView * custom = [self.view superview];
            [ac showFromRect:self.view.frame inView:custom animated:YES];
        } else {
            self.paypram.PairingToken = paramData.PairingToken;
            self.paypram.ReqToken = paramData.ReqToken;
            
            ShowViewController *Payviewcontroller = [[ShowViewController alloc] initWithValue:self.paypram];
            [self.navigationController pushViewController:Payviewcontroller animated:YES];
        }
    } failedBlock:^(NSString *errorCode, NSString *errorData) {
        NSLog(@"errorCode:%@", errorCode);
        NSLog(@"errorData:%@", errorData);
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
         
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex ) {
        
        switch (actionSheet.tag) {
            case tagACCards:{
                NSString * buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
                
                for (NSDictionary * cardDict in self.listOfCard) {
                    if ([buttonTitle isEqualToString:[self displayFormatForLastFour:cardDict[@"LastFour"]]]) {
                        self.paypram.PreCheckoutId = self.preCheckoutID;
                        self.paypram.CardId = cardDict[@"CardId"];
                        
                        ShowViewController *Payviewcontroller = [[ShowViewController alloc] initWithValue:self.paypram];
                        [self.navigationController pushViewController:Payviewcontroller animated:YES];

                        break;
                    }
                }
                
            }
            break;
            
            default:{
                
            }
            break;
            
        }
    }
}

- (NSString *)displayFormatForLastFour:(NSString *)lastFour {
    return [NSString stringWithFormat:@"**** **** **** %@", lastFour];
}

#pragma mark - UITapGesture
- (void)viewTapped:(UITapGestureRecognizer*)tapGr {
    [self.view endEditing:YES];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.Amount]) {
        self.paypram.Amount = textField.text;
    } else if ([textField isEqual:self.Merchant]){
        self.paypram.MerchantName = textField.text;
    } else if ([textField isEqual:self.Email]){
        self.paypram.CustEmail = textField.text;
    } else if ([textField isEqual:self.Customer]){
        self.paypram.CustName = textField.text;
    } else if ([textField isEqual:self.ServiceID]){
        self.paypram.ServiceID = textField.text;
    } else if ([textField isEqual:self.Password]){
        self.paypram.Password = textField.text;
    } else if ([textField isEqual:self.Currency]){
        self.paypram.CurrencyCode = textField.text;
    }
}

@end
