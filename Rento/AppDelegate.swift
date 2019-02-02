//
//  AppDelegate.swift
//  Rento
//
//  Created by mouhammed ali on 7/1/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import OneSignal
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSSubscriptionObserver {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Initailize L102Language
        L102Localizer.DoTheMagic()
        
        //setup onesignal
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "0849c9a9-8fcb-4ac7-88ad-b335fff919ba",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        OneSignal.add(self as OSSubscriptionObserver)
        UserDefaults.standard.set(1, forKey: "Show Lang")
        GMSServices.provideAPIKey("AIzaSyDM-AUfsi6MhKuDMCM8NbwfJr9h99qCOvE")
        GMSPlacesClient.provideAPIKey("AIzaSyDM-AUfsi6MhKuDMCM8NbwfJr9h99qCOvE")
        UserDefaults.standard.set(1, forKey: "Show Lang")
        IQKeyboardManager.shared.enable = true
        
        //setup navigation bar
        var navigationBarAppearace = UINavigationBar.appearance()
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-1000, 0), for:UIBarMetrics.default)
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:#colorLiteral(red: 0.09411764706, green: 0.4039215686, blue: 0.662745098, alpha: 1), NSFontAttributeName:UIFont(name: "NeoSansW23", size: 18)!]
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {

    }
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        print("SubscriptionStateChange: \n\(stateChanges)")
        
        //The player id is inside stateChanges. But be careful, this value can be nil if the user has not granted you permission to send notifications.
        if let playerId = stateChanges.to.userId {
            UserDefaults.standard.set(playerId, forKey: "onesignalid")
            print("Current playerId \(playerId)")
        }
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("nofication reciewveddd")
        print(userInfo)
        if let dict = userInfo["aps"] as? [String:AnyObject] {
            if let dictAlert = dict["alert"] as? [String:AnyObject] {
                if let msg = dictAlert["body"] as? String {
                    //Show Message with the incoming notification
                    UIApplication.shared.keyWindow?.currentViewController()?.view.makeToast(msg)
                    
                }
            }
        }
        if let userInfoDict = userInfo["custom"] as? [String:AnyObject] {
            if let userInfoA = userInfoDict["a"] as? [String:AnyObject]{
                if let notifType = userInfoA["type"] as? String {
                    let added = UserDefaults.standard.integer(forKey: "notifNumber") + 1
                    UserDefaults.standard.set(added, forKey: "notifNumber")
                     NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateBadge"), object: nil, userInfo: nil)
                    //Handle Notification types
                    switch notifType {
                    case "reservation_added":
                        let when = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            let vc = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "RentPromptViewController") as! RentPromptViewController
                            vc.userInfo = userInfoA
                            
                            UIApplication.shared.keyWindow?.currentViewController()?.present(vc, animated: true, completion: nil)
                        }
                    case "reservation_deleted":
                        let when = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            let vc = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "RefusalViewController") as! RefusalViewController
                            
                            
                            UIApplication.shared.keyWindow?.currentViewController()?.present(vc, animated: true, completion: nil)
                        }
                    case "reservation_ended":
                        let when = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            let vc = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "CongratsViewController") as! CongratsViewController
                            vc.resEnded = 1
                            
                            UIApplication.shared.keyWindow?.currentViewController()?.present(vc, animated: true, completion: nil)
                        }
                    case "rate":
                        let when = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            let vc = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "RatingViewController") as! RatingViewController
                            vc.userInfo = userInfoA
                            
                            UIApplication.shared.keyWindow?.currentViewController()?.present(vc, animated: true, completion: nil)
                        }
                    case "reservation_approved":
                        let when = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            let vc = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "CongratsViewController") as! CongratsViewController
                            
                            
                            if let dataDict = userInfoA["data"] as? [String:AnyObject]{
                                if let hasMoney = dataDict["has_enough_balance"] as? Bool {
                                    vc.hasBalance = hasMoney
                                }
                            }
                            UIApplication.shared.keyWindow?.currentViewController()?.present(vc, animated: true, completion: nil)
                        }
                    case "reservation_deleted":
                        let vc = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "RefusalViewController") as! RefusalViewController
                        
                        
                        UIApplication.shared.keyWindow?.currentViewController()?.present(vc, animated: true, completion: nil)
                        
                    default:
                      break
                    }
                }
            }
        }
        
        
        
    }
 
}
