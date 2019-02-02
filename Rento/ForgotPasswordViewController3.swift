//
//  ForgotPasswordViewController3.swift
//  Rento
//
//  Created by mouhammed ali on 9/6/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import Toast_Swift
class ForgotPasswordViewController3: UIViewController {
    
    @IBOutlet var password: UITextField!
var token = ""
    
    @IBAction func butt(_ sender: Any) {
        
        if password.text != "" {
        HUD.show(.progress)
        let headers = ["Accept": "application/json"]
        let par = ["password" : password.text!,
                   "token":token]
        print(par)
        Alamofire.request("http://myrentoapp.com/api/password/reset", method: .post, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                if let resResponse = value as? [String:AnyObject]{
                    
                    
                        if let error = resResponse["errors"] as? [String:AnyObject] {
                            if let erMsg = error["password"] as? [String] {
                                var er = ""
                                for i in 0..<erMsg.count {
                                    er = er + erMsg[i]
                                    if i != erMsg.count - 1 {
                                        er = er + "\n"
                                    }
                                }
                                self.view.makeToast(er)
                            }
                        }
                    if let token = resResponse["user"] as? [String:AnyObject]{
                        HUD.show(.success)
                        
                        let when = DispatchTime.now() + 1
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
                            self.navigationController?.pushViewController(vc!, animated: true)
                        }
                        
                        
                    }
                    if let errors = resResponse["errors"] as? [String:AnyObject] {
                        if let code = errors["toekn"] as? String {
                            self.view.makeToast(code)
                        }
                        
                    }
                }
                
                HUD.hide()
            case .failure(let error):
                print(error)
                HUD.hide()
                self.view.makeToast("something went wrong")
            }
            
            
            
            }
        }

        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
