//
//  LanguageSelectionViewController.swift
//  Rento
//
//  Created by mouhammed ali on 8/15/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import DropDown
import Toast_Swift
import Alamofire
import PKHUD
class LanguageSelectionViewController: UIViewController {
    let dropdown = DropDown()
    var selected = 0
    var options = 0
    var langFlag = 0
    var currentLang = ""
    var selectLang = ""
    
     var token = ""
    @IBOutlet weak var langButt: UIButton!
    @IBAction func selectLanguagePressed(_ sender: Any) {
        
        dropdown.direction = .bottom
        dropdown.anchorView = langButt
        dropdown.dataSource = ["English", "عربي"]
        dropdown.width = langButt.frame.width
        dropdown.contentMode = .center
        dropdown.bottomOffset = CGPoint(x:0,y:self.langButt.frame.height+1)
        dropdown.show()
        dropdown.selectionAction = {[unowned self](index: Int, item: String) in
            self.langButt.setTitle(item, for: .normal)
            
        }
    }
    @IBAction func nextButt(_ sender: Any) {
        print(langButt.currentTitle)
        
        
        if langButt.currentTitle == "English" {
            selectLang = "en"
        }else{
            selectLang = "ar"
        }
        if let lang = UserDefaults.standard.string(forKey: "language") {
            currentLang = lang
        }else{
            currentLang = selectLang
        }
        if options == 1 {
            changeLanguage()
          
        }
        else{
            if langButt.currentTitle == "English" {
                selectLang = "en"
            }else{
                selectLang = "ar"
            }
            
            if let lang = UserDefaults.standard.string(forKey: "language") {
                currentLang = lang
            }else{
                
                currentLang = "en"
            }
            UserDefaults.standard.set(selectLang, forKey: "language")
            if self.currentLang != self.selectLang {
                
                UserDefaults.standard.set(1, forKey: "changeLangFlagImmed")
                //rootLanguageSelectionViewController
                changeLanguage(root:"rootLanguageSelectionViewController")
            }else{
                let vc = storyboard?.instantiateViewController(withIdentifier: "CountrySelectionViewController")
                self.navigationController?.pushViewController(vc!, animated: true)
            }
           
     
        }
    }
    @IBOutlet var nextButtOut: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.integer(forKey: "changeLangFlagImmed") == 1 {
             UserDefaults.standard.set(0, forKey: "changeLangFlagImmed")
            let vc = storyboard?.instantiateViewController(withIdentifier: "CountrySelectionViewController")
            self.navigationController?.pushViewController(vc!, animated: true)
            
        }
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            
            token = userDict["token"] as! String
        }
        
        if options == 1 {
            nextButtOut.setTitle(NSLocalizedString("Done", comment: ""),for: .normal)
        }
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeLanguage(){
        
        HUD.show(.progress)
        let headers = ["Accept": "application/json",
            "Authorization" : "Bearer \(token)"]
        
  
        Alamofire.request("http://myrentoapp.com/api/locale/\(selectLang)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                var time = 0
                if let resResponse = value as? [String:AnyObject]{
                    if let er = resResponse["error"] as? String{
                        self.view.makeToast(er)
                    }
                    else{
                        if self.currentLang != self.selectLang {
                            UserDefaults.standard.set(1, forKey: "changeLangFlag")
                            time = 1
                        }
                        UserDefaults.standard.set(self.selectLang, forKey: "language")
                        self.dismiss(animated: true, completion: {
                            print("innnn")
                            let when = DispatchTime.now() + .seconds(time) // change 2 to desired number of seconds
                            DispatchQueue.main.asyncAfter(deadline: when) {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCarsView"), object: nil, userInfo: nil)
                            }
                            
                        })
                    }
                }
                
                
                HUD.hide()
            case .failure(let error):
                print(error)
                HUD.hide()
              //  self.view.makeToast(error.localizedDescription)
            }
        }
        
    }
    
    func changeLanguage(root:String){
        if L102Language.currentAppleLanguage() == "en" {
            L102Language.setAppleLAnguageTo(lang: "ar")
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            L102Language.setAppleLAnguageTo(lang: "en")
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        };
        
        let rootviewcontroller: UIWindow = ((UIApplication.shared.delegate?.window)!)!
        rootviewcontroller.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: root)
        let mainwindow = (UIApplication.shared.delegate?.window!)!
        mainwindow.backgroundColor = UIColor(hue: 0.6477, saturation: 0.6314, brightness: 0.6077, alpha: 0.8)
        UIView.transition(with: mainwindow, duration: 0.55001, options: .transitionFlipFromLeft, animations: { () -> Void in
        }) { (finished) -> Void in
        }
        
    }

    

}
