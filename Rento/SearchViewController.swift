//
//  SearchViewController.swift
//  Rento
//
//  Created by mouhammed ali on 8/29/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import RangeSeekSlider
import Alamofire
import DropDown
import GooglePlacePicker
class SearchViewController: UIViewController,GMSPlacePickerViewControllerDelegate {
    var selectedPricePerDay = ""
    var SelectedCity = ""
    var selectedModel = ""
    var selectedType = ""
    var selctedBrand = ""
    var selectedDoOrNumer = ""
    var selectedGear = ""
    var long = ""
    var lat = ""
    var citiesArr = [[String:AnyObject]]()
    var carModelsArr = [[String:AnyObject]]()
    var minDate = ""
    var fieldTag = 0
    var countryId = 0
    var lang = ""
    var brandsArr = [[String:AnyObject]]()
    var carTypArr = [[String:AnyObject]]()
    @IBOutlet var carNameLbl: UITextField!
    @IBOutlet var ownerNameLbl: UITextField!
    @IBOutlet var carKmSlider: RangeSeekSlider!
    @IBOutlet var startDateField: UITextField!
    @IBAction func locationSelected(_ sender: Any) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    @IBOutlet var locationButt: UIButton!
    @IBOutlet var endDateField: UITextField!
    @IBOutlet var selectedCityButt: UIButton!
    @IBOutlet var pricePerDayLabel: UITextField!
    @IBOutlet var allowedKmSlider: RangeSeekSlider!
    let dropdown = DropDown()
    @IBAction func selectCity(_ sender: Any) {
        dropdown.direction = .bottom
        dropdown.anchorView = selectedCityButt
        dropdown.dataSource = getStringsFromArr(array: citiesArr)
        dropdown.width = selectedCityButt.frame.width
        dropdown.contentMode = .center
        dropdown.bottomOffset = CGPoint(x:0,y:self.selectedCityButt.frame.height+1)
        dropdown.show()
        dropdown.selectionAction = {[unowned self](index: Int, item: String) in
            self.selectedCityButt.setTitle(item, for: .normal)
            self.selectedCityButt.setTitleColor(.black, for: .normal)
            self.SelectedCity = "\(self.citiesArr[index]["city_id"]!)"
            
        }
    }
    
    @IBOutlet var selectModelButt: UIButton!
    @IBAction func selectModel(_ sender: Any) {
        dropdown.direction = .bottom
        dropdown.anchorView = selectModelButt
        dropdown.dataSource = getStringsFromArr(array: carModelsArr)
        dropdown.width = selectModelButt.frame.width
        dropdown.contentMode = .center
        dropdown.bottomOffset = CGPoint(x:0,y:self.selectModelButt.frame.height+1)
        dropdown.show()
        dropdown.selectionAction = {[unowned self](index: Int, item: String) in
            self.selectModelButt.setTitle(item, for: .normal)
            self.selectModelButt.setTitleColor(.black, for: .normal)
            self.selectedModel = "\(self.carModelsArr[index]["car_model_id"]!)"
            
        }
    }
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
    
    @IBAction func didendPricePerDay(_ sender: Any) {
        
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        if startDateField.text != "" {
            if endDateField.text != "" {
                search()
            }else{
                self.view.makeToast("Please Enter An End Date")
            }
        }else{
            search()
        }
        
        
        
    }
    
    override func viewDidLoad() {
        self.title = NSLocalizedString("FILTER SEARCH", comment: "")
        locationButt.titleLabel?.numberOfLines = 0
        locationButt.titleLabel?.textAlignment = .center
        setupNavBar()
        configureLblForDate(textField: startDateField)
        configureLblForDate(textField: endDateField)
        super.viewDidLoad()
        
        if let data = UserDefaults.standard.object(forKey: "selectedCountry") as? NSData{
            if let item = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:AnyObject] {
            
            //print(cityyy:\(item["city_id"]))
            countryId = item["country_id"] as! Int
            
            }
        }
        if let langString = UserDefaults.standard.object(forKey: "language") as? String {
            lang = langString
        }
        setupDropArray(suffix: "car_models", key:"car_models")
        setupDropArray(suffix: "types", key:"types")
        setupDropArray(suffix: "brands", key:"brands")

        setupDropArray(suffix: "countries/\(countryId)/cities", key: "cities")
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            print(userDict)
            
        }
        
        allowedKmSlider.numberFormatter.positiveSuffix = "KM"
        carKmSlider.numberFormatter.positiveSuffix = "KM"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
        
        if sender.tag == 2 && startDateField.text == "" {
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
            fieldTag = sender.tag
            sender.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(SignUpViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
        }
    }
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        (self.view.viewWithTag(fieldTag) as! UITextField).text = dateFormatter.string(from: sender.date)
        if fieldTag == 1 {
            minDate = dateFormatter.string(from: sender.date)
            endDateField.text = ""
        }
        
    }

    func search(){
        let url = "http://myrentoapp.com/api/cars?doors=\(selectedDoOrNumer)&owner=\(ownerNameLbl.text!)&name=\(carNameLbl.text!)&city_id=\(SelectedCity)&brand_id=\(selctedBrand)&car_model_id=\(selectedModel)&type_id=\(selectedType)&kilometers_start=\(carKmSlider.minValue)&kilometers_end=\(carKmSlider.maxValue)&kilometers_per_day_start=\(allowedKmSlider.minValue)&kilometers_per_day_end=\(allowedKmSlider.maxValue)&gear=\(selectedGear)&price=\(pricePerDayLabel.text!)&from=\(startDateField.text!)&to=\(endDateField.text!)&lng=\(long)&lat=\(lat)"
        let urlToSend = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        print("lllllll\(url)")
        let view = storyboard?.instantiateViewController(withIdentifier: "CarsTableViewController") as! CarsTableViewController
        view.search = 1
        view.searchUrl = urlToSend!
        self.navigationController?.pushViewController(view, animated: true)
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

    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
       print(place.addressComponents)
        var str = ""
        if let address = place.addressComponents {
            
            
            for i in 0..<address.count {
                str = str + address[i].name
            }
            print(str)
            
            locationButt.setTitle(str, for: .normal)
          
            
        }
        locationButt.setTitleColor(.black, for: .normal)
        if str == "" {
            locationButt.setTitle("\(place.coordinate.latitude) - \(place.coordinate.longitude)", for: .normal)
        }
        lat = "\(place.coordinate.latitude)"
        long = "\(place.coordinate.longitude)"
        
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
    
    
}
