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
    [df setDateFormat:@"yyyyMMddHHmm"];
    NSString * dateString = [df stringFromDate:[NSDate date]];
    
    int value =arc4random_uniform(9999 + 1);
    
    _paymentID = [NSString stringWithFormat:@"DEMO%@%d", dateString, value];
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
        self.paypram.Password = @"";
        self.paypram.ServiceID = @"";
        
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
- (IBAction)SaleReqBtn:(UIButton *)btnSale {
    [self.view endEditing:YES];
    
    self.paypram.TransactionType = @"SALE";

    self.paypram.CustEmail = @"somebody@somesite.com";
    self.paypram.CustName = @"Somebody";
    
    self.paypram.MerchantReturnURL = @"SDK"; // Just put any dummy string, cannot be empty
//    self.paypram.MerchantCallBackURL = @"https://abc.com/callback";
    
    self.paypram.CustPhone = @"0123456789";
    self.paypram.LanguageCode = @"EN";
    self.paypram.PaymentDesc = @"just buy something";
    self.paypram.PageTimeout = @"600";
    
    [self generateNewPaymentID];
    self.paypram.PaymentID = self.paymentID;
    self.paypram.OrderNumber = self.paymentID;

    NSLog(@"\n%@", [ShowViewController displayRequestParam:self.paypram]);
    ShowViewController *Payviewcontroller = [[ShowViewController alloc] initWithValue:self.paypram];
    Payviewcontroller.eghlpay = self.eghlpay;
    
    [self.navigationController pushViewController:Payviewcontroller animated:YES];
}
- (IBAction)QueryReqBtn:(UIButton *)btnSale {
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

    self.paypram.TransactionType = @"query";
    self.paypram.PaymentID = self.paymentID;
    self.paypram.OrderNumber = self.paymentID;
    
    [self.eghlpay paymentAPI:self.paypram successBlock:^(PaymentRespPARAM* paramData) {
        NSLog(@"\n%@", [ShowViewController displayResponseParam:paramData]);
    } failedBlock:^(NSString *errorCode, NSString *errorData, NSError * error) {
        NSLog(@"respdata:%@",errorData);
    }];
}

- (IBAction)preAuthReqBtn:(UIButton *)btnSale {
    [self.view endEditing:YES];
    
    self.paypram.TransactionType = @"AUTH";
    
    self.paypram.CustEmail = @"somebody@somesite.com";
    self.paypram.CustName = @"Somebody";
    
    self.paypram.MerchantReturnURL = @"SDK"; // Just put any dummy string, cannot be empty
    //    self.paypram.MerchantCallBackURL = @"https://abc.com/callback";
    
    self.paypram.CustPhone = @"0123456789";
    self.paypram.LanguageCode = @"EN";
    self.paypram.PaymentDesc = @"just buy something";
    self.paypram.PageTimeout = @"600";
    
    [self generateNewPaymentID];
    self.paypram.PaymentID = self.paymentID;
    self.paypram.OrderNumber = self.paymentID;
    
    NSLog(@"\n%@", [ShowViewController displayRequestParam:self.paypram]);
    ShowViewController *Payviewcontroller = [[ShowViewController alloc] initWithValue:self.paypram];
    Payviewcontroller.eghlpay = self.eghlpay;
    [self.navigationController pushViewController:Payviewcontroller animated:YES];
}

- (IBAction)captureReqBtn:(UIButton *)btnSale {
    [self.view endEditing:YES];
    
    self.paypram.TransactionType = @"CAPTURE";
    self.paypram.PaymentID = self.paymentID;
    
    [self.eghlpay paymentAPI:self.paypram successBlock:^(PaymentRespPARAM *paramData) {
        NSLog(@"\n%@", [ShowViewController displayResponseParam:paramData]);
    } failedBlock:^(NSString *errorCode, NSString *errorData, NSError * error) {
        NSLog(@"errordata:%@",errorData);
    }];
}

#pragma mark - Master Pass
- (IBAction)masterPassButtonPressed:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.paypram.TokenType = @"MPE";
    self.paypram.Token = @"somebodyLoginID"; // Comsumer's login ID to merchant System
    
    self.paypram.PaymentDesc = @"Testing MasterPass 会心";
    self.paypram.Amount = @"10.00";
    
    self.paypram.CurrencyCode = @"MYR";
    
    [self.eghlpay eGHLMPERequest:self.paypram successBlock:^(PaymentRespPARAM* paramData) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self generateNewPaymentID];
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
            /**
             Normal Request Payment Parameter + Tokens
             */
            self.paypram.TransactionType = @"SALE";
            
            self.paypram.CustEmail = @"somebody@somesite.com";
            self.paypram.CustName = @"Somebody";
            
            self.paypram.MerchantReturnURL = @"SDK"; // Just put any dummy string, cannot be empty
            //    self.paypram.MerchantCallBackURL = @"https://abc.com/callback";
            
            self.paypram.CustPhone = @"0123456789";
            self.paypram.LanguageCode = @"EN";
            self.paypram.PaymentDesc = @"just buy something";
            self.paypram.PageTimeout = @"600";
            
            [self generateNewPaymentID];
            self.paypram.PaymentID = self.paymentID;
            self.paypram.OrderNumber = self.paymentID;
            
            self.paypram.PairingToken = paramData.PairingToken;
            self.paypram.ReqToken = paramData.ReqToken;
            
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
            
            ShowViewController *Payviewcontroller = [[ShowViewController alloc] initWithValue:self.paypram];
            Payviewcontroller.eghlpay = self.eghlpay;
            [self.navigationController pushViewController:Payviewcontroller animated:YES];
        }
    } failedBlock:^(NSString *errorCode, NSString *errorData, NSError * error) {
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
                        
                        self.paypram.TransactionType=@"SALE";
                        self.paypram.MerchantReturnURL = @"abc";
                        
                        ShowViewController *Payviewcontroller = [[ShowViewController alloc] initWithValue:self.paypram];
                        Payviewcontroller.eghlpay = self.eghlpay;
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
