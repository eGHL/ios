![eghl.png](http://e-ghl.com/assets/img/logo.png)

*Software Development Kit (SDK)* makes it easier to integrate your mobile application with eGHL Payment Gateway. This repository is intended as a technical guide for merchant developers and system integrators who are responsible for designing or programming the respective applications to integrate with Payment Gateway.

[Home](http://e-ghl.com) | [Wiki](https://bitbucket.org/eghl/ios/wiki/Home) | [Downloads](https://bitbucket.org/eghl/ios/downloads/?tab=tags) | [Follow eGHL](https://bitbucket.org/eghl/follow)

****
# **Change Log** 
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