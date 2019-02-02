//
//  ContactUSViewController.swift
//  Rento
//
//  Created by mouhammed ali on 11/24/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class ContactUsViewController: UIViewController {
    @IBOutlet var nameTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    
    @IBOutlet var emailContentTxt: UITextView!
    @IBOutlet weak var phone: UITextField!
    @IBAction func callButtAction(_ sender: UIButton) {
        if let url = URL(string: "tel://\(sender.currentTitle!)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    @IBOutlet var callButt: UIButton!
    
    
    @IBAction func send(_ sender: Any) {
        sendEmail()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("CONTACT US", comment: "")
        getPhoneNumber()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*name
     email
     subject
     message*/
    
    func sendEmail(){
        if nameTxt.text != "" && emailTxt.text != "" &&  emailContentTxt.text != "" &&  phone.text! != ""{
            if !(emailTxt.text?.isValidEmail())!{
                self.view.makeToast("البريد الإلكتروني غير صحيح")
                return
            }
            let par = ["name": nameTxt.text!,
                       "email": emailTxt.text!,
                       "phone": phone.text!,
                       "message": emailContentTxt.text!]
            HUD.show(.progress)
            Alamofire.request("http://myrentoapp.com/api/contact_us", method: .post, parameters: par, encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
                switch(response.result) {
                case .success(let value):
                    HUD.hide()
                    print(value)
                    if let dict = value as? NSDictionary {
                        if let result = dict["errors"] as? String{
                            self.view.makeToast("حدث خطأ برجاء إعادة المحاولة لاحقاً")
                            return
                        }
                        if let result = dict["message"] as? String{
                            self.view.makeToast(result)
                        }
                    }
                case .failure(_):
                    HUD.hide()
                    self.view.makeToast("حدث خطأ برجاء إعادة المحاولة لاحقاً")
                    break
                }
            }
        }else{
           self.view.makeToast("من فضلك قم بإكمال الحقول الناقصة")
        }
        
        
    }
    func getPhoneNumber(){
        let headers = ["Accept": "application/json"]
        if let str = UserDefaults.standard.string(forKey: "phoneNumber") {
            callButt.setTitle(str, for: .normal)
        }
        Alamofire.request("http://myrentoapp.com/api/info", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                
                
                print(value)
                if let dict = value as? [String:AnyObject] {
                    if let appDict = dict["app"] as? [String:AnyObject]{
                        let str = "\(appDict["app_phone"]!)"
                        self.callButt.setTitle(str, for: .normal)
                        UserDefaults.standard.set(str, forKey: "phoneNumber")
                    }
                }
                
                
            case .failure(let error):
                print(error)
                
            }
        }
        
    }
    
    
    func setupNavBar(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
}
extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let firstMatch = dataDetector?.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: 0, length: length))
        return (firstMatch?.range.location != NSNotFound && firstMatch?.url?.scheme == "mailto")
    }
    
    public var length: Int {
        return self.characters.count
    }
}

