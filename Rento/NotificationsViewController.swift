//
//  NotificationsViewController.swift
//  Rento
//
//  Created by mouhammed ali on 8/26/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import PKHUD
import Alamofire
import SDWebImage

class NotificationsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    var token = ""

    @IBOutlet var notificationTable: UITableView!
    var arr = [[String:AnyObject]]()
    override func viewDidLoad() {
        self.title = NSLocalizedString("NOTIFICATIONS", comment: "")
        super.viewDidLoad()
        UserDefaults.standard.set(0, forKey: "notifNumber")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateBadge"), object: nil, userInfo: nil)
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            token = userDict["token"] as! String
        }

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false

        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3
        self.navigationController?.navigationBar.layer.masksToBounds = false
        setupNavBar()
        getNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)
        let item = arr[indexPath.row]
        
        let image = cell.viewWithTag(1) as! UIImageView
        image.sd_setImage(with: URL(string:item["image"] as! String), completed: nil)
        let boydLbl = cell.viewWithTag(-2) as! UILabel
        boydLbl.text = item["body"] as! String
        let dateLbl = cell.viewWithTag(-4) as! UILabel

        dateLbl.text = item["created_at_diff"] as! String
        let titleLbl = cell.viewWithTag(-3) as! UILabel
        titleLbl.text = item["subject"] as! String
        if L102Language.currentAppleLanguage() == "en" {
            dateLbl.textAlignment = .right
            titleLbl.textAlignment = .left
            boydLbl.textAlignment = .left
        }
        else{
            dateLbl.textAlignment = .left
            titleLbl.textAlignment = .right
            boydLbl.textAlignment = .right
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arr[indexPath.row]
        var dictToSend = [String:AnyObject]()
        if let dict = item["data"] as? [String:AnyObject] {
            dictToSend = dict
        }
        print(dictToSend)
        if let type = item["type"] as? String {
            if type == "rate" {
                let vc = storyboard?.instantiateViewController(withIdentifier: "RatingViewController") as! RatingViewController
                vc.userInfo = dictToSend
                self.present(vc, animated: true, completion: nil)
            }
            else if type == "reservation_added" {
                let vc = storyboard?.instantiateViewController(withIdentifier: "RentPromptViewController") as! RentPromptViewController
                vc.userInfo = dictToSend
                self.present(vc, animated: true, completion: nil)
            }else if type == "reservation_deleted" {
                let vc = storyboard?.instantiateViewController(withIdentifier: "RefusalViewController") as! RefusalViewController
                self.present(vc, animated:true, completion: nil)
            }
            else if type == "reservation_approved" {
                let vc = storyboard?.instantiateViewController(withIdentifier: "SentViewController") as! SentViewController
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            else{
                //self.view.makeToast("Action Has Been Taken Before")
            }
        }
        
    }
    
    
    func getNotifications(){
        
        HUD.show(.progress, onView: self.view)
        let headers = ["Accept": "application/json",
                       "Authorization" : "Bearer \(token)"]
        print(headers)
        Alamofire.request("http://myrentoapp.com/api/notifications", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                
               print(value)
                if let resDict = value as? [String:AnyObject]{
                    
                    if let resArr = resDict["notifications"] as? [[String:AnyObject]] {
                        
                        self.arr = resArr
                        
                        self.notificationTable.reloadData()
                    }
                    if let message = resDict["message"] as? String{
                        self.view.makeToast(message)
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
