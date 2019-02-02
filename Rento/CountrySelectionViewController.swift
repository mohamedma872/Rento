
//
//  CountrySelectionViewController.swift
//  Rento
//
//  Created by mouhammed ali on 8/16/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import Toast_Swift

class CountrySelectionViewController: UIViewController {
    var options = 0
    var selectedLang = ""
    @IBOutlet var getStartedButt: UIButton!
    @IBAction func getStarted(_ sender: Any) {
        
        if let data = UserDefaults.standard.object(forKey: "selectedCountry") as? NSData{
            if let _ = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:AnyObject] {
                
                
                if let _ = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
                    
                    
                    self.dismiss(animated: true, completion: {
                        print("innnn")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCarsView"), object: nil, userInfo: nil)
                    })
                    
                    
                }else{
                    
                    self.navigationController?.pushViewController((storyboard?.instantiateViewController(withIdentifier: "SignUpOrLoginViewController"))!, animated: true)
                }
            }}else{
            self.view.makeToast("Please select country first")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        if options == 1 {
            getStartedButt.setTitle(NSLocalizedString("Done", comment: "") ,for: .normal)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
