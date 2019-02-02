//
//  CarImageViewController.swift
//  Rento
//
//  Created by mouhammed ali on 8/23/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import SDWebImage

class CarImageViewController: UIViewController {
    var url = ""
    var pageIndex = 0

    @IBAction func selectImage(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showImgInLightBox"), object: nil, userInfo: nil)
    }
    @IBOutlet var image: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("url:\(url)")
        print(image)
        image.sd_setImage(with: URL(string:url), completed: nil)
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
