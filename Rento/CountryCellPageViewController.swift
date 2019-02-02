//
//  CountryCellPageViewController.swift
//  Rento
//
//  Created by mouhammed ali on 8/17/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import SDWebImage
class CountryCellPageViewController: UIViewController {
    @IBOutlet weak var image: UIImageView!
    var imageUrl = ""
    var lblText = ""
@IBOutlet weak var lbl: UILabel!
    var pageIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        image.sd_setImage(with: URL(string:imageUrl) , completed: nil)
        lbl.text = lblText
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
