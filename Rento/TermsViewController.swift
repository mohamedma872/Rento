//
//  TermsViewController.swift
//  Rento
//
//  Created by mouhammed ali on 11/24/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
//info
import Alamofire
import PKHUD

class TermsViewController: UIViewController {
    
    @IBOutlet var termsText: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("CONDITIONS", comment: "")
        getTerms()
        setupNavigatioBar()
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func getTerms(){
        let headers = ["Accept": "application/json"]
        if let str = UserDefaults.standard.string(forKey: "terms") {
        termsText.text = "\(str)"
        }
        Alamofire.request("http://myrentoapp.com/api/info", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                
                
                print(value)
                if let dict = value as? [String:AnyObject] {
                    if let appDict = dict["app"] as? [String:AnyObject]{
                        let str = "\(appDict["terms-conditions"]!)"
                        self.termsText.text = str
                        UserDefaults.standard.set(str, forKey: "terms")
                    }
                }

                
            case .failure(let error):
                print(error)
                
            }
        }
        
        
        
        
    }
    func setupNavigatioBar(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.title = ""
        
    }

}
