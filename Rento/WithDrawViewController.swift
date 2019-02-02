//
//  WithDrawViewController.swift
//  Rento
//
//  Created by mouhammed ali on 9/5/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
class WithDrawViewController: UIViewController {
    
    
    @IBOutlet var withdrawLblImage: UIImageView!
    
    @IBOutlet var fieldBackground: UIImageView!
    @IBAction func withdrawButt(_ sender: Any) {
        withdraw()
    }
    var token = ""
    @IBOutlet var amountField: UITextField!
    override func viewDidLoad() {
        setupNavBar()
        super.viewDidLoad()
        self.title = NSLocalizedString("WITHDRAW", comment: "")
        if L102Language.currentAppleLanguage() == "ar" {
            fieldBackground.image = UIImage(named:"withdrawAr")
            withdrawLblImage.image = UIImage(named:"rechargeLabelAr")
        
        }
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            token = userDict["token"] as! String
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func withdraw(){
        HUD.show(.progress)
        let headers = ["Accept": "application/json",
                       "Authorization" : "Bearer \(token)"]

        let par = ["type":"withdrawal",
                   "balance":amountField.text!,
                   ]
        Alamofire.request("http://myrentoapp.com/api/users/balance/recharge", method: .post, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                if let resResponse = value as? [String:AnyObject]{
                    
                    
                    if let message = resResponse["message"] as? String{
                        self.view.makeToast(message)
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RefusalViewController") as! RefusalViewController
                        vc.withrraw = 1
                        self.present(vc, animated: true, completion: nil)
                    }
                }
                
                HUD.hide()
            case .failure(let error):
                print(error)
                HUD.hide()
                
            }
        }
        
        
    }
    func setupNavBar(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }

}
