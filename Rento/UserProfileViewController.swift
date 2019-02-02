//
//  UserProfileViewController.swift
//  Rento
//
//  Created by mouhammed ali on 8/25/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import Font_Awesome_Swift
class UserProfileViewController: UIViewController {
    var lang = ""
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var country: UILabel!
    @IBOutlet var balance: UILabel!
    @IBOutlet var frozenBalance: UILabel!
    var cityDict = [String:AnyObject]()
    
    @IBOutlet var blanceLbl: UILabel!
    @IBOutlet var frozenLbl: UILabel!
    @IBAction func withdrawBalance(_ sender: Any) {
    }

    @IBAction func editInfo(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        vc.edit = 1
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBOutlet var updateInfoButt: UIButton!
    @IBOutlet var rechargeButt: UIButton!
    @IBOutlet var mycarsButt: UIButton!
    @IBOutlet var favButt: UIButton!
    @IBOutlet var incomingButt: UIButton!
    @IBOutlet var sentButt: UIButton!
    
    
    
    @IBAction func myCars(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CarsTableViewController") as! CarsTableViewController
        vc.myCars = 1
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func incomingOrder(_ sender: Any) {
    }
    
    @IBAction func recharge(_ sender: Any) {
    }
    
    @IBAction func myFav(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CarsTableViewController") as! CarsTableViewController
        vc.featured = 1
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func sentOrders(_ sender: Any) {
    }
    override func viewDidLoad() {
        setupNavBar()
        super.viewDidLoad()
         self.title = NSLocalizedString("PROFILE", comment: "")
        
        if L102Language.currentAppleLanguage() == "ar" {
//            frozenLbl.textAlignment = .left
//            blanceLbl.textAlignment = .left
            updateInfoButt.setImage(UIImage(named:"editAr")!, for: .normal)
            rechargeButt.setImage(UIImage(named:"rechargeAr")!, for: .normal)
            mycarsButt.setImage(UIImage(named:"myCarsAr")!, for: .normal)
            favButt.setImage(UIImage(named:"favCarsAr")!, for: .normal)
            incomingButt.setImage(UIImage(named:"receivedOrdresAr")!, for: .normal)
            sentButt.setImage(UIImage(named:"sentOrdersAr")!, for: .normal)
        }else{
//            frozenLbl.textAlignment = .left
//            blanceLbl.textAlignment = .left
        }
        
        
        if let langString = UserDefaults.standard.object(forKey: "language") as? String {
            lang = langString
        }
        if let user = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            print(user)
            name.text = "\(user["name"]!)"
            userImage.sd_setImage(with: URL(string:"\(user["avatar"]!)"), completed: nil)
            balance.text = "\(user["balance"]!)"
            frozenBalance.text = "\(user["frozen_balance"]!)"
          //  getCity(id: "\(user["city_id"]!)")
            
            
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if let user = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            print(user)
            name.text = "\(user["name"]!)"
            userImage.sd_setImage(with: URL(string:"\(user["avatar"]!)"), completed: nil)
            balance.text = "\(user["balance"]!)"
            frozenBalance.text = "\(user["frozen_balance"]!)"
            //getCity(id: "\(user["city_id"]!)")
            country.setFAText(prefixText: "", icon: .FAEnvelope , postfixText: "   \(user["email"]!)", size: 17, iconSize: 20)
            //email
            
        }
        if L102Language.currentAppleLanguage() == "ar" {
                        frozenLbl.textAlignment = .left
                        blanceLbl.textAlignment = .left
        }else{
            frozenLbl.textAlignment = .right
            blanceLbl.textAlignment = .right
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCity(id:String){
        var flag = 0
        if let data = UserDefaults.standard.object(forKey: "city\(id)\(lang)") as? NSData{
             if let dict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:AnyObject] {
            if let array = dict["city"] as? [[String : AnyObject]]{
                flag = 1
                
            }
            }}
        
            Alamofire.request("http://myrentoapp.com/api/cities/\(id)?language=\(lang)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
                switch(response.result) {
                    
                    
                case .success(let value):
                    if flag == 0
                    {
                        if let dict = value as? [String:AnyObject]{
                            if let city = dict["city"] as? [String:AnyObject]{
                            
                            self.cityDict = city
                            self.country.text = "\(city["name"]!)"
                        
                        }
                        }}
                        
                            else{
                                
                                
                    }
                
                            let dat = NSKeyedArchiver.archivedData(withRootObject: self.cityDict)
                            UserDefaults.standard.set(dat, forKey: "city\(id)\(self.lang)")
                            
                    
                        case .failure(let error):
                        print(error)
                    
                        // HUD.hide()
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
