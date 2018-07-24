![eghl.png](http://e-ghl.com/assets/img/logo.png)

*Software Development Kit (SDK)* makes it easier to integrate your mobile application with eGHL Payment Gateway. This repository is intended as a technical guide for merchant developers and system integrators who are responsible for designing or programming the respective applications to integrate with Payment Gateway.

[eGHL](http://e-ghl.com) | [Wiki](https://bitbucket.org/eghl/ios/wiki/Home) | [Downloads](https://bitbucket.org/eghl/ios/downloads/?tab=tags) | [Follow eGHL Repos](https://bitbucket.org/eghl/follow)

****
# **Change Log** 
### [**v2.0.1 rv1](https://bitbucket.org/eghl/ios/commits/tag/v2.0.1)
* Fixed bitcode is not fully turn on.

### [**v2.0.1]
* Fixed card holer name not sent to server.
* Fixed keyboard for not showing for card number & cvv

### [**v2.0.0](https://bitbucket.org/eghl/ios/commits/tag/v2.0.0)
* SDK new base.
* Added Card UI

### [**v1.9.13](https://bitbucket.org/eghl/ios/commits/tag/v1.9.13)
* Allow merchant to send HashValue  

### [**v1.9.12](https://bitbucket.org/eghl/ios/commits/tag/v1.9.12)
* Fixed issue webview will keep on redirecting whenever user return back the app after minimizing it in order to get the OTP code  

### [**v1.9.11](https://bitbucket.org/eghl/ios/commits/tag/v1.9.11)
* Fixed "+" showing in `TxnMessage`  

### [**v1.9.10](https://bitbucket.org/eghl/ios/commits/tag/v1.9.10)
* Fixed instance response not working when MerchantReturnUrl Contains GET parameter
* Added raw response ([rawResponseDict](https://bitbucket.org/eghl/ios/src/1c446c60a49748ad36265fb7126a626b924ce0f2/Library/EGHLPayment.h?at=master&fileviewer=file-view-default#EGHLPayment.h-260)) 
* Added an options([shouldTriggerReturnURL](https://bitbucket.org/eghl/ios/src/1c446c60a49748ad36265fb7126a626b924ce0f2/Library/EGHLPayment.h?at=master&fileviewer=file-view-default#EGHLPayment.h-147)) to trigger MerchantReturnURL (default is false)

### [**v1.9.9rv1](https://bitbucket.org/eghl/ios/commits/tag/v1.9.9rv1)
* enabled bitcode

### [**v1.9.9](https://bitbucket.org/eghl/ios/commits/tag/v1.9.9)
* Fixed issue where SDK timer still running after transaction had finalise for Masterpass express checkout

### [**v1.9.8](https://bitbucket.org/eghl/ios/commits/tag/v1.9.8)
* Fixed delay sdk close for Masterpass express checkout not working if eGHL landing page shows awkward page
* Fixed exiting sdk will still load the url for certain situation. 
* Fixed: making payment immediately after user cancel masterpass express checkout will return "Buyer cancel"

### [**v1.9.7](https://bitbucket.org/eghl/ios/commits/tag/v1.9.7)
* Fixed query trigger in Scenario 1
* For Scenario 1 - masterpass express checkout, now user will need to wait for eghl landing page to finish load before they exit the SDK.
* Fixed webview still loading eghl payment page eventhough the user already exit the SDK
* Added new property in EGHLPayment: cancelMessage
* Added new property in PaymentRespPARAM:RespTime

### [**v1.9.6](https://bitbucket.org/eghl/ios/commits/tag/v1.9.6)
* added [options](https://bitbucket.org/eghl/ios/src/80e843168462c8e878b374bbc275050e84657d7a/Library/EGHLPayment.h?fileviewer=file-view-default#EGHLPayment.h-27,28 "view options") to set customise message for finalising transaction & loading MasterPass transaction 

### [**v1.9.5](https://bitbucket.org/eghl/ios/commits/tag/v1.9.5)
* fixed issue #3 & #4 

### [**v1.9.4](https://bitbucket.org/eghl/ios/commits/tag/v1.9.4)
* fixed apps will hang when calling [`eGHLMPERequest:successBlock:failedBlock`](https://bitbucket.org/eghl/ios/src/05484478c5672c89f3de871062555d4e9db4ee4d/Library/EGHLPayment.h?at=master&fileviewer=file-view-default#EGHLPayment.h-30,31,32,33,34,35,36,37,38,39 "View function"). 
* fixed reopen issue "SDK timer still running after transaction had finalise"

### [**v1.9.3](https://bitbucket.org/eghl/ios/commits/tag/v1.9.3)
* Fixed issue where SDK timer still running after transaction had finalise

### [**v1.9.2](https://bitbucket.org/eghl/ios/commits/tag/v1.9.2)
* Fixed #2: calling finalizeTransaction wont trigger block

### [**v1.9.1](https://bitbucket.org/eghl/ios/commits/tag/v1.9.1)
* Fixed issue #1: Unable to make CC payment in staging
* added NSError in failed Block (onErrorCB) 	

### [**v1.9](https://bitbucket.org/eghl/ios/commits/tag/v1.9)
**SDK**

* Added a [general function](https://bitbucket.org/eghl/ios/src/05484478c5672c89f3de871062555d4e9db4ee4d/Library/EGHLPayment.h?at=master&fileviewer=file-view-default#EGHLPayment.h-55,56,57,58,59,60,61,62,63,64,65,66,67 "view changes")  that will support all type of transaction (SALE, AUTH, QUERY, REVERSAL, REFUND, CAPTURE). 
* Added TransactionType variable in PaymentRequestPARAM
    
**DEMO**

* Added [convenient method](https://bitbucket.org/eghl/ios/commits/ddf4fed3379c4bb0e93b9cc4b03815c302a81cf6#chg-eghl/eghl/ShowViewController.h "view functions") in demo app
* Update UI
    * added constraints
    * added new buttons (pre-auth & capture)

### [**v1.8.7](https://bitbucket.org/eghl/ios/commits/tag/v1.8.7)
* fixed invalid service id
* added support for MSC in 1st message
* added option to skip using SDK Masterpass Lightbox [`self.paypram.mpLightboxParameter = nil`](https://bitbucket.org/eghl/ios/src/05484478c5672c89f3de871062555d4e9db4ee4d/eghl/eghl/ViewController.m?at=master&fileviewer=file-view-default#ViewController.m-337,338,339,340,341 "set to nil")
* fixed finalizeTransaction method not working in certain situation 
### [**v1.8.6](https://bitbucket.org/eghl/ios/commits/tag/v1.8.6)
* added extra approach to get instance response in browser (js-json approach)
* fixed bug on function name finalizeTransaction

### **v1.8.5
* added function name [finalizeTransaction](https://bitbucket.org/eghl/ios/src/05484478c5672c89f3de871062555d4e9db4ee4d/eghl/eghl/ShowViewController.m?at=master&fileviewer=file-view-default#ShowViewController.m-167 "View code"), this should be call whenever merchant intend to close SDK. Result will return via protocol [QueryResult](https://bitbucket.org/eghl/ios/src/05484478c5672c89f3de871062555d4e9db4ee4d/eghl/eghl/ViewController.m?at=master&fileviewer=file-view-default#ViewController.m-213 "View code")
