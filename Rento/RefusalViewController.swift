//
//  RefusalViewController.swift
//  Rento
//
//  Created by mouhammed ali on 9/27/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit

class RefusalViewController: UIViewController {
    @IBAction func dimissButt(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBOutlet var imgView: UIImageView!
    var accepted = 0
    var hasBalance = false
    var withrraw = 0
    override func viewDidLoad() {
        if L102Language.currentAppleLanguage() == "ar" {
            imgView.image = UIImage(named:"sadar")
        }
        if accepted == 1 {
            imgView.image = UIImage(named:"sent Icon")
            
            if L102Language.currentAppleLanguage() == "ar" {
                imgView.image = UIImage(named:"smileBalanceAr")
            }
            
            if hasBalance == true {
                imgView.image = UIImage(named:"sent paid")
                if L102Language.currentAppleLanguage() == "ar" {
                    imgView.image = UIImage(named:"send paid ar")
                }
            }
        }
        if withrraw == 1 {
            imgView.image = UIImage(named: "quotes-right")
            if L102Language.currentAppleLanguage() == "ar" {
                imgView.image = UIImage(named:"quotes-right ar")
            }
        }
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

