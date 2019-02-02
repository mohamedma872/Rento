//
//  RentPromptViewController.swift
//  Rento
//
//  Created by mouhammed ali on 9/27/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import Font_Awesome_Swift
import PKHUD
class RentPromptViewController: UIViewController {
    var userInfo = [String:AnyObject]()
    @IBOutlet var userImgView: UIImageView!
    @IBOutlet var nameField: UILabel!
    @IBOutlet var locationField: UILabel!
    @IBOutlet var fromField: UILabel!
    @IBOutlet var toField: UILabel!
    @IBOutlet var carField: UILabel!
    @IBOutlet var priceLbl: UILabel!
    var reservationId = 0
    var token = ""
    
    @IBOutlet var noButt: UIButton!
    @IBOutlet var yesButt: UIButton!
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func yesBtnAction(_ sender: Any) {
        sendAnswer(answer: "approved")
    }
    @IBAction func noBtnAction(_ sender: Any) {
        sendAnswer(answer: "delete")
    }

    @IBOutlet var promptBackground: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if L102Language.currentAppleLanguage() == "ar" {
            yesButt.setImage(UIImage(named:"yesAr"), for: .normal)
            noButt.setImage(UIImage(named:"noAr"), for: .normal)
            promptBackground.image = UIImage(named:"promptBackar")
        
        }
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            token = userDict["token"] as! String
            
        }
        if let avatar = userInfo["avatar"] as? String {
            userImgView.sd_setImage(with: URL(string:avatar), completed: nil)
        }
        if let country = userInfo["country"] as? String {
            var str = country
            if let city = userInfo["city"] as? String {
                var str = str + ", " + city
            }
            locationField.setFAText(prefixText: "", icon: .FAMapMarker , postfixText: " \(str)", size: 17, iconSize: 20)
            
        }
        if let fromDate = userInfo["start"] as? String {
            fromField.text = fromDate
        }
        if let toDate = userInfo["end"] as? String {
            toField.text = toDate
        }
        if let userName = userInfo["username"] as? String {
            nameField.text = userName
        }
        if let car = userInfo["car"] as? String {
            carField.text = car
        }
        if let id = userInfo["reservation_id"] as? Int {
            reservationId = id
        }
        if let price = userInfo["price"] as? Float {
            
        priceLbl.text = "\(price)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func sendAnswer(answer:String){
        HUD.show(.progress)
        let headers = ["Accept": "application/json",
                       "Authorization" : "Bearer \(token)"]
        let par = ["status":answer]
        print("http://myrentoapp.com/api/reservations/\(reservationId)")
        Alamofire.request("http://myrentoapp.com/api/reservations/\(reservationId)", method: .put, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                HUD.hide()
                self.dismiss(animated: true, completion: {
                    var msg = ""
                    if let dict = value as? [String:AnyObject] {
                        if let message = dict["message"] as? String {
                            msg = message
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
