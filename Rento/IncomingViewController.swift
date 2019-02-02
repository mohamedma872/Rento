//
//  IncomingViewController.swift
//  Rento
//
//  Created by mouhammed ali on 9/4/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import PKHUD
import Alamofire
class IncomingCell:UITableViewCell{
    var ButtonHandler:(()-> Void)!
    
    @IBAction func ButtonClicked(_ sender: UIButton) {
        self.ButtonHandler()
    }
}
class IncomingViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var token = ""
    
    @IBOutlet var resrvationsTable: UITableView!
    var arr=[[String:AnyObject]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("INCOMING ORDERS", comment: "")
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            token = userDict["token"] as! String
        }
        setupNavBar()
        getReservations()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getReservations(){
        HUD.show(.progress)
        let headers = ["Accept": "application/json",
                       "Authorization" : "Bearer \(token)"]
        print(headers)
        Alamofire.request("http://myrentoapp.com/api/incoming_reservations", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                
                //print(value)
                if let resResponse = value as? [String:AnyObject]{
                    if let resDict = resResponse["reservations"] as? [String:AnyObject] {
                    if let resArr = resDict["data"] as? [[String:AnyObject]] {
                        print(resArr)
                        self.arr = resArr
                        
                        self.resrvationsTable.reloadData()
                    }
                    if let message = resDict["message"] as? String{
                        self.view.makeToast(message)
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingCell", for: indexPath) as! IncomingCell
        let item = arr[indexPath.row]
        print(item)
        let statusLbl = cell.viewWithTag(100) as! UIButton
        
        let boydLbl = cell.viewWithTag(2) as! UILabel
        boydLbl.text = item["username"] as! String
        let dateLbl = cell.viewWithTag(3) as! UILabel
        dateLbl.text = "\(NSLocalizedString("From", comment: "")) :\(item["start"]!) - \(NSLocalizedString("To", comment: "")) :\(item["end"]!)"
        let titleLbl = cell.viewWithTag(1) as! UILabel
        titleLbl.text = item["car"] as! String
        if L102Language.currentAppleLanguage() == "ar" {
            (cell.viewWithTag(6) as! UIButton).setImage(UIImage(named:"callAr"), for: .normal)
        }
        if let status = item["status"] as? String {
            print(status)
            statusLbl.setTitle(status, for: .normal)
            if status == "pendding" {
                
                cell.viewWithTag(6)?.isHidden = true
            }
            
            if status == "received" {
                
                cell.viewWithTag(6)?.isHidden = false
            }
            
            
            
        }
        let loc = cell.viewWithTag(4) as! UILabel
        loc.text = item["city"] as! String
        cell.ButtonHandler = {()-> Void in
            if let phoneNumber = item["phone"] as? String {
                if let url = URL(string:phoneNumber) {
                    print(url)
                UIApplication.shared.openURL(url)
                }
            }
        }
        return cell
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
