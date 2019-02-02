//
//  CongratsViewController.swift
//  Rento
//
//  Created by mouhammed ali on 9/26/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit

class CongratsViewController: UIViewController {
    @IBAction func dimissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet var imgView: UIImageView!
    var hasBalance = false
    var resEnded = 0
    override func viewDidLoad() {
        if L102Language.currentAppleLanguage() == "ar" {
            imgView.image = UIImage(named:"smileBalanceAr")
        }
        super.viewDidLoad()
        if hasBalance == true {
            imgView.image = UIImage(named:"smileBalance")
            if L102Language.currentAppleLanguage() == "ar" {
                imgView.image = UIImage(named:"send paid ar")
            }
        }
        if resEnded == 1 {
            imgView.image = UIImage(named:"reservation ended")
            if L102Language.currentAppleLanguage() == "ar" {
                imgView.image = UIImage(named:"rentendedAr")
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
