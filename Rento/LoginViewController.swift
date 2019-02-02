//
//  LoginViewController.swift
//  Rento
//
//  Created by mouhammed ali on 8/20/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import Toast_Swift
class LoginViewController: UIViewController {
    @IBOutlet weak var emaolField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
     var lang = ""
    @IBAction func loginButt(_ sender: Any) {
        if emaolField.text != "" && passwordField.text != "" {
            logIn()
        }else{
            self.view.makeToast("Please Fill In The Username And Password")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let langString = UserDefaults.standard.object(forKey: "language") as? String {
            lang = langString
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logIn() {
        HUD.show(.progress)
        let par = ["email": emaolField.text!,
                   "password":passwordField.text!,
                   "one-signal-player-id":UserDefaults.standard.string(forKey: "onesignalid")!]
        print(par)
        let headers = ["Accept":"application/json"]
                       
        Alamofire.request("http://myrentoapp.com/api/login?language=\(lang)", method: .post, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                HUD.hide()
                print(value)
                
                if let dict = value as? [String:AnyObject] {
                    if let errorDict = dict["errors"] as? [String:AnyObject]{
                        if let errorString = errorDict["email"] as? String {
                            self.view.makeToast(errorString)
                        }
                        if let errorString = errorDict["password"] as? String {
                            self.view.makeToast(errorString)
                        }

                        
                    }
                    if let errorString = dict["errors"] as? String {
                        self.view.makeToast(errorString)
                    }
                    if let user = dict["user"] as? [String:AnyObject]{
                        if let boolVerified = user["is_verified"] as? Bool {
                            if boolVerified == true {
                                skipped = 0
                                
                                UserDefaults.standard.set(user, forKey: "user")
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCarsView"), object: nil, userInfo: nil)
                                
                        
                                if UserDefaults.standard.integer(forKey: "openedBefoure") == 0 {
                                    UserDefaults.standard.set(1, forKey: "openedBefoure")
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SegmentedViewController")
                                    self.navigationController?.pushViewController(vc!, animated: true)
                                }
                                
                                
                                self.dismiss(animated: true, completion: nil)
                            }else{
                                self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier: "WaitVerificartionViewController"))!, animated: true)
                            }
                        }
                  
                    }
                }
                
            case .failure(let error):
                print(error)
                HUD.hide()
            }
        }

    }

}
