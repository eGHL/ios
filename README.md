![eghl.png](http://e-ghl.com/assets/img/logo.png)

*Software Development Kit (SDK)* makes it easier to integrate your mobile application with eGHL Payment Gateway. This repository is intended as a technical guide for merchant developers and system integrators who are responsible for designing or programming the respective applications to integrate with Payment Gateway.

# **Configure Xcode project**

Drag & drop EGHL.bundle & EGHL.framework within it to your Xcode project

![4047482560-Screen Shot 2018-06-13 at 10 38 18 AM](https://user-images.githubusercontent.com/46514524/95950323-dfba3280-0e26-11eb-9ac3-282a668b3fb6.png)
![1382549676-Screen Shot 2018-06-13 at 10 38 34 AM](https://user-images.githubusercontent.com/46514524/95950789-c9f93d00-0e27-11eb-94c1-77fa9d007f9c.png)


Uncheck the box “Copy items if needed” then press finish button on bottom right. This will reduce space in your App.
![3922570236-Screen Shot 2017-02-14 at 4 35 04 PM](https://user-images.githubusercontent.com/46514524/95950873-e9906580-0e27-11eb-932f-b6777f7a9aa5.png)

## Project Settings

Next, we need to include eGHL framework into your apps build.

![3673732560-Screen Shot 2018-06-13 at 10 47 05 AM](https://user-images.githubusercontent.com/46514524/95950911-fb720880-0e27-11eb-8297-052390ee7293.png)

1. Select `project file` in project navigator
2. Select `target` in the Project & Target list
3. Open build phases, click `+` button & select `New Copy Files Phase`. 
4. Drag the `Copy Files` section on top of `Compile Sources. 
5. Select `Frameworks` for `Destination` and select .
6. Click `+` under `Copy Files` section and select `EGHL.framework`.

\** Ensure that EGHL.framework appear in `Copy Files` and `Link Binary with Libraries`

# **Configure SDK**

## **Import SDK**

Import SDK's Public header.

````
#import <EGHL/EGHL.h>
````

## **Prepare request details.**

### SALE

````
PaymentRequestPARAM * payparam = [[PaymentRequestPARAM alloc] init];
payparam.Amount = ... (Type: NSString) 
payparam.MerchantName = ... (Type: NSString)
payparam.CustEmail = ... (Type: NSString) 
payparam.CustName = ... (Type: NSString) 
payparam.ServiceID = ... (Type: NSString) 
payparam.Password = ... (Type: NSString) 
payparam.CurrencyCode = ... (Type: NSString)
payparam.PaymentID = ... (Type: NSString)
payparam.OrderNumber = ... (Type: NSString)
payparam.MerchantReturnURL = ... (Type: NSString)
payparam.MerchantCallBackURL = ... (Type: NSString)
payparam.CustPhone = ... (Type: NSString)
payparam.LanguageCode = ... (Type: NSString)
payparam.PageTimeout = ... (Type: NSString)
payparam.PaymentDesc = ... (Type: NSString)
payparam.IssuingBank = ... (Type: NSString)
payparam.PymtMethod = ... (Type: NSString)
payparam.RealHost = ... (Type: NSString)
````

### QUERY

````
PaymentRequestPARAM * payparam = [[PaymentRequestPARAM alloc] init]
payparam.PymtMethod = ... (Type: NSString) 
payparam.ServiceID = ... (Type: NSString) 
payparam.PaymentID = ... (Type: NSString) 
payparam.Amount = ... (Type: NSString) 
payparam.CurrencyCode = ... (Type: NSString)
````

## **Allocate eGHLPayment class.**
````
EGHLPayment * eghl = [[EGHLPayment alloc] init]
````

## **Set Transaction Type**

eg. SALE 
````
payparam.TransactionType = EGHL_TRANSACTION_TYPE_SALE;
````

eg. QUERY 
````
payparam.TransactionType = EGHL_TRANSACTION_TYPE_QUERY;
````

## **Load the SDK**

````
[eghl execute:payparam fromViewController:self successBlock:^(PaymentRespPARAM *responseData) { 
    NSLog(@"SuccessData: %@", SuccessData);
} failedBlock:^(NSString *errorCode, NSString *errorData, NSError *error) { 
    NSLog(@"errorcode: %@ errordata: %@", errorCode, errorData);
}];
````

\* Please refer PaymentRespPARAM class for possible fields 

\* Please refer appendix for fields specification

## **Possible Error code & Error Data**

Error code | Error Data
:--------:|:-----------
-1009|The Internet connection appears to be offline.
-1001|The request timed out.
-1|ParametersEmpty

## **Customize String Messages**

You can customize SDK messages by update the value in `localizable.strings`

eg.
```
...
"Are you sure you want to quit" = "Really?"; // Title
"Pressing BACK button will close and abandon the payment session." = "Press ok to confirm"; // Message
...

```
>Kindly refer localizable.strings in the example app for more details.
