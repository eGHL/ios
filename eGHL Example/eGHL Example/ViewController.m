//
//  ViewController.m
//  eGHL Example
//
//  Created by Arif Jusoh on 13/06/2018.
//  Copyright © 2018 GHL ePayments Sdn Bhd. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
#import <EGHL/EGHL.h>

typedef enum {
    tagSegmentedPaymentMethod = 900,
    tagSegmentedBank,
    tagSegmentedToken,
}tagForUI;

@interface ViewController () <UIActionSheetDelegate>
@property (strong, nonatomic) PaymentRequestPARAM *paypram;
@property (strong, nonatomic) EGHLPayment *eghlpay;


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

@property (nonatomic) BOOL realHost;
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
    self.realHost = realHost;
    if (realHost) {
        self.paypram.MerchantName = @"eGHL Payment";
        self.paypram.Password = @"";
        self.paypram.ServiceID = @"";
        
        [self setupTextFieldValue];
    } else {
        self.paypram.MerchantName = @"eGHL Payment Testing";
        self.paypram.Password = @"sit12345";
        self.paypram.ServiceID = @"SIT";
        
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
    
    self.paypram.TransactionType = EGHL_TRANSACTION_TYPE_SALE;
    
    self.paypram.CustEmail = @"somebody@somesite.com";
    self.paypram.CustName = @"Somebody";
    
    self.paypram.MerchantReturnURL = @"SDK"; // Just put any dummy string, cannot be empty
    //    self.paypram.MerchantReturnURL = @"http://example.com/returnURL=1";
    //    self.paypram.MerchantCallBackURL = @"http://example.com/callbackURL=1";
    
    
    self.paypram.CustPhone = @"0123456789";
    self.paypram.LanguageCode = @"EN";
    self.paypram.PaymentDesc = @"just buy something";
    self.paypram.PageTimeout = @"600";
    //  self.paypram.CustID = @"12345678";
    //  self.paypram.HashValue = @"";
    
    [self generateNewPaymentID];
    self.paypram.PaymentID = self.paymentID;
    self.paypram.OrderNumber = self.paymentID;

    self.paypram.settingDict = @{
                                 EGHL_DEBUG_PAYMENT_URL:[NSNumber numberWithBool:!self.realHost],
                                 // EGHL_ENABLED_CARD_PAGE:         @YES, // Default: NO;
                                 // EGHL_TOKENIZE_REQUIRED:         @YES  // Defautl: NO;
                                 // EGHL_CVV_OPTIONAL:              @YES,  // Default: NO;
                                 
                                 // To trigger return URL upon transaction process completed
                                 // EGHL_SHOULD_TRIGGER_RETURN_URL: @NO,  // Default: NO
                                 
                                 // To set number of requery
                                 // refer: https://bitbucket.org/eghl/ios/wiki/Home#markdown-header-scenario-3-redirectingloading-to-bank-page-etc-and-user-exit-sdk
                                 // EGHL_NUM_OF_REQUERY: [NSNumber numberWithInteger:6],  // Default: 12
                                 
                                 // EGHL_NAV_BAR_TITLE_COLOR:  [UIColor greenColor],
                                 // EGHL_NAV_BAR_BG_COLOR:     [UIColor purpleColor],
                                 // EGHL_CARD_PAGE_BG_COLOR:   [UIColor blueColor]
                                 };
    self.paypram.PymtMethod = EGHL_PAYMENT_METHOD_CARD;
    self.paypram.TokenType = @"OCP";
    self.paypram.Token = @"uUekGp3SPBI7upNxBcZjA==";
    
    NSLog(@"\n%@", [ViewController displayRequestParam:self.paypram]);
    [self eGHLAPI];
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
    
    self.paypram.TransactionType = EGHL_TRANSACTION_TYPE_QUERY;
    self.paypram.PaymentID = self.paymentID;
    self.paypram.OrderNumber = self.paymentID;
    
    [self eGHLAPI];
}

- (IBAction)preAuthReqBtn:(UIButton *)btnSale {
    [self.view endEditing:YES];
    
    self.paypram.TransactionType = @"AUTH";
    
    self.paypram.CustEmail = @"johndoe@test.com";
    self.paypram.CustName = @"John Doe";

    self.paypram.MerchantReturnURL = @"SDK"; // Just put any dummy string, cannot be empty
    //    self.paypram.MerchantCallBackURL = @"https://abc.com/callback";
    
    self.paypram.CustPhone = @"0123456789";
    self.paypram.LanguageCode = @"EN";
    self.paypram.PaymentDesc = @"just buy something";
    self.paypram.PageTimeout = @"600";
    
    [self generateNewPaymentID];
    self.paypram.PaymentID = self.paymentID;
    self.paypram.OrderNumber = self.paymentID;
    
    [self eGHLAPI];
}

- (IBAction)captureReqBtn:(UIButton *)btnSale {
    [self.view endEditing:YES];
    
    self.paypram.TransactionType = EGHL_TRANSACTION_TYPE_CAPTURE;
    self.paypram.PaymentID = self.paymentID;
    
    [self eGHLAPI];
}

#pragma mark - Master Pass
- (IBAction)masterPassButtonPressed:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.paypram.TokenType = @"MPE";
    self.paypram.Token = @"somebodyLoginID"; // Comsumer's login ID to merchant System
    
    self.paypram.PaymentDesc = @"Testing MasterPass 会心";
    self.paypram.Amount = @"10.00";
    
    self.paypram.CurrencyCode = @"MYR";
    
    [self.eghlpay executeMasterpass:self.paypram successBlock:^(PaymentRespPARAM * paramData) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self generateNewPaymentID];
        self.paypram.PaymentID = self.paymentID;
        self.paypram.OrderNumber = self.paymentID;
        
        if (paramData.PreCheckoutId && paramData.Cards.count > 0) {
            self.listOfCard = paramData.Cards;
            self.preCheckoutID = paramData.PreCheckoutId;
            
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Select Card" preferredStyle:UIAlertControllerStyleActionSheet];
            
            for (NSDictionary * cardDict in self.listOfCard) {
                [alertController addAction: [UIAlertAction actionWithTitle:[self displayFormatForLastFour:cardDict[@"LastFour"]] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    for (NSDictionary * cardDict in self.listOfCard) {
                        if ([action.title isEqualToString:[self displayFormatForLastFour:cardDict[@"LastFour"]]]) {
                            self.paypram.PreCheckoutId = self.preCheckoutID;
                            self.paypram.CardId = cardDict[@"CardId"];
                            
                            self.paypram.TransactionType=@"SALE";
                            self.paypram.MerchantReturnURL = @"abc";
                            
                            [self eGHLAPI];
                            
                            break;
                        }
                    }
                }]];
            }
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
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
            
            [self eGHLAPI];
        }
    } failedBlock:^(NSString *errorCode, NSString *errorData, NSError *error) {
        NSLog(@"errorCode:%@", errorCode);
        NSLog(@"errorData:%@", errorData);
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
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

#pragma mark - Convenient Methods
+ (NSString *)displayResponseParam:(PaymentRespPARAM *)respParam {
    NSMutableString * message = [NSMutableString string];
    
    for (NSString * key in @[@"Amount",@"AuthCode",@"BankRefNo",@"CardExp",@"CardHolder",@"CardNoMask",@"CardType",@"CurrencyCode",@"EPPMonth",@"EPP_YN",@"HashValue",@"HashValue2",@"IssuingBank",@"OrderNumber",@"PromoCode",@"PromoOriAmt",@"Param6",@"Param7",@"PaymentID",@"PymtMethod",@"QueryDesc",@"ServiceID",@"SessionID",@"SettleTAID",@"TID",@"TotalRefundAmount",@"Token",@"TokenType",@"TransactionType",@"TxnExists",@"TxnID",@"TxnMessage",@"TxnStatus",@"ReqToken",@"PairingToken",@"PreCheckoutId",@"Cards",@"mpLightboxError"]) {
        NSString * value = [respParam valueForKey:key];
        
        if ([value isKindOfClass:[NSString class]] && value.length>0) {
            [message appendFormat:@"%@: %@\n", key,value];
        } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value
                                                               options:0 //NSJSONWritingPrettyPrinted for readability
                                                                 error:&error];
            
            if (jsonData) {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                
                [message appendFormat:@"%@: %@\n", key, jsonString];
            }
            
        }
    }
    
    return message;
}
+ (NSString *)displayRequestParam:(PaymentRequestPARAM *)reqParam {
    NSMutableString * message = [NSMutableString string];
    
    for (NSString * key in @[@"realHost",@"Amount", @"PaymentID", @"OrderNumber", @"MerchantName", @"ServiceID", @"PymtMethod", @"MerchantReturnURL", @"CustEmail", @"Password", @"CustPhone", @"CurrencyCode", @"CustName", @"LanguageCode", @"PaymentDesc", @"PageTimeout", @"CustIP", @"MerchantApprovalURL", @"CustMAC", @"MerchantUnApprovalURL", @"CardHolder", @"CardNo", @"CardExp", @"CardCVV2", @"BillAddr", @"BillPostal", @"BillCity", @"BillRegion", @"BillCountry", @"ShipAddr", @"ShipPostal", @"ShipCity", @"ShipRegion", @"ShipCountry", @"TransactionType", @"TokenType", @"Token", @"SessionID", @"IssuingBank", @"MerchantCallBackURL", @"B4TaxAmt", @"TaxAmt", @"Param6", @"Param7", @"EPPMonth", @"PromoCode", @"ReqVerifier", @"PairingVerifier", @"CheckoutResourceURL", @"ReqToken", @"PairingToken", @"CardId", @"PreCheckoutId", @"mpLightboxParameter",  @"sdkTimeOut"]) {
        id value = [reqParam valueForKey:key];
        
        if (value) {
            if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSArray class]]) {
                if ([value length]>0) {
                    [message appendFormat:@"%@: %@\n", key, value];
                }
            } else if ([value isKindOfClass:[NSNumber class]]) {
                [message appendFormat:@"%@: %d\n", key, [value intValue]] ;
            }
        }
    }
    
    return message;
}

- (void)eGHLAPI {
    [self.eghlpay execute:self.paypram fromViewController:self successBlock:^(PaymentRespPARAM *responseData) {
        NSLog(@"\n%@", [ViewController displayResponseParam:responseData]);
        
        NSString * resultString;
        if ([responseData.mpLightboxError isKindOfClass:[NSDictionary class]]) {
            resultString = [NSString stringWithFormat:@"%@", responseData.mpLightboxError];
        } else {
            resultString = [ViewController displayResponseParam:responseData];
        }
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:[self.paypram.TransactionType stringByAppendingString:@"Result"]
                                                                                  message:resultString
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } failedBlock:^(NSString *errorCode, NSString *errorData, NSError *error) {
        NSLog(@"errordata:%@ (%@)", errorData, errorCode);
        
        if (error) {
            NSString * urlstring = [error userInfo][@"NSErrorFailingURLKey"];
            if (urlstring) {
                NSLog(@"NSErrorFailingURLKey:%@",urlstring);
            }
        }
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Error (%@)", errorCode]
                                                                                  message:errorData preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}


@end
