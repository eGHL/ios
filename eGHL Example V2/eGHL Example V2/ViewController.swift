//
//  ViewController.swift
//  eGHL Example V2
//
//  Created by Shyan Hua on 23/02/2021.
//

import UIKit
import EGHL

class ViewController: UIViewController {
    
    @IBOutlet weak var saleButton: UIButton!
    
    var payParam = PaymentRequestPARAM()
    let ghl = EGHLPayment()
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saleButton(_ sender: UIButton) {
        let value = arc4random_uniform(9999 + 1)
        
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "yyyyMMddHHmm"
        
        let dateString: String = df.string(from: Date())
        
        self.payParam.merchantName = "eGHL Payment Testing"
        self.payParam.serviceID = "SIT"
        self.payParam.password = "sit12345"


        self.payParam.transactionType = "SALE"
        self.payParam.merchantReturnURL = "SDK"
        self.payParam.merchantCallBackURL = "http://somesite.com/"
        self.payParam.currencyCode = "MYR"
        self.payParam.amount = "1.00"
        self.payParam.languageCode = "EN";
        self.payParam.paymentDesc = "Buy something";
        self.payParam.pageTimeout = "600";
        
        self.payParam.paymentID = "\(dateString)\(value)"
        self.payParam.orderNumber = "\(self.payParam.serviceID ?? "")\(dateString)\(value)"

        self.payParam.custEmail = "somebody@somesite.com"
        self.payParam.custName = "Somebody"
        self.payParam.custPhone = "0123456789"
        
        self.payParam.settingDict = [
            EGHL_DEBUG_PAYMENT_URL: true, // Default: false
            EGHL_WEBVIEW_ZOOMING: true, // Default: false
            // EGHL_ENABLED_CARD_PAGE: true, // Default: false
            // EGHL_TOKENIZE_REQUIRED: true, // Default: false
            // EGHL_CVV_OPTIONAL:      true, // Default: false
            
            // To trigger return URL upon transaction process completed
            //  EGHL_SHOULD_TRIGGER_RETURN_URL: true, // Default: false
            
            // To set number of requery
            // refer: https://bitbucket.org/eghl/ios/wiki/Home#markdown-header-scenario-3-redirectingloading-to-bank-page-etc-and-user-exit-sdk
            // EGHL_NUM_OF_REQUERY: [NSNumber numberWithInteger:6],  // Default: 12
            
            // EGHL_NAV_BAR_TITLE_COLOR: UIColor.green,
            // EGHL_NAV_BAR_BG_COLOR: UIColor.purple,
            // EGHL_CARD_PAGE_BG_COLOR: UIColor.blue
        ]
        // self.payParam.pymtMethod = EGHL_PAYMENT_METHOD_CARD
        // self.paypram.TokenType = @"OCP";
        // self.paypram.Token = @"vTlpNhakj24ijZjJaSqd5A==";

        print("paymentID:", self.payParam.paymentID)
        
        ghl.execute(self.payParam, fromViewController: self, successBlock: { responseData in
            let alert = UIAlertController(title: "Response", message: "Response Status: \(responseData?.txnStatus ?? "")\n\(responseData?.txnMessage ?? "")", preferredStyle: UIAlertController.Style.alert)
        
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }) { (errorCode, errorData, error) in
            print("errorData:\(errorData ?? "")")
        }
    }

}

