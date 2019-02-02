//
//  CarPageViewController.swift
//  Rento
//
//  Created by mouhammed ali on 8/23/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit

class CarPageViewController: UIPageViewController,UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var arr = [String]()
    var orderedViewControllers: [UIViewController]?
    var lastPendingViewControllerIndex = 0
    var currentPageIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadPhotos(_:)), name: NSNotification.Name(rawValue: "LoadCarsPhotos"), object: nil)
        
        //CarImageViewController
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPhotos(_ notification: NSNotification) {
        
        if let images = notification.userInfo?["data"] as? [String] {
            arr = images
            print(arr)
            self.setViewControllers([self.getViewControllerAtIndex(index: 0)], direction: .forward, animated: true, completion: nil)
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]){
        
        if let viewController = pendingViewControllers[0] as? CarImageViewController {
            
            
            self.lastPendingViewControllerIndex = viewController.pageIndex
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed{
            
            self.currentPageIndex = self.lastPendingViewControllerIndex
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendIndex"), object: nil, userInfo: ["index":currentPageIndex])
            
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? CarImageViewController{
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
        if let vc = viewController as? CarImageViewController{
            if let index = vc.pageIndex as? Int {
                if index < arr.count - 1  {
                    // pageControl.currentPage = index + 1
                    return getViewControllerAtIndex(index: index+1)
                    
                }
            }
        }
        return nil
    }
    
    func getViewControllerAtIndex(index: NSInteger) -> CarImageViewController
    {
        // Create a new view controller and pass suitable data.
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "CarImageViewController") as! CarImageViewController
        pageContentViewController.pageIndex = index
        if arr.count>0{
            pageContentViewController.url = arr[index]
        }
       
        //   pageContentViewController.strPhotoName = "\(arrPagePhoto[index])"
        
        return pageContentViewController
    }
}



