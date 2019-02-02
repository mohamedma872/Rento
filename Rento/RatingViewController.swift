//
//  RatingViewController.swift
//  Rento
//
//  Created by mouhammed ali on 9/27/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import Cosmos
import SDWebImage
import Alamofire
import PKHUD
class RatingViewController: UIViewController {
    @IBOutlet var imgView: UIImageView!
    var userInfo = [String:AnyObject]()
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var countryLbl: UILabel!
    @IBOutlet var starsView: CosmosView!
    var reservationId = 0
    var useId = 0
    var token = ""
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func ratePressed(_ sender: Any) {
        rate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            token = userDict["token"] as! String
            
        }
        if let avatar = userInfo["avatar"] as? String {
            imgView.sd_setImage(with: URL(string:avatar), completed: nil)
        }
        if let country = userInfo["country"] as? String {
            var str = country
            if let city = userInfo["city"] as? String {
                var str = str + ", " + city
            }
            countryLbl.setFAText(prefixText: "", icon: .FAMapMarker , postfixText: " \(str)", size: 17, iconSize: 20)
            
        }
        if let userName = userInfo["username"] as? String {
            nameLbl.text = userName
        }
        if let id = userInfo["reservation_id"] as? Int {
            reservationId = id
        }
        if let id = userInfo["user_id"] as? Int {
            useId = id
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func rate() {
        HUD.show(.progress)
        let headers = ["Accept": "application/json",
                       "Authorization" : "Bearer \(token)"]
        let par = ["reservation_id":reservationId,
                   "user_id":useId,
                   "rate": Float(starsView.rating)] as [String : Any]
        
        Alamofire.request("http://myrentoapp.com/api/rate", method: .post, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
              
                
                
            case .success(let value):
                print(value)
                HUD.hide()
                var message = ""
                self.dismiss(animated: true, completion: {
                    var msg = ""
                    if let dict = value as? [String:AnyObject] {
                        if (dict["errors"] as? [String:AnyObject]) != nil {
                            
                        }else{
                            msg = "You rated the car sucessfuly"
                        }
                    }
                    UIApplication.shared.keyWindow?.currentViewController()?.view.makeToast(msg)
                })
            case .failure(let error):
                print(error)
                HUD.hide()
                self.view.makeToast("something went wrong")
            }
        }
    }

}
