//
//  SignUpOrLoginViewController.swift
//  Rento
//
//  Created by mouhammed ali on 3/5/18.
//  Copyright © 2018 mouhammed ali. All rights reserved.
//

import UIKit
var skipped = 0
class SignUpOrLoginViewController: UIViewController {

    @IBAction func skipPressed(_ sender: Any) {
        if skipped == 1 {
            self.dismiss(animated: true, completion: nil)
        }else{
        skipped = 1
        if UserDefaults.standard.integer(forKey: "openedBefoure") == 0 {
            //Check if First Open
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SegmentedViewController")
            self.navigationController?.pushViewController(vc!, animated: true, completion: { (Void) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCarsView"), object: nil, userInfo: nil)
            })
        }
        else{
            
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCarsView"), object: nil, userInfo: nil)
            })
            }
            
        }}
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension UINavigationController {
    public func pushViewController(
        _ viewController: UIViewController,
        animated: Bool,
        completion: @escaping (Void) -> Void)
    {
        pushViewController(viewController, animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            completion()
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
}


