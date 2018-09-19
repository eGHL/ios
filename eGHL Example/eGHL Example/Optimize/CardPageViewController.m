//
//  CardPageViewController.m
//  eGHL Example
//
//  Created by Arif Jusoh on 14/09/2018.
//  Copyright © 2018 GHL ePayments Sdn Bhd. All rights reserved.
//

#import "CardPageViewController.h"
#import <EGHL/EGHL.h>

@interface CardPageViewController ()
@property (strong, nonatomic) NSString * paymentID;
@property (strong, nonatomic) EGHLPayment * eghl;
@end

@implementation CardPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupEghlView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (EGHLPayment *)eghl {
    if (!_eghl) {
        _eghl = [[EGHLPayment alloc] init];
    }
    return _eghl;
}


// Any Unique String
- (NSString *)generateDateTime {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddHHmmss"];
    NSString * dateString = [df stringFromDate:[NSDate date]];
    
    return dateString;
}

- (NSArray *)cardSettings {
    NSMutableArray * cardSettings = [@[
                                       // Card Holder
                                       @{
                                           EGHL_CARD_HOLDER: @{
                                                   EGHL_ATTRIBUTE_ROW_HEIGHT:[NSNumber numberWithFloat:72.5f],
                                                   EGHL_ATTRIBUTE_CELL_XIB: @"GeneralTableCell",
                                                   EGHL_ATTRIBUTE_TITlE: @"Customer name (Card holder name)",
                                                   EGHL_ATTRIBUTE_PLACEHOLDER: @"Enter the name on the card"
                                                   }
                                           },
                                       @{
                                           EGHL_ATTRIBUTE_SECTION: @{
                                                   EGHL_ATTRIBUTE_ROW_HEIGHT:[NSNumber numberWithFloat:50.0f],
                                                   EGHL_ATTRIBUTE_CELL_XIB: @"SectionView"
                                                   }
                                           },
                                       // Card Number
                                       @{
                                           EGHL_CARD_NUMBER: @{
                                                   EGHL_ATTRIBUTE_ROW_HEIGHT:[NSNumber numberWithFloat:72.5f],
                                                   EGHL_ATTRIBUTE_CELL_XIB: @"CardNumberTableCell"
                                                   }
                                           },
                                       ] mutableCopy];
    
    // Card expiry & Card Cvv
    NSDictionary * cardExpiryDict = @{
                                      EGHL_CARD_EXPIRY: @{
                                              EGHL_ATTRIBUTE_TITlE:        @"Expiration Date",
                                              EGHL_ATTRIBUTE_PLACEHOLDER:  @"MM / YYYY",
                                              EGHL_ATTRIBUTE_CARD_EXP_TAG_YEAR:     @"YYYY",
                                              EGHL_ATTRIBUTE_CARD_EXP_TAG_MONTH:    @"MM",
                                              EGHL_ATTRIBUTE_CARD_EXP_TAG_SEPERATOR:@" / "
                                              },
                                      };
    
    NSDictionary * cardCVVDict = @{
                                   EGHL_CARD_CVV: @{
                                           EGHL_ATTRIBUTE_TITlE:        @"CVV",
                                           EGHL_ATTRIBUTE_PLACEHOLDER:  @"Enter Card CVV"
                                           }
                                   };
    
    NSDictionary * cardExp_Cvv = @{
                                   EGHL_CARD_CUSTOM: @{
                                           EGHL_ATTRIBUTE_ROW_HEIGHT:[NSNumber numberWithFloat:92.5f],
                                           EGHL_ATTRIBUTE_CELL_XIB: @"CardExpiryCell",
                                           EGHL_CARD_SETTING:@[
                                                   cardExpiryDict,
                                                   cardCVVDict
                                                   ]
                                           }
                                   };
    [cardSettings addObject:cardExp_Cvv];
    return cardSettings;
}

- (void)setupEghlView {
    PaymentRequestPARAM * requestParam = [[PaymentRequestPARAM alloc] init];
    requestParam.ServiceID = @"SIT";
    requestParam.Password = @"sit12345";
    
    self.paymentID = [self generateDateTime];
    requestParam.PaymentID = self.paymentID;
    // For recurring
    // requestParam.CustEmail = @"johndoe@test.com";
    // requestParam.CustPhone = @"0123456789";
    // requestParam.TokenType = @"OCP";
    // requestParam.Token = @"xfypazs0LZUfF4sPY5M5sw==";
    
    requestParam.settingDict = @{
                                 EGHL_CARD_SETTING: [self cardSettings],
                                 EGHL_DEBUG_PAYMENT_URL:         @YES, // Default: NO;
                                 // EGHL_HIDE_DEFAULT_CARD_TYPE:@YES, // hide card type
                                 };
    
    [self.eghl loadCardView:self.eghlView paymentRequest:requestParam fromViewController:self failedBlock:^(NSString* errorCode, NSString* errorData, NSError * error){
        if ([[error domain] isEqualToString:@"EGHLAPIErrorType"]) { // For debugging purpose
            EGHLAPIErrorType type = (EGHLAPIErrorType)[errorCode intValue];
            switch (type) {
                case EGHLAPIErrorSOPInvalidEmailOrPhone:
                    NSLog(@"CustEmail/CustPhone is missing");
                    break;
                    
                default:
                    break;
            }
        }
    }];
}

- (IBAction)checkoutButtonDidPressed:(id)sender {
    [self.eghl fetchSOPTokenSuccess:^(NSString *token, NSString * tokenType, NSString *paymentId) {
        NSLog(@"Token: %@, TokenType: %@, PaymentID: %@", token, tokenType, paymentId);
        
        EGHLPayment * eghl = [[EGHLPayment alloc] init];
        
        PaymentRequestPARAM * requestParam = [[PaymentRequestPARAM alloc] init];
        
        requestParam.TokenType = tokenType;
        requestParam.Token = token;
        
        requestParam.MerchantName = @"eGHL Testing";
        requestParam.ServiceID = @"SIT";
        requestParam.Password = @"sit12345";
        
        requestParam.TransactionType = @"SALE";
        requestParam.MerchantReturnURL = @"SDK";
        requestParam.MerchantCallBackURL = @"http://arifall.my/eGHL/mp_callback.php?transId=1816;callbackURL=1";
        requestParam.CurrencyCode = @"MYR";
        requestParam.Amount = @"1.00";
        requestParam.LanguageCode = @"EN";
        requestParam.PaymentDesc = @"eGHL Debug - verify page";
        requestParam.PageTimeout = @"600";
        
        requestParam.PaymentID = self.paymentID;
        requestParam.OrderNumber = [NSString stringWithFormat:@"AJ%@%d", self.paymentID, (int)arc4random_uniform(9999 + 1)];
        
        requestParam.CustEmail = @"johndoe@test.com";
        requestParam.CustName = @"John Doe";
        requestParam.CustPhone = @"0123456789";
        
        requestParam.settingDict = @{
                                     EGHL_DEBUG_PAYMENT_URL:         @YES, // Default: NO;
                                     EGHL_CARD_CUSTOMER_CONSENT: [NSNumber numberWithBool:self.customerConsent.on],
                                     // EGHL_NUM_OF_REQUERY: [NSNumber numberWithInteger:1],  // Default: 12
                                     // EGHL_SHOULD_TRIGGER_RETURN_URL: @NO,  // Default: NO
                                     // EGHL_NAV_BAR_TITLE_COLOR:  [UIColor whiteColor],
                                     // EGHL_NAV_BAR_BG_COLOR:     [UIColor colorWithRed:0.95 green:0 blue:0 alpha:1.0],
                                     // EGHL_CARD_PAGE_BG_COLOR:   [UIColor blueColor]
                                     };
        requestParam.PymtMethod = EGHL_PAYMENT_METHOD_CARD;
        
        [eghl execute:requestParam fromViewController:self successBlock:^(PaymentRespPARAM *responseData) {
            NSLog(@"Raw response: %@", responseData.rawResponseDict);
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Response" message:[NSString stringWithFormat:@"Trasaction status:%@\nMessage:%@", responseData.TxnStatus, responseData.TxnMessage] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:[self okActionHandler]];
            [alert addAction:okAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        } failedBlock:^(NSString *errorCode, NSString *errorData, NSError *error) {
            NSLog(@"%@", errorData);
        }];
    } failed:^(NSString *errorCode, NSString *errorData, NSError *error) {
        NSLog(@"errorCode: %@, errorData: %@ , error: %@", errorCode, errorData, error);

        UIAlertController * alert = [UIAlertController alertControllerWithTitle:errorData message:[error localizedRecoverySuggestion] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (void (^)(UIAlertAction *action))okActionHandler {
    return ^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:YES];
    };
}
@end
