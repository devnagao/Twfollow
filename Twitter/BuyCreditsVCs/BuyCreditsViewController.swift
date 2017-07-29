//
//  BuyCreditsViewController.swift
//  Twitter
//
//  Created by Dev on 7/28/17.
//  Copyright © 2017 Dev. All rights reserved.
//

import UIKit
import Alamofire
import SystemConfiguration
import Foundation


class BuyCreditsViewController: UIViewController {

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var imgLoading: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadingView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func on250(_ sender: Any) {
        let receiptURL = Bundle.main.appStoreReceiptURL
        
        do {
            let receipt = try Data(contentsOf: receiptURL!)
            self.encodeBase64(str: receipt)
        } catch {
            
        }
        
//        self.encodeBase64(str: "credits_250")
    }
    
    @IBAction func on500(_ sender: Any) {
//        self.encodeBase64(str: "credits_500")
    }
    
    @IBAction func on1000(_ sender: Any) {
//        self.encodeBase64(str: "credits_1000")
    }
    
    @IBAction func on2500(_ sender: Any) {
//        self.encodeBase64(str: "credits_2500")
    }
    
    @IBAction func on5000(_ sender: Any) {
//        self.encodeBase64(str: "credits_5000")
    }
    
    @IBAction func on10000(_ sender: Any) {
//        self.encodeBase64(str: "credits_10000")
    }
    
    func encodeBase64(str: Data) {
        
        print("Original: \(str)")
        
        let gif = UIImage.gifImageWithName(name: "loading")
        self.imgLoading.image = gif
        self.loadingView.isHidden = false
        
        if (!isInternetAvailable()) {
            self.loadingView.isHidden = true
            self.showDefaultAlert(title: "Error", message: "There is no internet connection.")
            return
        }
        
        
        let receiptData = str.base64EncodedString()
        if (receiptData == "")
        {
            
            //print("Encoded:  \(receiptData)")
            
//            let storeURL = "https://buy.itunes.apple.com/verifyReceipt"
            let storeURL = "https://sandbox.itunes.apple.com/verifyReceipt"
            let requestContents: [String: Any] = ["receipt-data": receiptData]
            
            Alamofire.request(storeURL, method: .post, parameters: requestContents,
                              encoding: URLEncoding.default)
                .responseJSON { response in
                    self.imgLoading.image = nil
                    self.loadingView.isHidden = true
                    
                    guard response.result.error == nil else {
                        // got an error in getting the data, need to handle it
                        
                        self.showDefaultAlert(title: "Error", message: "")
                        print(response.result.error!)
                        return
                    }
                    // make sure we got some JSON since that's what we expect
                    guard let json = response.result.value as? [String: Any] else {
                        self.showDefaultAlert(title: "Error", message: "Empty Data")
                        
                        print("didn't get todo object as JSON from API")
                        print("Error: \(String(describing: response.result.error))")
                        return
                    }
                    
                    let status = json["status"] as! Int
                    if (status == 0) {
                        
                        guard let receipt = json["receipt"] as? [String: Any] else {
                            self.showDefaultAlert(title: "Error", message: "No get receipt")
                            return
                        }
                        
                        self.iap(receipt: receipt)
                        
                    } else {
                        
                        print("Error: no get receipt")
                    }
            }
            
        }
    }

    func iap(receipt: [String:Any]) {
        
        let gif = UIImage.gifImageWithName(name: "loading")
        self.imgLoading.image = gif
        self.loadingView.isHidden = false
        
        if (!isInternetAvailable()) {
            self.loadingView.isHidden = true
            self.showDefaultAlert(title: "Error", message: "There is no internet connection.")
            return
        }
        
        let urlString: String = "https://www.twfollo.com/retweet/twapi.php"
        
        let username = UserDefaults.standard.string(forKey: "username") ?? ""
        let param: [String: Any] = ["twusername333": username, "getoperation": "buycredits", "receipt": receipt]
        
        Alamofire.request(urlString, method: .post, parameters: param,
                          encoding: URLEncoding.default)
            .responseJSON { response in
                self.imgLoading.image = nil
                self.loadingView.isHidden = true
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    
                    self.showDefaultAlert(title: "Error", message: "")
                    print(response.result.error!)
                    return
                }
                // make sure we got some JSON since that's what we expect
                guard let json = response.result.value as? [String: Any] else {
                    self.showDefaultAlert(title: "Error", message: "Empty Data")
                    
                    print("didn't get todo object as JSON from API")
                    print("Error: \(String(describing: response.result.error))")
                    return
                }
                
                self.completionPurchase()
                
        }
    }
    
    
    func completionPurchase() {
        
        let alertController = UIAlertController(title: "Success" as String, message: "do you want to see  other applications of us?" as String, preferredStyle: UIAlertControllerStyle.alert)
        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (action) in
            UIApplication.shared.open(URL(string: "https://itunes.apple.com/developer/erkan-eroglu/id667357099")!, options: [:], completionHandler: nil)
        }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    
    func showDefaultAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title as String, message: message as String, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}