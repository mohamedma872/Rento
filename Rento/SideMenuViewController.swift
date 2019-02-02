//
//  SideMenuViewController.swift
//  Rento
//
//  Created by mouhammed ali on 8/24/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var sideTable: UITableView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var userLocation: UILabel!
    let arr =  ["Home","Profile", "My Cars", "Add Car", "Notifications", "My Favorites", "Sent Orders", "Incoming Orders","Contact Us", "More" ,"Logout" ]
    
    override func viewDidAppear(_ animated: Bool) {
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            print(userDict)
            userImage.sd_setImage(with: URL(string:"\(userDict["avatar"]!)"), completed: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        sideTable.tableHeaderView = headerView
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            print(userDict)
            userImage.sd_setImage(with: URL(string:"\(userDict["avatar"]!)"), completed: nil)
            userName.text = "\(userDict["name"]!)"
            
            if let data = UserDefaults.standard.object(forKey: "selectedCountry") as? NSData{
                if let countryDict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:AnyObject] {
                print(countryDict)
                userLocation.text = "\(countryDict["name"]!)"
                }
            }
            
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sideCell")
        let label = cell?.viewWithTag(1) as! UILabel
        let img = cell?.viewWithTag(2) as! UIImageView
        img.image = UIImage(named:"\(indexPath.row)")
        label.text = NSLocalizedString(arr[indexPath.row], comment: "") 
        return cell!
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        switch arr[indexPath.row] {
        case "Home":
            self.navigationController?.popToRootViewController(animated: false)
            self.dismiss(animated: true, completion: nil)
            let vc = storyboard?.instantiateViewController(withIdentifier: "SegmentedViewController") as! SegmentedViewController
            self.navigationController?.pushViewController(vc, animated: true)
            
            
        case "Profile":
            let vc = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
            self.navigationController?.pushViewController(vc, animated: true)
            
        case "My Cars":
            let vc = storyboard?.instantiateViewController(withIdentifier: "CarsTableViewController") as! CarsTableViewController
            vc.myCars = 1
            self.navigationController?.pushViewController(vc, animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCarsView"), object: nil, userInfo: nil)
            
        case "Add Car":
            let vc = storyboard?.instantiateViewController(withIdentifier: "AddCarViewController") as! AddCarViewController
            self.navigationController?.pushViewController(vc, animated: true)
            
        case "Notifications":
            let vc = storyboard?.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
            self.navigationController?.pushViewController(vc, animated: true)
            
        case "My Favorites":
            let vc = storyboard?.instantiateViewController(withIdentifier: "CarsTableViewController") as! CarsTableViewController
            vc.MyFav = 1
            self.navigationController?.pushViewController(vc, animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCarsView"), object: nil, userInfo: nil)
            
        case "Sent Orders":
            let vc = storyboard?.instantiateViewController(withIdentifier: "SentViewController") as! SentViewController
            self.navigationController?.pushViewController(vc, animated: true)
            
        case "Incoming Orders":
            let vc = storyboard?.instantiateViewController(withIdentifier: "IncomingViewController") as! IncomingViewController
            self.navigationController?.pushViewController(vc, animated: true)
            
        case "Contact Us":
            let vc = storyboard?.instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case "More":
            let vc = storyboard?.instantiateViewController(withIdentifier: "MoreVC") as! MoreVC
            self.navigationController?.pushViewController(vc, animated: true)
        case "Logout":
            let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logout"), object: nil, userInfo: nil)
            }
            
            
            self.dismiss(animated: true, completion: nil)
        default:
            return
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
}
