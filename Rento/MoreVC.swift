//
//  MoreVC.swift
//  Rento
//
//  Created by mouhammed ali on 9/22/18.
//  Copyright © 2018 mouhammed ali. All rights reserved.
//

import UIKit

class MoreVC: UIViewController {
    @IBAction func presentToPDF(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PDFWebVC") as! PDFWebVC
        vc.PDFName = sender.title(for: .normal) ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("More", comment: "")
        setupNavigatioBar()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupNavigatioBar(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.title = ""
        
    }

}
