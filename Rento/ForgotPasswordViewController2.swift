//
//  ForgotPasswordViewController2.swift
//  Rento
//
//  Created by mouhammed ali on 9/6/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import Toast_Swift

class ForgotPasswordViewController2: UIViewController {

    @IBAction func submitButt(_ sender: Any) {
        
        if codefield!.text != "" {
        print(codefield!.text!)
        HUD.show(.progress)
        let headers = ["Accept": "application/json"]
        let par = ["code" : codefield!.text!]
        
        Alamofire.request("http://myrentoapp.com/api/password/check-code", method: .post, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)

                if let resResponse = value as? [String:AnyObject]{
                    if let error = resResponse["errors"] as? [String:AnyObject] {
                        if let erMsg = error["code"] as? [String] {
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
                    
                    if let token = resResponse["token"] as? String{
                        HUD.show(.success)
                        
                        let when = DispatchTime.now() + 1
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController3") as! ForgotPasswordViewController3
                            vc.token = token
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                        
                    }
                    if let errors = resResponse["errors"] as? [String:AnyObject] {
                        if let code = errors["code"] as? String {
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
    
    
    
    var codefield: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        codefield = view.viewWithTag(1) as! UITextField
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
