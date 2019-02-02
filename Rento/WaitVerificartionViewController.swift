//
//  WaitVerificartionViewController.swift
//  Rento
//
//  Created by mouhammed ali on 10/17/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
class WaitVerificartionViewController: UIViewController {
    
    @IBOutlet var lbl: UITextView!
    
    
    @IBAction func signout(_ sender: Any) {
        HUD.show(.progress)
        let headers = ["Accept": "application/json"]
        
        let par = ["one_signal_player_id":UserDefaults.standard.string(forKey: "onesignalid")!
        ]
        Alamofire.request("http://myrentoapp.com/api/logout", method: .get, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                if let resResponse = value as? [String:AnyObject]{
                    if let doneMessage = resResponse["message"] as? String{
                        if doneMessage == "done" {
                            
                            UserDefaults.standard.removeObject(forKey: "user")
                            
                            
                            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "LanguageSelectionViewController") as! LanguageSelectionViewController
                           self.navigationController?.pushViewController(VC1, animated: true)
                            
                        }
                    }
                }
                
                HUD.hide()
            case .failure(let error):
                print(error)
                HUD.hide()
                
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

          if L102Language.currentAppleLanguage() == "ar" {
            lbl.text = "جاري مراجعة حسابك"
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
