//
//  CarsTableViewController.swift
//  Rento
//
//  Created by mouhammed ali on 8/21/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Alamofire
import SDWebImage
import PKHUD
import GearRefreshControl
class CarsTableViewController: UIViewController,IndicatorInfoProvider , UITableViewDelegate, UITableViewDataSource{
    var carsArr = [[String:AnyObject]]()
    var user = [String:AnyObject]()
    var lang = ""
    var currency = ""
    var search = 0
    var searchUrl = ""
    var myCars = 0
    var featured = 0
    var logout = 0
    var gearRefreshControl: GearRefreshControl!
    var alreadyShown = 0
    var MyFav = 0
    var token = ""
    var countryId = 0
    
    @IBOutlet weak var carsTable: UITableView!
    override func viewDidLoad() {
        navigationController?.hidesBarsWhenKeyboardAppears = false
       
        if search == 1 {
            self.title = NSLocalizedString("SEARCH RESULTS", comment: "")
            
            
        }
        if MyFav == 1 {
            
            self.title = NSLocalizedString("FAVORITES", comment: "")
            
            
        }
        if myCars == 1 {
            self.title = NSLocalizedString("MY CARS", comment: "")
        }
        
        
        setupNavBar()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadView(_:)), name: NSNotification.Name(rawValue: "reloadCarsView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.logOut(_:)), name: NSNotification.Name(rawValue: "logout"), object: nil)
        
        super.viewDidLoad()
        gearRefreshControl = GearRefreshControl(frame: self.view.bounds)
        gearRefreshControl.gearTintColor = UIColor.lightGray
        gearRefreshControl?.addTarget(self, action: #selector(CarsTableViewController.refresh), for: UIControlEvents.valueChanged)
        carsTable.refreshControl = gearRefreshControl
        if let data = UserDefaults.standard.object(forKey: "selectedCountry") as? NSData{
            if let currencyDict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:AnyObject] {
                
                countryId = currencyDict["country_id"] as! Int
                currency = currencyDict["currency"] as! String
                UserDefaults.standard.set("\(NSLocalizedString("\(currencyDict["currency"]!)", comment: ""))", forKey: "currentCurrency")
            }
        }
        if let langString = UserDefaults.standard.object(forKey: "language") as? String {
            lang = langString
        }
        
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            token = userDict["token"] as! String
            user = userDict
            getCars(forceReload: 0, hideHud: 0)
            
            
        }else{
            
            if skipped == 0 {
            if UserDefaults.standard.integer(forKey:"openedBefoure") == 0 {
                
                let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "LanguageSelectionViewController") as! LanguageSelectionViewController
                let navController = UINavigationController(rootViewController: VC1) // Creating a navigation controller with VC1 at the root of the navigation stack.
                self.present(navController, animated:true, completion: nil)
            }else{
                let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "SignUpOrLoginViewController")
                let navController = UINavigationController(rootViewController: VC1)
                
                self.present(navController, animated:true, completion: nil)
            }
            }
        }
        // }
        
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        if featured == 1{
            return IndicatorInfo(title: NSLocalizedString("POPULAR", comment: ""))
        }
        return IndicatorInfo(title:  NSLocalizedString("RECENT", comment: ""))
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carsArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "carsCell")
        if indexPath.row<carsArr.count {
            var index = indexPath.row
            if myCars == 1 {
                index = (carsArr.count - 1) - indexPath.row
            }
            let item = carsArr[index]
            let image = cell?.viewWithTag(1) as! UIImageView
            let carMake = cell?.viewWithTag(2) as! UILabel
            let carType = cell?.viewWithTag(3) as! UILabel
            let carModel = cell?.viewWithTag(4) as! UILabel
            let userName = cell?.viewWithTag(5) as! UILabel
            let userAd = cell?.viewWithTag(6) as! UILabel
            let location = cell?.viewWithTag(7) as! UILabel
            let numberOfDoors = cell?.viewWithTag(8) as! UILabel
            let gearType = cell?.viewWithTag(9) as! UILabel
            let price = cell?.viewWithTag(10) as! UILabel
            let userAvatar = cell?.viewWithTag(12) as! UIImageView
            
            
            carMake.text = "\(item["name"]!)"
            if let typeDict = item["type"] as? [String:AnyObject]{
                carType.text = "\(typeDict["name"]!)"}
            if let modelDict = item["car_model"] as? [String:AnyObject]{
                carModel.text = "\(modelDict["name"]!)"}
            if let countryDict = item["country"] as? [String:AnyObject]{
                location.text = "\(countryDict["name"]!)"}
            
            numberOfDoors.text = "\(item["doors"]!) \(NSLocalizedString("Doors", comment: ""))"
            gearType.text = "\(item["gear"]!)"
            price.text = "\(item["price"]!) \(UserDefaults.standard.object(forKey: "currentCurrency")!)"
            if let userDict = item["user"] as? [String:AnyObject]{
                userName.text = "\(userDict["name"]!)"
                if let carCountry = item["country"] {
                    
                    userAd.text = carCountry["name"] as! String
                    
                }
                if let carCity = item["city"] {
                    let str = carCity["name"] as! String
                    userAd.text = "\(userAd.text!), \(str)"
                    
                }
                if let av = userDict["avatar"] as? String {
                    userAvatar.sd_setImage(with: URL(string:av), completed: nil)
                }
            }
            image.sd_setImage(with: URL(string:"\(item["photo"]!)"), completed: nil)
            return cell!}
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if myCars == 1 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "AddCarViewController") as! AddCarViewController
            vc.item = carsArr[(carsArr.count - 1) - indexPath.row]
            vc.edit = 1
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            let vc = storyboard?.instantiateViewController(withIdentifier: "CarViewController") as! CarViewController
            vc.item = carsArr[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func getCars(forceReload:Int, hideHud:Int){
        var flag = 0
        self.carsArr.removeAll()
        let par = ["country_id":self.countryId]
        if hideHud == 0 {
            
            HUD.show(.progress, onView: self.view)
        }
        var headers = ["Accept": "application/json"
            ,
                       "Authorization" : "Bearer \(token)"]
        
        
        var url = "http://myrentoapp.com/api/cars?language=\(lang)"
        if featured == 1 {
            url = "http://myrentoapp.com/api/featured-cars?language=\(lang)"
        }
        if search == 1 {
            
            url = searchUrl
        }
        if MyFav == 1 {
            
            
            url = "http://myrentoapp.com/api/favorite"
        }
        if myCars == 1 {
            
            
            url = "http://myrentoapp.com/api/my-cars"
        }
        
        
        
        // HUD.show(.progress)
        if MyFav == 0 {
            if myCars == 0 {
                
                if let data = UserDefaults.standard.object(forKey: url) as? NSData{
                    if let dict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:AnyObject] {
                        if forceReload == 0 {
                            
                            var sustring = "cars"
                            if self.myCars == 1 {
                                sustring = "my_cars"
                                
                            }
                            if self.MyFav == 1  {
                                sustring = "favorite"
                            }
                            if let carsDict = dict[sustring]{
                                
                                
                                if let array = carsDict["data"] as? [[String : AnyObject]]{
                                    
                                    
                                    
                                    
                                    print(array)
                                    if array.count>0{
                                        let item = array[0]
                                        if let modelDict = item["car_model"] as? [String:AnyObject]{
                                            if "\(modelDict["name"]!)" == "<null>" {
                                                flag = 0
                                            }else{
                                                if search == 1 {
                                                    flag = 1
                                                }
                                                self.carsArr = array
                                                self.carsTable.reloadData()
                                            }
                                            
                                        }
                                        
                                        
                                    }
                                    
                                }
                                HUD.hide()
                                self.gearRefreshControl?.endRefreshing()
                                
                            }
                        }}
                }
            }
        }
        if search == 1 {
            HUD.show(.progress, onView: self.view)
        }
        Alamofire.request(url, method: .get, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                
                
                print(value)
                
                
                if let dict = value as? [String:AnyObject]{
                    
                    
                    
                    
                    if flag == 0 || self.MyFav == 1 || self.myCars == 1
                    {
                        
                        var sustring = "cars"
                        if self.myCars == 1 {
                            sustring = "my_cars"
                            
                        }
                        if self.MyFav == 1  {
                            sustring = "favorite"
                        }
                        if let carsDict = dict[sustring]{
                            
                            
                            if let array = carsDict["data"] as? [[String : AnyObject]]{
                                
                                
                                
                                self.carsArr = array
                                
                                self.carsTable.reloadData()
                            }
                            if self.carsArr.count == 0 && self.search == 1 &&  self.alreadyShown == 0 {
                                self.view.makeToast(NSLocalizedString("No Matching Cars Were Found", comment: ""))
                                self.alreadyShown = 1
                            }
                            HUD.hide()
                            self.gearRefreshControl?.endRefreshing()
                            
                        }
                    }

                    
                    let dat = NSKeyedArchiver.archivedData(withRootObject: dict)
                    
                    UserDefaults.standard.set(dat, forKey: url)
                    
                }
                
                
                HUD.hide()
            case .failure(let error):
                print(error)
                HUD.hide()
                self.gearRefreshControl?.endRefreshing()
            }
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            token = userDict["token"] as! String
            user = userDict
           getCars(forceReload: 0, hideHud: 0)
        }

    }
    func logOut(_ notification: NSNotification) {
        
        
        
        
        HUD.show(.progress, onView: self.view)
        let headers = ["Accept": "application/json"]
        
        let par = ["one_signal_player_id":UserDefaults.standard.string(forKey: "onesignalid")!
        ]
        Alamofire.request("http://myrentoapp.com/api/logout", method: .get, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                
                if let resResponse = value as? [String:AnyObject]{
                    if let doneMessage = resResponse["message"] as? String{
                        if doneMessage == "done" {
                            
                            UserDefaults.standard.removeObject(forKey: "user")
                            
                            
                            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "SignUpOrLoginViewController")
                            let navController = UINavigationController(rootViewController: VC1)
                            
                            self.present(navController, animated:true, completion: nil)
                            
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
    func refresh(){
        getCars(forceReload:1, hideHud:1)
    }
    func reloadView(_ notification: NSNotification) {
        

        if let langString = UserDefaults.standard.object(forKey: "language") as? String {
            lang = langString
        }
        
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            token = userDict["token"] as! String
            user = userDict
            getCarsWithLangChange()
            
        }
        if skipped == 1 {
             getCars(forceReload:1, hideHud:0)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        gearRefreshControl.scrollViewDidScroll(scrollView)
    }
    func getCarsWithLangChange(){
        HUD.show(.progress)
        let headers = ["Accept": "application/json",
                       "Authorization" : "Bearer \(token)"]
        
        
        Alamofire.request("http://myrentoapp.com/api/locale/\(L102Language.currentAppleLanguage())", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                HUD.show(.progress)
                let par = ["Accept" : "application/json"]
                Alamofire.request("http://myrentoapp.com/api/countries?language=\(L102Language.currentAppleLanguage())", method: .get, parameters: nil, encoding: URLEncoding.default, headers: par).responseJSON { (response:DataResponse) in
                    switch(response.result) {
                        
                        
                    case .success(let value):
                        print(value)
                        
                        
                        if let dict = value as? [String:AnyObject]{
                            
                            let datt = NSKeyedArchiver.archivedData(withRootObject: dict)
                            UserDefaults.standard.set(datt, forKey: "countries\(L102Language.currentAppleLanguage())")
                            
                            
                            if let array = dict["countries"] as? [[String : AnyObject]]{
                               
                                let dat = NSKeyedArchiver.archivedData(withRootObject: array[UserDefaults.standard.integer(forKey: "selectedCountryIndex")])
                                UserDefaults.standard.set(dat, forKey: "selectedCountry")
                                
                            
                           
                            if let data = UserDefaults.standard.object(forKey: "selectedCountry") as? NSData{
                                if let currencyDict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:AnyObject] {
                                    
                                    self.countryId = currencyDict["country_id"] as! Int
                                    self.currency = currencyDict["currency"] as! String
                                    print("currrrr\(self.currency)")
                                    UserDefaults.standard.set("\(currencyDict["currency"]!)", forKey: "currentCurrency")
                                        self.getCars(forceReload: 1, hideHud: 0)
                                 //   }
                                    
                                    //
                                    
                                }
                            }
                            }
                            
                            
                            
                        }
                        
                        
                        HUD.hide()
                    case .failure(let error):
                        print(error)
                        HUD.hide()
                    }
                }
                HUD.hide()
            case .failure(let error):
                print(error)
                HUD.show(.progress)
                let par = ["Accept" : "application/json"]
                Alamofire.request("http://myrentoapp.com/api/countries?language=\(L102Language.currentAppleLanguage())", method: .get, parameters: nil, encoding: URLEncoding.default, headers: par).responseJSON { (response:DataResponse) in
                    switch(response.result) {
                        
                        
                    case .success(let value):
                        print(value)
                        
                        
                        if let dict = value as? [String:AnyObject]{
                            
                            
                            
                            
                   if let array = dict["countries"] as? [[String : AnyObject]]{
                    let datt = NSKeyedArchiver.archivedData(withRootObject: dict)
                    UserDefaults.standard.set(datt, forKey: "countries\(L102Language.currentAppleLanguage())")
                                    let dat = NSKeyedArchiver.archivedData(withRootObject: array[UserDefaults.standard.integer(forKey: "selectedCountryIndex")])
                                    UserDefaults.standard.set(dat, forKey: "selectedCountry")
                                    
                            }
                                HUD.hide()
                      
                            if let data = UserDefaults.standard.object(forKey: "selectedCountry") as? NSData{
                                if let currencyDict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:AnyObject] {
                                    
                                    self.countryId = currencyDict["country_id"] as! Int
                                    self.currency = currencyDict["currency"] as! String
                                    UserDefaults.standard.set("\(currencyDict["currency"]!)", forKey: "currentCurrency")
                                }
                            }
                            
                            self.getCars(forceReload:1, hideHud: 0)
                           
                            
                            
                        }
                        
                        
                     HUD.hide()
                    case .failure(let error):
                        print(error)
                         HUD.hide()
                    }
                }
           
                
                
                
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
