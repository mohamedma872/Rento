//
//  ForgotPasswordViewController.swift
//  Rento
//
//  Created by mouhammed ali on 8/20/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import Toast_Swift
class ForgotPasswordViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!

    @IBAction func submitButt(_ sender: Any) {
        forgetPass()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func forgetPass(){
        if emailField.text != "" {
            HUD.show(.progress)
            let headers = ["Accept": "application/json"]
        let par = ["email" : emailField.text!]
      
            Alamofire.request("http://myrentoapp.com/api/password/email", method: .post, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
                switch(response.result) {
                    
                    
                case .success(let value):
                    print(value)
                     HUD.hide()
                    if let resResponse = value as? [String:AnyObject]{
                        
                        if let error = resResponse["errors"] as? [String:AnyObject] {
                            if let erMsg = error["email"] as? [String] {
                                var er = ""
                                for i in 0..<erMsg.count {
                                    er = er + erMsg[i]
                                    if i != erMsg.count - 1 {
                                       er = er + "\n"
                                    }
                                }
                                self.view.makeToast(er)
                            }
                            if let erMsg = error["email"] as? String {
                                self.view.makeToast(erMsg)
                            }
                        }
                        if let message = resResponse["message"] as? String{
                            self.view.makeToast(message)
                            let when = DispatchTime.now() + 2
                            DispatchQueue.main.asyncAfter(deadline: when) {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController2")
                                self.navigationController?.pushViewController(vc!, animated: true)
                            }
                            
                        }
                    }
                    
                   
                case .failure(let error):
                    print(error)
                    HUD.hide()
                    self.view.makeToast("something went wrong")
                }
            
            
            
        }

        }
    }

}
