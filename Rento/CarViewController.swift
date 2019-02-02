//
//  CarViewController.swift
//  Rento
//
//  Created by mouhammed ali on 8/23/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import Cosmos
import ReadMoreTextView
import Toast_Swift
import Alamofire
import PKHUD
import PhotoSlider
import SDWebImage
class CarViewController: MirroringViewController, UIScrollViewDelegate {
    var currntIndex = 0
    var photosArray = [URL]()
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var numberOfImageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var carMakeLabel: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var tripsLbl: UILabel!
    @IBOutlet weak var carType: UILabel!
    @IBOutlet weak var carModel: UILabel!
    @IBOutlet weak var numberOfDoors: UILabel!
    @IBOutlet weak var gearType: UILabel!
    @IBOutlet weak var km: UILabel!
    @IBOutlet weak var kmPerDay: UILabel!
    let datePickerView:UIDatePicker = UIDatePicker()
    let datePickerContainer = UIView()
    var fiedlTag = 0
    var numberOfPhotos = 0
    var newAddedCar = 0
    var minDate = ""
    var token = ""
    var userId = ""
    var lang = ""
    var currency = ""
    @IBOutlet var startDateView: UIView!
    @IBOutlet var endDateView: UIView!
    @IBOutlet var startTime: UITextField!
    
    @IBOutlet var endTime: UITextField!

    @IBOutlet var showCarInMapButt: UIButton!
    @IBOutlet var rentCarButt: UIButton!
    @IBOutlet var reportCarButt: UIButton!
    @IBOutlet var addToFavButt: UIButton!
    
    @IBOutlet var startView: UIView!
    
    @IBOutlet var endView: UIView!
    
    @IBOutlet var infoViewController: UIView!
    
    @IBOutlet var buttonsView: UIView!
    
    @IBOutlet var desc: UILabel!
    
    @IBOutlet var readMoreButt: UIButton!
    
    @IBOutlet var fromField: UITextField!
    
    @IBOutlet var toField: UITextField!
    
    @IBAction func rentCarButt(_ sender: Any) {
        if fromField.text == NSLocalizedString("From:", comment: "")  || toField.text == NSLocalizedString("To:", comment: "") || endTime.text == NSLocalizedString("End Time:", comment: "") || startTime.text ==  NSLocalizedString("Start Time:", comment: "")  {
            self.view.makeToast("Please Select From And To Dates")
        }
        else{
            rentThisCar()
        }
    }
    
    @IBAction func openMapButt(_ sender: Any) {
        
        UIApplication.shared.openURL(NSURL(string:"http://maps.apple.com/?ll=\(item["map_lat"]!),\(item["map_lng"]!)")! as URL)
    }
    
    @IBAction func reportButt(_ sender: Any) {
        
        showReportAlert()
        
        
    }
    
    @IBAction func favoritesButt(_ sender: Any) {
        addToFav()
    }
    var lblFrame = CGRect.zero
    
    @IBAction func readMorePressed(_ sender: Any) {
        if readMoreButt.currentTitle == NSLocalizedString("Read More", comment: "") {
            readMoreButt.setTitle(NSLocalizedString("Read Less", comment: ""), for: .normal)
            lblFrame = desc.frame
            desc.numberOfLines = 0
            desc.sizeToFit()
            readMoreButt.setY(y: readMoreButt.frame.origin.y+desc.frame.height)
            infoViewController.setHeight(height:infoViewController.frame.height+desc.frame.height)
            buttonsView.setY(y: infoViewController.frame.maxY + 20)
            carScrollView.contentSize.height = carScrollView.contentSize.height + desc.frame.height
            carScrollView.layoutIfNeeded()
            buttonsView.layoutIfNeeded()
            self.view.layoutIfNeeded()
            infoViewController.layoutIfNeeded()
            readMoreButt.layoutIfNeeded()
            desc.layoutIfNeeded()
            
        }else{
            readMoreButt.setTitle(NSLocalizedString("Read More", comment: ""), for: .normal)
            readMoreButt.setY(y: readMoreButt.frame.origin.y - desc.frame.height)
            infoViewController.setHeight(height:infoViewController.frame.height - desc.frame.height)
            buttonsView.setY(y: infoViewController.frame.maxY + 20)
            carScrollView.contentSize.height = carScrollView.contentSize.height - desc.frame.height
            desc.numberOfLines = 1
            desc.frame = lblFrame
            carScrollView.layoutIfNeeded()
            buttonsView.layoutIfNeeded()
            self.view.layoutIfNeeded()
            infoViewController.layoutIfNeeded()
            readMoreButt.layoutIfNeeded()
            desc.layoutIfNeeded()
        }
    }
    
    @IBOutlet var carScrollView: UIScrollView!
    
    
    @IBOutlet var starsView: CosmosView!
    
    var item = [String:AnyObject]()
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.showImgInLightBox(_:)), name: NSNotification.Name(rawValue: "showImgInLightBox"), object: nil)
        carScrollView.delegate = self
        setupNavBar()
        if L102Language.currentAppleLanguage() == "ar" {
            fromField.textAlignment = .right
            toField.textAlignment = .right
        }
        self.title = NSLocalizedString("CAR DETAILS", comment: "")
        
        super.viewDidLoad()
      
        if let data = UserDefaults.standard.object(forKey: "selectedCountry") as? NSData{
            if let currencyDict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:AnyObject] {
                
                
            currency = currencyDict["currency"] as! String
            }
        }
        if let langString = UserDefaults.standard.object(forKey: "language") as? String {
            lang = langString
        }
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            token = userDict["token"] as! String
            userId = "\(userDict["user_id"]!)"
            print(userId)
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.updaeIndexLabel(_:)), name: NSNotification.Name(rawValue: "sendIndex"), object: nil)
        if let photosArr = item["photos"] as? [String] {
            var arr = photosArr
            photosArray.removeAll()
            for str in photosArr {
                self.photosArray.append(URL(string: str)!)
            }
            
            if newAddedCar == 1 {
                if let uploadedArr = item["uploadedPhotos"] as? [String] {
                    arr = arr + uploadedArr
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LoadCarsPhotos"), object: nil, userInfo: ["data":arr])
            numberOfPhotos  = arr.count
        }
        numberOfImageLabel.text = "1 of \(numberOfPhotos)"
        configureLblForDate(textField: fromField)
        configureLblForDate(textField: toField)
        configureLblForDate(textField: endTime)
        configureLblForDate(textField: startTime)
        desc.text = "\(item["info"]!)"
        
        print(item)
        tripsLbl.text = "\(item["trips"]!) \(NSLocalizedString("Trips", comment: ""))"
        if let carTypeDict = item["type"] {
            carType.text = carTypeDict["name"] as! String
        }
        if let carMakeDict = item["brand"] {
            carMakeLabel.text = carMakeDict["name"] as! String
        }
        if let carBrandDict = item["brand"] {
            carMakeLabel.text = carBrandDict["name"] as! String
        }
        if let carModelDict = item["car_model"] {
            carModel.text = carModelDict["name"] as! String
        }
        if let rate = item["rate"] as? String {
            if Double(rate) != nil {
                starsView.rating = Double(rate)!
            }
        }
        km.text = "\(item["kilometers"]!)"
        kmPerDay.text = "\(item["kilometers_per_day"]!) \(NSLocalizedString("Per Day", comment: ""))"
        gearType.text = "\(item["gear"]!)"
        if let carCountry = item["country"] {
            
            addressLbl.text = carCountry["name"] as! String
            
        }
        if let carCity = item["city"] {
            let str = carCity["name"] as! String
            addressLbl.text = "\(addressLbl.text!), \(str)"
            
        }
        numberOfDoors.text = "\(item["doors"]!) \(NSLocalizedString("Doors", comment: ""))"
        usernameLabel.text = "\(item["name"]!)"
        
      priceLbl.text = "\(item["price"]!) \(currency)"
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if newAddedCar == 1 || skipped == 1 {
            startDateView.isHidden = true
            endDateView.isHidden = true
            showCarInMapButt.setY(y:startDateView.frame.origin.y)
            rentCarButt.isHidden = true
            reportCarButt.isHidden = true
            addToFavButt.isHidden = true
            startView.isHidden = true
            endView.isHidden = true
            carScrollView.contentSize.height = 720
            
            
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func configureLblForDate(textField:UITextField){
        textField.addTarget(self, action: #selector(CarViewController.EditingDidBeginFunction(_:)), for: UIControlEvents.editingDidBegin)
        
    }
    func EditingDidBeginFunction(_ sender : UITextField){
        sender.tintColor = .clear
        print("did begin")
        if sender.tag < 3 {
        if sender.tag == 2 && fromField.text == "From:" {
            sender.resignFirstResponder()
            self.view.makeToast("Choose Start Date First")
        }else{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let datePickerView:UIDatePicker = UIDatePicker()
            datePickerView.locale = Locale(identifier: L102Language.currentAppleLanguage())
            if sender.tag == 2 {
                print("innnn")
                print(minDate)
                datePickerView.minimumDate = dateFormatter.date(from: minDate)
            }else{
                datePickerView.minimumDate  =  dateFormatter.date(from: item["from"] as! String)
                
            }
            datePickerView.maximumDate = dateFormatter.date(from: item["to"] as! String)
            if sender.tag == 1 {
                if datePickerView.maximumDate!<Date() {
                    self.view.makeToast("No Available Dates")
                    fromField.endEditing(true)
                }else{
                    datePickerView.datePickerMode = UIDatePickerMode.date
                    fiedlTag = sender.tag
                    sender.inputView = datePickerView
                    datePickerView.addTarget(self, action: #selector(CarViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
                }
            }else{
            datePickerView.datePickerMode = UIDatePickerMode.date
            fiedlTag = sender.tag
            sender.inputView = datePickerView
                datePickerView.addTarget(self, action: #selector(CarViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)}
            }
        }else{
             let datePickerView:UIDatePicker = UIDatePicker()
            fiedlTag = sender.tag
            datePickerView.datePickerMode = .time
            sender.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(CarViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
            
        }
    }
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        if fiedlTag > 2 {
            dateFormatter.dateFormat = "HH:mm a"
            (self.view.viewWithTag(fiedlTag) as! UITextField).text = dateFormatter.string(from: sender.date)
            
        }else{
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        (self.view.viewWithTag(fiedlTag) as! UITextField).text = dateFormatter.string(from: sender.date)
        if fiedlTag == 1 {
            minDate = dateFormatter.string(from: sender.date)
            toField.text = NSLocalizedString("To:", comment: "")
            }
        }
        
    }
    func updaeIndexLabel(_ notification: NSNotification) {
        //["index":currentPageIndex])
        if let index = notification.userInfo?["index"] as? Int {
            currntIndex = index
            numberOfImageLabel.text = "\(index+1) of \(numberOfPhotos)"
        }
    }
    func rentThisCar(){
          HUD.show(.progress)
        let headers = ["Accept": "application/json",
                       "Authorization" : "Bearer \(token)"]
        let par = ["car_id": "\(item["car_id"]!)",
        "user_id":userId,
        "start":fromField.text!,
        "end":toField.text!,
        "start_time":startTime.text!.components(separatedBy: " " )[0] ,
        "end_time":endTime.text!.components(separatedBy: " " )[0]
        ]
        print(par)
        print(headers)
        Alamofire.request("http://myrentoapp.com/api/reservations?language=\(lang)", method: .post, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
              print(value)
                
                if let resDict = value as? [String:AnyObject]{
                    if let erStr = resDict["errors"] as? String{
                        self.view.makeToast(erStr)
                    }
                    if let erDict = resDict["errors"] as? [String:AnyObject] {
                          print(value)
                        
                        if let message = erDict["car_id"] as? [String]{
                            var str = ""
                            for i in 0..<message.count {
                                str = str + message[i]
                            }
                            self.view.makeToast(str)
                        }
                        if let message = erDict["user_id"] as? [String]{
                            var str = ""
                            for i in 0..<message.count {
                                str = str + message[i]
                            }
                            self.view.makeToast(str)
                        }
                        if let message = erDict["start"] as? [String]{
                            var str = ""
                            for i in 0..<message.count {
                                str = str + message[i]
                            }
                            self.view.makeToast(str)
                        }
                        if let message = erDict["end"] as? [String]{
                            var str = ""
                            for i in 0..<message.count {
                                str = str + message[i]
                            }
                            self.view.makeToast(str)
                        }
                        if let message = erDict["message"] as? [String]{
                            var str = ""
                            for i in 0..<message.count {
                                str = str + message[i]
                            }
                            self.view.makeToast(str)
                        }

                    }
                    if let message = resDict["car_id"] as? String{
                        self.view.makeToast(message)
                    }
                    if let message = resDict["user_id"] as? String{
                        self.view.makeToast(message)
                    }
                    if let message = resDict["start"] as? String{
                        self.view.makeToast(message)
                    }
                    if let message = resDict["end"] as? String{
                        self.view.makeToast(message)
                    }
                    if let message = resDict["message"] as? String{
                        //self.view.makeToast(message)
                        if let hasBalance = resDict["has_enough_balance"] as? Bool {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RefusalViewController") as! RefusalViewController
                            vc.accepted = 1
                            vc.hasBalance = hasBalance
                            self.present(vc, animated: true, completion: nil)
                            
                        }
                       
                    }

                   
                }
                HUD.hide()
            case .failure(let error):
                print(error)
              //  self.view.makeToast(error.localizedDescription)
                HUD.hide()
            }
        }
        
    }
    func sendReport(msg:String){
        HUD.show(.progress)
        let headers = ["Accept": "application/json",
                       "Authorization" : "Bearer \(token)"]
        let par = ["car_id": "\(item["car_id"]!)",
            "message":msg,
            ]
        print(par)
        print(headers)
        Alamofire.request("http://myrentoapp.com/api/reports?language=\(lang)", method: .post, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                if let resDict = value as? [String:AnyObject]{
                    if let message = resDict["message"] as? String{
                        self.view.makeToast(message)
                    }
                }
                HUD.hide()
            case .failure(let error):
                print(error)
                HUD.hide()
            }
        }
    }
    
    func addToFav(){
        HUD.show(.progress)
        let headers = ["Accept": "application/json",
                       "Authorization" : "Bearer \(token)"]
        let par = ["car_id": "\(item["car_id"]!)",
            
            ]
        

        Alamofire.request("http://myrentoapp.com/api/favorite?language=\(lang)", method: .post, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                if let resDict = value as? [String:AnyObject]{
                    if let message = resDict["message"] as? String{
                        self.view.makeToast(message)
                    }
                }
                HUD.hide()
            case .failure(let error):
                print(error)
              //  self.view.makeToast(error.localizedDescription)
                HUD.hide()
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if readMoreButt.currentTitle != NSLocalizedString("Read More", comment: "") {
            readMoreButt.setTitle(NSLocalizedString("Read More", comment: ""), for: .normal)
            readMoreButt.setY(y: readMoreButt.frame.origin.y - desc.frame.height)
            infoViewController.setHeight(height:infoViewController.frame.height - desc.frame.height)
            buttonsView.setY(y: infoViewController.frame.maxY + 20)
            carScrollView.contentSize.height = carScrollView.contentSize.height - desc.frame.height
            desc.numberOfLines = 1
            desc.frame = lblFrame
            carScrollView.layoutIfNeeded()
            buttonsView.layoutIfNeeded()
            self.view.layoutIfNeeded()
            infoViewController.layoutIfNeeded()
            readMoreButt.layoutIfNeeded()
            desc.layoutIfNeeded()
        }
    }
    func showReportAlert() {
        let alertController = UIAlertController(title:NSLocalizedString("What Is Wrong?", comment: "") , message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: NSLocalizedString("Send", comment: ""), style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            
            
            self.sendReport(msg:firstTextField.text!)
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        alertController.addTextField { (textField : UITextField!) -> Void in
            
        }


        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    func setupNavBar(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        if newAddedCar == 1 {
            if self.isMovingFromParentViewController {
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                for aViewController in viewControllers {
                    if aViewController is SegmentedViewController {
                        self.navigationController!.popToViewController(aViewController, animated: true)
                    }
                }
            }
        }
    }
    func showImgInLightBox(_ notification: NSNotification) {
        
        let slider = PhotoSlider.ViewController(imageURLs: photosArray)
        slider.modalPresentationStyle = .overCurrentContext
        slider.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        slider.currentPage = currntIndex
        slider.imageLoader = PhotoSliderSDImageLoader()
        present(slider, animated: true, completion: nil)

        

        
    }
}
class PhotoSliderSDImageLoader: PhotoSlider.ImageLoader {
    public func load(
        imageView: UIImageView?,
        fromURL url: URL?,
        progress: @escaping PhotoSlider.ImageLoader.ProgressBlock,
        completion: @escaping PhotoSlider.ImageLoader.CompletionBlock)
    {
        imageView?.sd_setImage(
            with: url,
            placeholderImage: nil,
            options: SDWebImageOptions.retryFailed,
            progress: { (receivedSize, totalSize, url) in
                progress(receivedSize, totalSize)
        },
            completed: { (image, _, _, _) in
                completion(image)
        }
        )
    }}
    extension UIView {

    func setX(x:CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.x = x
        self.frame = frame
    }
    func setHeight(height:CGFloat) {
        var frame:CGRect = self.frame
        frame.size.height = height
        self.frame = frame
    }
    func setWidth(width:CGFloat) {
        var frame:CGRect = self.frame
        frame.size.width = width
        self.frame = frame
    }
    func setY(y:CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.y = y
        self.frame = frame
    }
}
extension CGRect {
    mutating func setY(y:CGFloat) {
        var frame:CGRect = self
        frame.origin.y = y
        self = frame
    }
}
