//
//  CountryPageViewController.swift
//  Rento
//
//  Created by mouhammed ali on 8/17/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
class CountryPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var pageControl = UIPageControl()
    var arr = [[String:AnyObject]]()
    var orderedViewControllers: [UIViewController]?
    var lang = ""
    var lastPendingViewControllerIndex = 0
    var currentPageIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        print("didLoad")
        self.dataSource = self
        self.delegate = self
        if let langString = UserDefaults.standard.object(forKey: "language") as? String {
            lang = langString
            
        }
        
         UserDefaults.standard.removeObject(forKey: "selectedCountry")
        getData()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - PageViewController Delegate
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]){
        
        if let viewController = pendingViewControllers[0] as? CountryCellPageViewController {
            
            
            self.lastPendingViewControllerIndex = viewController.pageIndex
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed{
            
            self.currentPageIndex = self.lastPendingViewControllerIndex
            pageControl.currentPage = self.currentPageIndex
            let dat = NSKeyedArchiver.archivedData(withRootObject: self.arr[self.currentPageIndex])
            UserDefaults.standard.set(dat, forKey: "selectedCountry")
            UserDefaults.standard.set(self.currentPageIndex, forKey: "selectedCountryIndex")

                    
                    
        }

    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? CountryCellPageViewController{
            if let index = vc.pageIndex as? Int {
                if index > 0  {
                   // pageControl.currentPage = index - 1
                    return getViewControllerAtIndex(index: index-1)
                }
            }
        }
        return nil
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? CountryCellPageViewController{
            if let index = vc.pageIndex as? Int {
                if index < arr.count - 1  {
                   // pageControl.currentPage = index + 1
                    return getViewControllerAtIndex(index: index+1)
                    
                }
            }
        }
        return nil
    }

    //Get Countries
    func getData(){
        var flag = 0
        // HUD.show(.progress)
        print("getting")
        
        var method = HTTPMethod.get
        let par = ["Accept" : "application/json"]
        
        // HUD.show(.progress)
        if let data = UserDefaults.standard.object(forKey: "countries\(lang)") as? NSData{
            if let dict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:AnyObject] {
                if let array = dict["countries"] as? [[String : AnyObject]]{
                    flag = 1
                    arr = array
                    self.setViewControllers([self.getViewControllerAtIndex(index: 0)], direction: .forward, animated: true, completion: nil)
                    self.configurePageControl()
                    let dat = NSKeyedArchiver.archivedData(withRootObject: self.arr[self.currentPageIndex])
                    UserDefaults.standard.set(dat, forKey: "selectedCountry")
                    UserDefaults.standard.set(self.currentPageIndex, forKey: "selectedCountryIndex")
                    

                }
            }}
        Alamofire.request("http://myrentoapp.com/api/countries?language=\(lang)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: par).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                
                
                if let dict = value as? [String:AnyObject]{
                    
                    
                    
                    
                    if flag == 0
                    {
                        if let array = dict["countries"] as? [[String : AnyObject]]{
                            self.arr = array
                            self.setViewControllers([self.getViewControllerAtIndex(index: 0)], direction: .forward, animated: true, completion: nil)
                            self.configurePageControl()
                            let dat = NSKeyedArchiver.archivedData(withRootObject: self.arr[self.currentPageIndex])
                            UserDefaults.standard.set(dat, forKey: "selectedCountry")
                            UserDefaults.standard.set(self.currentPageIndex, forKey: "selectedCountryIndex")
                        }
                        //HUD.hide()
                        
                    }
                    else{
                        //self.introTable.reloadData()
                    }
                    
                    let dat = NSKeyedArchiver.archivedData(withRootObject: dict)
                    UserDefaults.standard.set(dat, forKey: "countries\(self.lang)")
                    
                }
                
                
            // HUD.hide()
            case .failure(let error):
                print(error)
                // HUD.hide()
            }
        }
        
    }
    
    
    func getViewControllerAtIndex(index: NSInteger) -> CountryCellPageViewController
    {
        // Create a new view controller and pass suitable data.
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "CountryCellPageViewController") as! CountryCellPageViewController
        pageContentViewController.pageIndex = index
        
        
        pageContentViewController.imageUrl = "\(arr[index]["photo"]!)"
        pageContentViewController.lblText = "\(arr[index]["name"]!)"
        //   pageContentViewController.strPhotoName = "\(arrPagePhoto[index])"
        
        return pageContentViewController
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: -20 ,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = arr.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        //.addTarget(self, action: "action:", forControlEvents: UIControlEvents.TouchUpInside)
       // self.pageControl.addTarget(self, action: "switchPage", for: .touchUpInside)
        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)
        self.view.addSubview(pageControl)
    }
    func changePage(sender:UIPageControl!) {
        var direction = UIPageViewControllerNavigationDirection.reverse
        if currentPageIndex<sender.currentPage {
            direction = UIPageViewControllerNavigationDirection.forward
        }
        self.setViewControllers([self.getViewControllerAtIndex(index: sender.currentPage)], direction: direction, animated: true, completion: nil)
    }
    
}
