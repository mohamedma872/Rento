//
//  AddCarViewController.swift
//  Rento
//
//  Created by mouhammed ali on 9/2/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import GooglePlacePicker
import DropDown
import Alamofire
import PKHUD
import CoreLocation

class imageCell:UICollectionViewCell {
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var deleteButt: UIButton!
    
    var ButtonHandler:(()-> Void)!
    
    @IBAction func ButtonClicked(_ sender: UIButton) {
        self.ButtonHandler()
    }
    
}
class AddCarViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate, GMSPlacePickerViewControllerDelegate {
    var pickerController = UIImagePickerController()
    @IBOutlet var selectCityButt: UIButton!
    
    @IBOutlet var largeTitle: UILabel!
    var urlArray = [String]()
    var countryDict = [String:AnyObject]()
    var selectedPricePerDay = ""
    var mainImgurl = ""
    var SelectedCity = ""
    var minDate = ""
    var selectedModel = ""
    var selectedType = ""
    var selectedPlace:GMSPlace?
    var long = ""
    var edit = 0
    var item = [String:AnyObject]()
    var lat = ""
    @IBOutlet var descriptionField: UITextField!
    var selctedBrand = ""
    var selectedDoOrNumer = ""
    var selectedGear = ""
    var fiedlTag = 0
    var citiesArr = [[String:AnyObject]]()
    var carModelsArr = [[String:AnyObject]]()
    var countryId = 0
    var lang = ""
    var token = ""
    var brandsArr = [[String:AnyObject]]()
    var carTypArr = [[String:AnyObject]]()
    let dropdown = DropDown()
    @IBAction func selectCity(_ sender: Any) {
        dropdown.direction = .bottom
        dropdown.anchorView = selectCityButt
        dropdown.dataSource = getStringsFromArr(array: citiesArr)
        dropdown.width = selectCityButt.frame.width
        dropdown.contentMode = .center
        dropdown.bottomOffset = CGPoint(x:0,y:self.selectCityButt.frame.height+1)
        dropdown.show()
        dropdown.selectionAction = {[unowned self](index: Int, item: String) in
            self.selectCityButt.setTitle(item, for: .normal)
            self.selectCityButt.setTitleColor(.black, for: .normal)
            self.SelectedCity = "\(self.citiesArr[index]["city_id"]!)"
            
        }
    }
    
    var selectedImg = 0
    @IBAction func carModel(_ sender: Any) {
        dropdown.direction = .bottom
        dropdown.anchorView = carModelButt
        dropdown.dataSource = getStringsFromArr(array: carModelsArr)
        dropdown.width = carModelButt.frame.width
        dropdown.contentMode = .center
        dropdown.bottomOffset = CGPoint(x:0,y:self.carModelButt.frame.height+1)
        dropdown.show()
        dropdown.selectionAction = {[unowned self](index: Int, item: String) in
            self.carModelButt.setTitle(item, for: .normal)
            self.carModelButt.setTitleColor(.black, for: .normal)
            self.selectedModel = "\(self.carModelsArr[index]["car_model_id"]!)"
            
        }
        
    }
    var locatin:CLLocationCoordinate2D?
    @IBOutlet var carModelButt: UIButton!
    @IBOutlet var whiteView: UIView!
    @IBOutlet var selectTypeButt: UIButton!
    @IBAction func selectType(_ sender: Any) {
        dropdown.direction = .bottom
        dropdown.anchorView = selectTypeButt
        dropdown.dataSource = getStringsFromArr(array: carTypArr)
        dropdown.width = selectTypeButt.frame.width
        dropdown.contentMode = .center
        dropdown.bottomOffset = CGPoint(x:0,y:self.selectTypeButt.frame.height+1)
        dropdown.show()
        dropdown.selectionAction = {[unowned self](index: Int, item: String) in
            self.selectTypeButt.setTitle(item, for: .normal)
            self.selectTypeButt.setTitleColor(.black, for: .normal)
            self.selectedType = "\(self.carTypArr[index]["type_id"]!)"
            
        }
    }
    @IBOutlet var selectBrandButt: UIButton!
    @IBAction func selectBrand(_ sender: Any) {
        dropdown.direction = .bottom
        dropdown.anchorView = selectBrandButt
        dropdown.dataSource = getStringsFromArr(array: brandsArr)
        dropdown.width = selectBrandButt.frame.width
        dropdown.contentMode = .center
        dropdown.bottomOffset = CGPoint(x:0,y:self.selectBrandButt.frame.height+1)
        dropdown.show()
        dropdown.selectionAction = {[unowned self](index: Int, item: String) in
            self.selectBrandButt.setTitle(item, for: .normal)
            self.selectBrandButt.setTitleColor(.black, for: .normal)
            self.selctedBrand = "\(self.brandsArr[index]["brand_id"]!)"
            
        }
        
    }
    @IBOutlet var selectDoorsButt: UIButton!
    @IBAction func selectDoors(_ sender: Any) {
        let arr = ["2", "4", "more"]
        dropdown.direction = .bottom
        dropdown.anchorView = selectDoorsButt
        dropdown.dataSource = arr
        dropdown.width = selectDoorsButt.frame.width
        dropdown.contentMode = .center
        dropdown.bottomOffset = CGPoint(x:0,y:self.selectDoorsButt.frame.height+1)
        dropdown.show()
        dropdown.selectionAction = {[unowned self](index: Int, item: String) in
            self.selectDoorsButt.setTitle(item, for: .normal)
            self.selectDoorsButt.setTitleColor(.black, for: .normal)
            self.selectedDoOrNumer = arr[index]
            
        }
    }
    @IBOutlet var selectGearButt: UIButton!
    @IBAction func selectGear(_ sender: Any) {
        let arr = ["automatic", "manual"]
        dropdown.direction = .bottom
        dropdown.anchorView = selectGearButt
        dropdown.dataSource = arr
        dropdown.width = selectGearButt.frame.width
        dropdown.contentMode = .center
        dropdown.bottomOffset = CGPoint(x:0,y:self.selectGearButt.frame.height+1)
        dropdown.show()
        dropdown.selectionAction = {[unowned self](index: Int, item: String) in
            self.selectGearButt.setTitle(item, for: .normal)
            self.selectGearButt.setTitleColor(.black, for: .normal)
            self.selectedGear = arr[index]
            
        }
        
    }
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var carNameField: UITextField!
    var mainOrmore = 0
    @IBOutlet var currentKmField: UITextField!
    @IBOutlet var kmPerDayFileld: UITextField!
    @IBOutlet var uploadMainImgButt: UIButton!
    @IBOutlet var uploadMoreImagesButt: UIButton!
    @IBAction func uploadMore(_ sender: UIButton) {
        
        imageCollectionView.isHidden = false
        mainOrmore = 1
        let alertViewController = UIAlertController(title: "", message: NSLocalizedString("Choose Option", comment: ""), preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default, handler: { (alert) in
            self.openCamera()
        })
        let gallery = UIAlertAction(title: NSLocalizedString("Gallery", comment: ""), style: .default) { (alert) in
            self.openGallary()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (alert) in
            
        }
        alertViewController.addAction(camera)
        alertViewController.addAction(gallery)
        alertViewController.addAction(cancel)
        alertViewController.popoverPresentationController?.sourceView = self.view
        alertViewController.popoverPresentationController?.permittedArrowDirections = .up
        alertViewController.popoverPresentationController?.sourceRect = sender.frame
        self.present(alertViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func uploadMainImage(_ sender: UIButton) {
        
        mainOrmore = 0
        let alertViewController = UIAlertController(title: "", message: NSLocalizedString("Choose Option", comment: ""), preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default, handler: { (alert) in
            self.openCamera()
        })
        let gallery = UIAlertAction(title: NSLocalizedString("Gallery", comment: ""), style: .default) { (alert) in
            self.openGallary()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (alert) in
            
        }
        alertViewController.addAction(camera)
        alertViewController.addAction(gallery)
        alertViewController.addAction(cancel)
        alertViewController.popoverPresentationController?.sourceView = self.view
        alertViewController.popoverPresentationController?.permittedArrowDirections = .up
        alertViewController.popoverPresentationController?.sourceRect = sender.frame
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    @IBOutlet var getYourtPostitionButt: UIButton!
    
    @IBOutlet var viewToGoDown: UIView!
    
    @IBAction func getPosition(_ sender: Any) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    @IBOutlet var nextButt: UIButton!
    
    @IBAction func nextPressed(_ sender: Any) {
        if selectedImg == 1 && SelectedCity != "" && selectedModel != "" && selectedType != "" && selctedBrand != "" && selectedDoOrNumer != "" && carNameField.text != "" && currentKmField.text != "" && kmPerDayFileld.text != "" && DateToFiel.text != "" && dateFromField.text != "" && urlArray.count + imageArr.count>0{

                checkCountryAndAdd()
        }else{
            self.view.makeToast("Please Fill In All The Information")
        }
    }
    
    @IBOutlet var imageCollectionView: UICollectionView!
    
    @IBOutlet var dateFromField: UITextField!
    
    @IBOutlet var DateToFiel: UITextField!
    @IBOutlet var pricePerDayField: UITextField!
    var imageArr = [UIImage]()
    override func viewWillAppear(_ animated: Bool) {
        largeTitle.textAlignment = .center
    }
    override func viewDidLoad() {
        if L102Language.currentAppleLanguage() == "ar" {
            
            uploadMainImgButt.setImage(UIImage(named:"uploadar"), for: .normal)
            uploadMoreImagesButt.setImage(UIImage(named:"uploadmorear"), for: .normal)
        }
        setupNavBar()
        super.viewDidLoad()
        
        configureLblForDate(textField: dateFromField)
        configureLblForDate(textField: DateToFiel)
        if let data = UserDefaults.standard.object(forKey: "selectedCountry") as? NSData{
            if let arr = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:AnyObject] {
        
            
            //print(cityyy:\(item["city_id"]))
                countryDict = arr
            countryId = arr["country_id"] as! Int
            
                }
        }
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            token = userDict["token"] as! String
            
            
        }
        if let langString = UserDefaults.standard.object(forKey: "language") as? String {
            lang = langString
        }
        
        setupDropArray(suffix: "car_models", key:"car_models")
        setupDropArray(suffix: "types", key:"types")
        setupDropArray(suffix: "brands", key:"brands")
        
        setupDropArray(suffix: "countries/\(countryId)/cities", key: "cities")
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            //print(userDict)
            
        }
        
        let center = CLLocationCoordinate2D(latitude: -33.865143, longitude: 151.2099)
        let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001,
                                               longitude: center.longitude + 0.001)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001,
                                               longitude: center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        
        self.title = NSLocalizedString("ADD CAR", comment: "")
        
        if edit == 1 {
            self.title = NSLocalizedString("EDIT CAR", comment: "")
            //  print("itemmmm:\(item)\n-------------")
            descriptionField.text = "\(item["info"]!)"
            selectedImg = 1
            selectDoorsButt.setTitle("\(item["doors"]!)", for: .normal)
            selectDoorsButt.setTitleColor(.black, for: .normal)
            selectedDoOrNumer = "\(item["doors"]!)"
            selectedGear = "\(item["gear"]!)"
            selectGearButt.setTitle("\(item["gear"]!)", for: .normal)
            selectGearButt.setTitleColor(.black, for: .normal)
            carNameField.text = "\(item["name"]!)"
            currentKmField.text = "\(item["kilometers"]!)"
            kmPerDayFileld.text = "\(item["kilometers_per_day"]!)"
            uploadMainImgButt.sd_setImage(with: URL(string:"\(item["photo"]!)"), for: .normal, completed: nil)
            mainImgurl = "\(item["photo"]!)"
            pricePerDayField.text = "\(item["price"]!)"
            dateFromField.text = "\(item["from"]!)"
            DateToFiel.text = "\(item["to"]!)"
            if let dict = item["brand"] as? [String:AnyObject] {
                selectBrandButt.setTitle("\(dict["name"]!)", for: .normal)
                selectBrandButt.setTitleColor(.black, for: .normal)
                selctedBrand = "\(dict["id"]!)"
            }
            if let dict = item["city"] as? [String:AnyObject] {
                selectCityButt.setTitle("\(dict["name"]!)", for: .normal)
                selectCityButt.setTitleColor(.black, for: .normal)
                SelectedCity = "\(dict["id"]!)"
            }
            if let dict = item["type"] as? [String:AnyObject] {
                selectTypeButt.setTitle("\(dict["name"]!)", for: .normal)
                selectTypeButt.setTitleColor(.black, for: .normal)
                selectedType = "\(dict["id"]!)"
            }
            if let dict = item["car_model"] as? [String:AnyObject] {
                carModelButt.setTitle("\(dict["name"]!)", for: .normal)
                carModelButt.setTitleColor(.black, for: .normal)
                selectedModel = "\(dict["id"]!)"
            }
            if let mapLat = item["map_lat"] as? String {
                lat = mapLat
            }
            if let maplng = item["map_lng"] as? String {
                long = maplng
            }
            if let photos = item["photos"] as? [String] {
                urlArray = photos
                self.imageCollectionView.isHidden = false
                self.whiteView.setHeight(height: 833)
                self.viewToGoDown.setY(y:691)
                self.getYourtPostitionButt.setY(y:898)
                self.nextButt.setY(y:971)
                self.scrollView.contentSize.height = 1036
                self.imageCollectionView.performBatchUpdates(
                    {
                        self.imageCollectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
                }, completion: { (finished:Bool) -> Void in
                })
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if edit == 1 {
            return urlArray.count + imageArr.count
        }
        return imageArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! imageCell
        cell.ButtonHandler = {()-> Void in
            if self.edit == 0 {
                self.imageArr.remove(at: indexPath.row)
            }
            else{
                if indexPath.row >= self.urlArray.count {
                    self.imageArr.remove(at: indexPath.row - self.urlArray.count)
                }else{
                    self.removeAtIndex(index: indexPath.row)
                    
                    
                }
            }
            self.imageCollectionView.performBatchUpdates(
                {
                    self.imageCollectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
            }, completion: { (finished:Bool) -> Void in
            })
        }
        if edit == 0 {
            cell.imgView.image = imageArr[indexPath.row]
        }
        else{
            if indexPath.row >= urlArray.count {
                cell.imgView.image = imageArr[indexPath.row - urlArray.count]
            }else{
                cell.imgView.sd_setImage(with: URL(string:urlArray[indexPath.row]), completed: nil)
            }
        }
        
        return cell
    }
    
    
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            pickerController.delegate = self
            self.pickerController.sourceType = UIImagePickerControllerSourceType.camera
            pickerController.allowsEditing = true
            self .present(self.pickerController, animated: true, completion: nil)
        }
        else {
            
            let alertViewController = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Ok", style: .default) { (alert) in
                
            }
            alertViewController.addAction(cancel)
            self.present(alertViewController, animated: true, completion: nil)
        }
    }
    func openGallary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            pickerController.delegate = self
            pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            pickerController.allowsEditing = true
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        if mainOrmore == 0{
            selectedImg = 1
            uploadMainImgButt.setImage(image, for: .normal)
        }
        else{
            
            imageArr.append(image)
            self.whiteView.setHeight(height: 833)
            self.viewToGoDown.setY(y:691)
            self.getYourtPostitionButt.setY(y:898)
            self.nextButt.setY(y:971)
            self.scrollView.contentSize.height = 1036
            self.imageCollectionView.performBatchUpdates(
                {
                    self.imageCollectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
            }, completion: { (finished:Bool) -> Void in
            })
            
        }
        dismiss(animated:true, completion: nil)
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        print("Cancel")
    }
    
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        place.formattedAddress
        print("xxxxxxx")
        
        lat = "\(place.coordinate.latitude)"
        long = "\(place.coordinate.longitude)"
        selectedPlace = place
        

        
        
//        GMSPlacesClient().lookUpPlaceID(placeID, callback: { (place, error) -> Void in
//            if let error = error {
//                print("lookup place id query error: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let place = place else {
//                print("No place details for \(placeID)")
//                return
//            }
//            
//            print("Place name \(place)")
//            print("Place address \(place)")
//            print("Place placeID \(place.placeID)")
//            print("Place attributions \(place.attributions)")
//        })
//        
        
        
        
    }
    
    
    func setupDropArray(suffix:String,key:String){
        var flag = 0
        
        print("getting")
        
        
        
        
        
        
        if let data = UserDefaults.standard.object(forKey: "\(suffix)\(lang)") as? NSData{
            if let dict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:AnyObject] {
                if let arr = dict[key] as? [[String : AnyObject]]{
                    flag = 1
                    switch suffix {
                    case "car_models":
                        self.carModelsArr = arr
                    case "types":
                        self.carTypArr = arr
                    case "brands":
                        self.brandsArr = arr
                    case "countries/\(countryId)/cities":
                        self.citiesArr = arr
                        
                    default:
                        break
                    }
                    
                }
            }}
        Alamofire.request("http://myrentoapp.com/api/\(suffix)?language=\(lang)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                
                
                if let dict = value as? [String:AnyObject]{
                    
                    
                    
                    
                    if flag == 0
                    {
                        if let arr = dict[key] as? [[String : AnyObject]]{
                            switch suffix {
                            case "car_models":
                                self.carModelsArr = arr
                            case "types":
                                self.carTypArr = arr
                            case "brands":
                                self.brandsArr = arr
                            case "countries/\(self.countryId)/cities":
                                self.citiesArr = arr
                                
                            default:
                                break
                            }
                        }
                        
                        
                    }
                    else{
                        
                    }
                    
                    let dat = NSKeyedArchiver.archivedData(withRootObject: dict)
                    UserDefaults.standard.set(dat, forKey: "\(suffix)\(self.lang)")
                    
                }
                
                
            // HUD.hide()
            case .failure(let error):
                print(error)
                // HUD.hide()
            }
        }
        
    }
    
    
    func configureLblForDate(textField:UITextField){
        textField.addTarget(self, action: #selector(SignUpViewController.EditingDidBeginFunction(_:)), for: UIControlEvents.editingDidBegin)
        
    }
    func EditingDidBeginFunction(_ sender : UITextField){
        sender.tintColor = .clear
        print("did begin")
        if sender.tag == 2 && dateFromField.text == "From:" {
            sender.resignFirstResponder()
            self.view.makeToast("Choose Start Date First")
        }else{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let datePickerView:UIDatePicker = UIDatePicker()
            if sender.tag == 2 {
                print("innnn")
                print(minDate)
                datePickerView.minimumDate = dateFormatter.date(from: minDate)
            }else{
                datePickerView.minimumDate  =  Date()
                
            }
            
            datePickerView.datePickerMode = UIDatePickerMode.date
            datePickerView.locale = Locale(identifier: L102Language.currentAppleLanguage())
            fiedlTag = sender.tag
            sender.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(SignUpViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
        }
    }
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        (self.view.viewWithTag(fiedlTag) as! UITextField).text = dateFormatter.string(from: sender.date)
        if fiedlTag == 1 {
            minDate = dateFormatter.string(from: sender.date)
            DateToFiel.text = ""
            
        }
        
    }
    
    
    
    func getStringsFromArr(array:[[String:AnyObject]])->[String]{
        var stringsArr = [String]()
        print(array)
        for i in 0..<array.count {
            stringsArr.append(array[i]["name"] as! String)
        }
        print(stringsArr)
        return stringsArr
    }
    func removeAtIndex(index: Int){
        let headers = ["Accept": "application/json",
                       "Authorization" : "Bearer \(token)"]
        let par = ["url":self.urlArray[index]]
        var url = "http://myrentoapp.com/api/files/delete"
        print(par)
        Alamofire.request(url, method: .post, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                if let resDict = value as? [String:AnyObject]{
                    if let erDict = resDict["message"] as? String {
                        if erDict == "deleted" {
                        self.urlArray.remove(at: index)
                        self.imageCollectionView.performBatchUpdates(
                            {
                                self.imageCollectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
                        }, completion: { (finished:Bool) -> Void in
                        })
                        }else{
                            self.view.makeToast(erDict)
                        }
                    }
                }
                HUD.hide()
            case .failure(let error):
                print(error)
                HUD.hide()
            }
        }
        
    }
    func checkCountryAndAdd(){
        HUD.show(.progress)
        let location = CLLocation(latitude: Double(lat) ?? 0.0, longitude: Double(long) ?? 0.0)
        fetchCountry(location: location) { country in
            print("country:", country)
            if countryDictionary[country] == "\(self.countryDict["key"]!)" {
                self.addCarFunc()
            }else{
                HUD.hide()
                self.view.makeToast("\(NSLocalizedString("Please Select a Location Within", comment: "")) \(self.countryDict["name"]!)")
            }
            
        }
        
    }
    func addCarFunc() {
        
        
        var photosStringArr = [String]()
        for i in 0..<imageArr.count {
            photosStringArr.append(imageArr[i].base64String())
        }
        let headers = ["Accept": "application/json",
                       "Authorization" : "Bearer \(token)"]
        let Formatter: NumberFormatter = NumberFormatter()
        Formatter.locale = Locale(identifier: "EN")
        
       // let final = Formatter.numberFromString(NumberStr)

        let par = ["country_id":countryId,
                   "city_id": SelectedCity,
                   "car_model_id":selectedModel,
                   "brand_id":selctedBrand,
                   "type_id":selectedType,
                   "name":carNameField.text!,
                   "info":descriptionField.text!,
                   "price":"\(Formatter.number(from: pricePerDayField.text!) ?? 0)",
                   "photo":uploadMainImgButt.currentImage!.base64String(),
                   "photos":photosStringArr,
                   "gear":selectedGear,
                   "doors":selectedDoOrNumer,
                   "map_lng":long,
                   "map_lat":lat,
                   "from":dateFromField.text!,
                   "to":DateToFiel.text!,
                   "kilometers":"\(Formatter.number(from: currentKmField.text!) ?? 0)",
                   "kilometers_per_day":"\(Formatter.number(from: kmPerDayFileld.text!) ?? 0)"] as [String : Any]

        print(par)
        print(headers)
        var url = "http://myrentoapp.com/api/cars"
        var httpmethod = HTTPMethod.post
        if edit == 1 {
            url = "http://myrentoapp.com/api/cars/\(item["car_id"]!)"
            httpmethod = HTTPMethod.put
        }
        
        Alamofire.request(url, method: httpmethod, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                if let resDict = value as? [String:AnyObject]{
                    if let erDict = resDict["errors"] as? [String:AnyObject] {
                        var str = ""
                        if let erArr = erDict["map_lat"] as? [String] {
                            for i in 0..<erArr.count {
                                str = str +  erArr[i]
                            }
                        }
                        if let erArr = erDict["map_lng"] as? [String] {
                            for i in 0..<erArr.count {
                                str = str + "\n" + erArr[i]
                            }
                        }
                        self.view.makeToast(str)
                    }
                    if let carDict = resDict["car"] as? [String:AnyObject] {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CarViewController") as! CarViewController
                        vc.newAddedCar = 1
                        vc.item = carDict
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    if let message = resDict["message"] as? String{
                        self.view.makeToast(message)
                        
                    }
                }
                HUD.hide()
            case .failure(let error):
                print(error)
                self.view.makeToast("something went wrong")
                HUD.hide()
            }
        }
    }
    func removeFirst(){
        let headers = ["Accept": "application/json",
                       "Authorization" : "Bearer \(token)"]
        let par = ["url":mainImgurl]
        var url = "http://myrentoapp.com/api/files/delete"
        print(par)
        Alamofire.request(url, method: .post, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                self.addCarFunc()
                HUD.hide()
            case .failure(let error):
                print(error)
                HUD.hide()
            }
        }
    }
    func setupNavBar(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
    func fetchCountry(location: CLLocation, completion: @escaping (String) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print(error)
                self.view.makeToast("Something went wrong, please try again")
                HUD.hide()
            } else if let country = placemarks?.first?.isoCountryCode {
                
                completion(country)
            }
        }
    }
    
}
