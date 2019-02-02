//
//  ViewController.swift
//  Rento
//
//  Created by mouhammed ali on 7/1/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import Foundation
import XLPagerTabStrip
import UIKit
import MIBadgeButton_Swift
import SideMenu
class SegmentedViewController: ButtonBarPagerTabStripViewController {
    
    @IBOutlet var seachButt: UIButton!
    @IBOutlet var menuButt: UIButton!
    
    @IBOutlet var rightNavView: UIView!
    @IBAction func menuPressed(_ sender: Any) {
        if skipped == 1 {
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "SignUpOrLoginViewController")
            let navController = UINavigationController(rootViewController: VC1)
            
            self.present(navController, animated:true, completion: nil)
        }else{
            if L102Language.currentAppleLanguage() == "en" {
                present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
                
            }else{
                present(SideMenuManager.menuRightNavigationController!, animated: true, completion: nil)
                
            }
        }
    }
    @IBAction func optionsButt(_ sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message:"Options", preferredStyle: .actionSheet)
        let changeLang = UIAlertAction(title: NSLocalizedString("Change Language", comment: ""), style: .default, handler:
        {(alert: UIAlertAction!) -> Void in
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "LanguageSelectionViewController") as! LanguageSelectionViewController
            VC1.options = 1
            self.present(VC1, animated:true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
        })
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        let messageText = NSMutableAttributedString(
            string: NSLocalizedString("Choose Option", comment: ""),
            attributes: [
                NSParagraphStyleAttributeName: paragraphStyle,
                NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.body),
                NSForegroundColorAttributeName : UIColor.black
            ]
        )
        
        
        let ChangeCountry = UIAlertAction(title:NSLocalizedString("Change Country", comment: "") , style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "CountrySelectionViewController") as! CountrySelectionViewController
            VC1.options = 1
            self.present(VC1, animated:true, completion: nil)
            
        })
        optionMenu.setValue(messageText, forKey: "attributedMessage")
        optionMenu.addAction(changeLang)
        optionMenu.addAction(ChangeCountry)
        optionMenu.addAction(cancelAction)
        
        if let presenter = optionMenu.popoverPresentationController {
            presenter.sourceView = sender
            presenter.sourceRect = sender.bounds
        }

        
            self.present(optionMenu, animated: true, completion: nil)
        
        
        
    }
    
    @IBOutlet var notificationsButt: MIBadgeButton!
    override func viewDidLoad() {
        //Setup SideMenu
        let view = storyboard?.instantiateViewController(withIdentifier: "SideMenuViewController")
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: view!)
        let view2 = storyboard?.instantiateViewController(withIdentifier: "SideMenuViewController")
        let leftNavigationController = UISideMenuNavigationController(rootViewController: view2!)
        
        
        leftNavigationController.leftSide = true
        SideMenuManager.menuLeftNavigationController = leftNavigationController
        
        menuLeftNavigationController.leftSide = false
        SideMenuManager.menuRightNavigationController = menuLeftNavigationController
        if L102Language.currentAppleLanguage() == "ar" {
            menuButt.setImage(UIImage(named:"Menuar"), for: .normal)
        }
        self.title = NSLocalizedString("CAR RENTAL", comment: "")
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = UIColor(colorLiteralRed: 162.0/255.0, green: 159.0/255.0, blue: 177.0/255.0, alpha: 1.0)
            newCell?.label.textColor = UIColor(colorLiteralRed: 49.0/255.0, green: 72.0/255.0, blue: 86.0/255.0, alpha: 1.0)
            
            if animated {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                })
            }
            else {
                newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
        // updateBadge
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateBadge(_:)), name: NSNotification.Name(rawValue: "updateBadge"), object: nil)
        super.viewDidLoad()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = ""
        
        
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let view = storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        let view2 = storyboard?.instantiateViewController(withIdentifier: "CarsTableViewController") as! CarsTableViewController
        let view3 = storyboard?.instantiateViewController(withIdentifier: "CarsTableViewController") as! CarsTableViewController
        view3.featured = 1
        return [view2,view3, view]
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        if UserDefaults.standard.integer(forKey: "changeLangFlag") == 1 {
            changeLanguage(root:"NavController")
            UserDefaults.standard.set(0, forKey: "changeLangFlag")
            
        }
        
        if UserDefaults.standard.integer(forKey:"notifNumber") == 0 {
            notificationsButt.badgeString = ""
        }else{
            notificationsButt.badgeString = "\(UserDefaults.standard.integer(forKey: "notifNumber"))"
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        let widthConstraint = menuButt.widthAnchor.constraint(equalToConstant: 32)
        let heightConstraint = menuButt.heightAnchor.constraint(equalToConstant: 32)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        menuButt.isHidden = false
        seachButt.isHidden = false
        if skipped == 1 {
            menuButt.setImage(UIImage(named:"login"), for: .normal)
            rightNavView.isHidden = true
        } else{
            if L102Language.currentAppleLanguage() == "ar" {
                menuButt.setImage(UIImage(named:"Menuar"), for: .normal)
            }else{
                menuButt.setImage(UIImage(named:"menu"), for: .normal)
            }
            rightNavView.isHidden = false
        }
        
        
        setupNavigatioBar()
    }
    override func viewWillDisappear(_ animated: Bool) {
        menuButt.isHidden = true
        seachButt.isHidden = true
        
    }
    
    func updateBadge(_ notification: NSNotification) {
        if UserDefaults.standard.integer(forKey:"notifNumber") == 0 {
            notificationsButt.badgeString = ""
        }else{
            notificationsButt.badgeString = "\(UserDefaults.standard.integer(forKey: "notifNumber"))"
        }
        
        
    }
    
    
    func setupNavigatioBar(){
        self.buttonBarView.layer.shadowColor = UIColor.black.cgColor
        self.buttonBarView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.buttonBarView.layer.shadowRadius = 4.0
        self.buttonBarView.layer.shadowOpacity = 0.3
        self.buttonBarView.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowRadius = 0
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: -100, width: 150, height: 40))
        imageView.contentMode = .scaleAspectFit
        
        
        
        
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    func changeLanguage(root:String){
        if L102Language.currentAppleLanguage() == "en" {
            L102Language.setAppleLAnguageTo(lang: "ar")
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            L102Language.setAppleLAnguageTo(lang: "en")
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        };        let rootviewcontroller: UIWindow = ((UIApplication.shared.delegate?.window)!)!
        rootviewcontroller.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: root)
        let mainwindow = (UIApplication.shared.delegate?.window!)!
        mainwindow.backgroundColor = UIColor(hue: 0.6477, saturation: 0.6314, brightness: 0.6077, alpha: 0.8)
        UIView.transition(with: mainwindow, duration: 0.55001, options: .transitionFlipFromLeft, animations: { () -> Void in
        }) { (finished) -> Void in
        }
        
    }
    
    
    
}

import UIKit

@IBDesignable extension UIView {
    
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor:color)
            }
            else {
                return nil
            }
        }
    }
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    //    @IBInspectable var cornerRadius:CGFloat {
    //        set {
    //            layer.cornerRadius = newValue
    //            clipsToBounds = newValue > 0
    //        }
    //        get {
    //            return layer.cornerRadius
    //        }
    //    }
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }
    
    
    
    
    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 0, height: 3.0),
                   shadowOpacity: Float = 0.2,
                   shadowRadius: CGFloat = 5.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = false
        
    }
    
}
