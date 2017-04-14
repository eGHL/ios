![eghl.png](http://e-ghl.com/assets/img/logo.png)
***
*Software Development Kit (SDK)* makes it easier to integrate your mobile application with eGHL Payment Gateway. This repository is intended as a technical guide for merchant developers and system integrators who are responsible for designing or programming the respective applications to integrate with Payment Gateway

# **Getting Started** #
In this page, you'll find all the information you need to get started and start receiving payments on your mobile apps.

# **How It all works** #
In this section, you will have general overview of SDK so that you have a better understanding on how all the pieces fall into place.

It all starts with user intend to **make payment**/**checkout** in the merchants app by either pressing the link/button, merchant app will gather required info (exclude sensitive card data) and pass it to the SDK via provided parameter object & methods.
At this point, all processing will handle by SDK. SDK will redirect user to eGHL's payment page (some call it **landing page**) and bank side choosed by merchant/user. 

# **Skipping eGHL's payment page** #
It's your chooice! eGHL's gateway behave accordingly by info you pass. **Except for cards payments**, merchant have the option to bypass our Landing Page by giving correct **PymtMethod** & **IssuingBank**.

eg.
````
     self.paypram.IssuingBank = @"FPXD_MB2U0227"; // Maybank2u
     self.paypram.PymtMethod  = @"DD";
````

FPX Test environment:

* FPXD_TEST0021 → *Success test*
* FPXD_TEST0022 → *Failed test*
     
Production environment:

* FPXD_MB2U0227 → *Maybank2u *
* FPXD_BCBB0235 → *CIMB Clicks*
* FPXD_RHB0218  → *RHB Now*
* FPXD_HLB0224  → *Hong Leong Connect*
* FPXD_AMBB0209 → *AmOnline*
* FPXD_ABMB0212 → *AllianceOnline*

# **Normal payment flow** #
1. Checkout **[User]**
2. Compile info & pass to SDK **[Merchant]**
3. Redirect to banks site **[SDK]**
4. Authorise payment **[User]**
5. Finalise transaction, response & redirect to eGHL **[Bank]**
6. Return payment status + details **[SDK]**
7. Show receipt **[Merchant]**

In normal flow (user authorise payment in bank side and wait until sdk redirect back to your app) merchant app will only get transaction 1 or 0. 
However, there a situation where sdk return 2, which is pending. Refer scenario 3.

**User exit sdk** = user press exit/back button (including hardware back button)

##Scenario 1  - User exit SDK **before** eGHL landing page finish load##
* **IOS**

    SDK will return **only** *TxnMessage = @"Buyer cancelled”* & *TxnStatus = @"1”*

* **Android**
    
    SDK will return as the following

````
Status Code     Constant Name                   Description
-999            EGHL.TRANSACTION_CANCELLED      Transaction cancelled by the user
````

##Scenario 2 - Landing page finish load and user exit sdk##

SDK will return same result as when user tap on cancel link at the bottom of eGHL Landing page
eg.
code in our page:
````
#!html
<a href="http://arifjusoh.local:8888/arifall.my/eGHL/success_page.php?TransactionType=SALE&PymtMethod=ANY&ServiceID=SIT&PaymentID=AJ1490948167917&OrderNumber=1490948167917&Amount=1.00&CurrencyCode=MYR&TxnID=&TxnStatus=1&Param6=&Param7=&TxnMessage=Buyer%20cancelled&HashValue=e5bf7e82414e37c27aa616f271564d6bee5598fbc8a5fe302f8d772d47b4dfb1&HashValue2=a5af31a0eee1d1d7180337adba5b58ffe5a96905eac2bfc748fc76433667819f” > Cancel and Return to eGHL Testing </a>
````

Result (Converted to json format)
````
#!json
{
    "TransactionType": "SALE",
    "PymtMethod": "ANY",
    "ServiceID": "SIT",
    "PaymentID": "AJ1490948167917",
    "OrderNumber": "1490948167917",
    "Amount": "1.00",
    "CurrencyCode": "MYR",
    "TxnID": "",
    "TxnStatus": "1",
    "Param6": "",
    "Param7": "",
    "TxnMessage": "Buyer cancelled",
    "HashValue": "e5bf7e82414e37c27aa616f271564d6bee5598fbc8a5fe302f8d772d47b4dfb1",
    "HashValue2": "a5af31a0eee1d1d7180337adba5b58ffe5a96905eac2bfc748fc76433667819f"
}
````

##Scenario 3 - Redirecting/loading to bank page, etc.. and user exit sdk##

SDK will requery  to ensure not to miss any capture status by bank.

eg.

````
#!json
{
  "TxnExists": "0",
  "QueryDesc": "Record exists",
  "TransactionType": "QUERY",
  "PymtMethod": "ANY",
  "ServiceID": "SIT",
  "PaymentID": "AJ1490948167917",
  "OrderNumber": "1490948167917",
  "Amount": "1.00",
  "TotalRefundAmount": "0",
  "CurrencyCode": "MYR",
  "TxnID": "",
  "IssuingBank": "",
  "TxnStatus": "1",
  "AuthCode": "",
  "BankRefNo": "",
  "TxnMessage": "",
  "HashValue": "e5bf7e82414e37c27aa616f271564d6bee5598fbc8a5fe302f8d772d47b4dfb1",
  "SessionID": "",
  "HashValue2": "a5af31a0eee1d1d7180337adba5b58ffe5a96905eac2bfc748fc76433667819f",
  "getParameters": "TxnExists=0&QueryDesc=Record exists&TransactionType=QUERY&PymtMethod=ANY&ServiceID=SIT&PaymentID=AJ1490948167917&OrderNumber=1490948167917&Amount=1.00&TotalRefundAmount=0&CurrencyCode=MYR&TxnID=&IssuingBank=&TxnStatus=1&AuthCode=&BankRefNo=&TxnMessage=&HashValue=e5bf7e82414e37c27aa616f271564d6bee5598fbc8a5fe302f8d772d47b4dfb1&SessionID=&HashValue2=a5af31a0eee1d1d7180337adba5b58ffe5a96905eac2bfc748fc76433667819f"
}
````

****

## Test card ##
````
Approved Test Cards
VISA: 4444333322221111
MasterCard: 5555444433332222
Expiry Date: any value
CVV2: any value

Declined Test Cards
VISA: 4444333322221414
MasterCard: 5555444433331414
Expiry Date: any value
CVV2: any value

No Response Test Cards
VISA: 4444333322225353
MasterCard: 5555444433335353
Expiry Date: any value
CVV2: any value
````

## **Change Log** ##
### [**v1.8.6](https://bitbucket.org/eghl/ios/commits/719131b)
* added extra approach to get instance response in browser (js-json approach)
* fixed bug on function name finalizeTransaction

### **v1.8.5
* added function name finalizeTransaction, this should be call whenever merchant intend to close SDK. Result will return via protocol :- (void)QueryResult:(PaymentRespPARAM *)result;