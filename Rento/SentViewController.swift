//
//  SentViewController.swift
//  Rento
//
//  Created by mouhammed ali on 9/4/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//


import UIKit
import PKHUD
import Alamofire
class SentCell:UITableViewCell{
    var ButtonHandler:(()-> Void)!
    var ButtonHandler2:(()-> Void)!
    var cancelHandler:(()-> Void)!
    @IBAction func ButtonClicked(_ sender: UIButton) {
        self.ButtonHandler()
    }
    @IBAction func ButtonClicked2(_ sender: UIButton) {
        self.ButtonHandler2()
    }
    @IBAction func cancelClicked(_ sender: UIButton) {
        self.cancelHandler()
    }
    @IBOutlet var cancelButt: UIButton!
    
}
class SentViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var token = ""
    
    @IBOutlet var sentTable: UITableView!
    var arr=[[String:AnyObject]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            token = userDict["token"] as! String
        }
        self.title = NSLocalizedString("SENT ORDERS", comment: "")
        setupNavBar()
        getSent()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getSent(){
        
        HUD.show(.progress, onView: self.view)
        let headers = ["Accept": "application/json",
                       "Authorization" : "Bearer \(token)"]
        print(headers)
        Alamofire.request("http://myrentoapp.com/api/reservations", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                
                print(value)
                if let resResponse = value as? [String:AnyObject]{
                    if let resDict = resResponse["reservations"] as? [String:AnyObject] {
                        if let resArr = resDict["data"] as? [[String:AnyObject]] {
                            print(resArr)
                            self.arr = resArr
                            
                            self.sentTable.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SentCell", for: indexPath) as! SentCell
        let item = arr[indexPath.row]
        
       // let image = cell.viewWithTag(5) as! UIImageView
        
        let boydLbl = cell.viewWithTag(2) as! UILabel
        boydLbl.text = ""
        let startDateLbl = cell.viewWithTag(3) as! UILabel
        let endDateLbl = cell.viewWithTag(30) as! UILabel
        startDateLbl.text = "\(item["start"]!)\n\(item["start_time"]!)"
        endDateLbl.text = "\(item["end"]!)\n\(item["end_time"]!)"
        let titleLbl = cell.viewWithTag(1) as! UILabel
        titleLbl.text = item["car"] as! String
        let statusLbl = cell.viewWithTag(100) as! UIButton
        let loc = cell.viewWithTag(4) as! UILabel
        loc.text = item["city"] as! String
        statusLbl.contentHorizontalAlignment = .center
        if L102Language.currentAppleLanguage() == "ar" {
            (cell.viewWithTag(6) as! UIButton).setImage(UIImage(named:"callAr"), for: .normal)
            (cell.viewWithTag(7) as! UIButton).setImage(UIImage(named:"findonmapar"), for: .normal)
            
        }
        if let status = item["status"] as? String {
            statusLbl.setTitle(status, for: .normal)
            
            
            print(status)
            if status == "Pending" {
                
                
                cell.viewWithTag(6)?.isHidden = true
                cell.viewWithTag(7)?.isHidden = true
            }
            if status == "Recived" {
                
                cell.viewWithTag(6)?.isHidden = false
                cell.viewWithTag(7)?.isHidden = false
            }
            if status == "Recived" {
                
                cell.viewWithTag(6)?.isHidden = false
                cell.viewWithTag(7)?.isHidden = false
            }

            if status == "deleted" || status == "Reservation Deleted" || status == "تم الحذف"   {
                
                statusLbl.setBackgroundImage(UIImage(named:"redGrad"), for: .normal)
                cell.viewWithTag(6)?.isHidden = true
                cell.viewWithTag(7)?.isHidden = true
            }else{
                
                statusLbl.setBackgroundImage(UIImage(named:"blue button"), for: .normal)
            }
            
            if status == "Reservation Deleted" {
                
                cell.viewWithTag(6)?.isHidden = true
                cell.viewWithTag(7)?.isHidden = true
            }
        
            
        }
        if let enableToCancel = item["enable_to_cancel"] as? Bool {
            cell.cancelButt.isHidden = !enableToCancel
        }
        cell.ButtonHandler = {()-> Void in
            if let phoneNumber = item["phone"] as? String {
                
                if let url = URL(string:phoneNumber) {
                    print(url)
                    UIApplication.shared.openURL(url)
                }
            }
        }
        cell.ButtonHandler2 = {()-> Void in
            
            UIApplication.shared.openURL(NSURL(string:"http://maps.apple.com/?ll=\(item["map_lat"]!),\(item["map_lng"]!)")! as URL)
        }
        cell.cancelHandler = {()-> Void in
            self.cancelReservation(id:"\(item["reservation_id"]!)")
        }
        
        
        
        
        return cell
    }
    
    
    
    func cancelReservation(id:String){
        HUD.show(.progress)
        let headers = ["Accept": "application/json",
                       "Authorization" : "Bearer \(token)"]
        
        print(headers)
        Alamofire.request("http://myrentoapp.com/api/reservations/\(id)/cancel", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                
                print(value)
                if let resResponse = value as? [String:AnyObject]{
                    if let er = resResponse["errors"] as? String{
                        self.view.makeToast(er)
                    }
                    if let msg = resResponse["message"] as? String{
                        self.view.makeToast(msg)
                        self.getSent()
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
