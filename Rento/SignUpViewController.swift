//
//  SignUpViewController.swift
//  Rento
//
//  Created by mouhammed ali on 8/18/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import DropDown
import Toast_Swift
import BEMCheckBox
import SDWebImage
class SignUpViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func termsButtPressed(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PDFWebVC") as! PDFWebVC
        vc.PDFName = NSLocalizedString("Terms And Conditions", comment: "")
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var birthDateField: UITextField!
    @IBOutlet weak var uploadPhotoButt: UIButton!
    @IBOutlet weak var uploadIDButt: UIButton!
    @IBOutlet weak var chooseCityButt: UIButton!
    var countryId = 0
    var selectedImg = 0
    var selectedID = 0
    var selectedSelfie = 0
    var photoOrId = 0
    var lang = ""
    var urlToRemove = ""
    @IBOutlet var termsButton: UIButton!
    @IBOutlet var acceptTerms: BEMCheckBox!
    @IBOutlet var termsButt: UIButton!
    @IBOutlet var newPasswordField: UITextField!
    @IBOutlet var containerView: UIView!
    var userDict = [String:AnyObject]()
    var edit = 0
    var cityArr = [[String:AnyObject]]()
    var cityName = [String]()
    var selectedCity = "-1"
    let dropdown = DropDown()
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var notificationButt: UIButton!
    
    @IBOutlet var signInButt: UIButton!
    
    @IBAction func uploadSelfie(_ sender: UIButton) {
        photoOrId = sender.tag
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
    
    @IBOutlet var uploadSelfieButt: UIButton!
    @IBOutlet var titleGrey: UILabel!
    var pickerController = UIImagePickerController()
    @IBAction func chooseCity(_ sender: Any) {
        dropdown.direction = .bottom
        dropdown.anchorView = chooseCityButt
        dropdown.dataSource = cityName
        dropdown.width = chooseCityButt.frame.width
        dropdown.contentMode = .center
        dropdown.bottomOffset = CGPoint(x:0,y:self.chooseCityButt.frame.height+1)
        dropdown.show()
        dropdown.selectionAction = {[unowned self](index: Int, item: String) in
            self.chooseCityButt.setTitle(item, for: .normal)
            self.chooseCityButt.setTitleColor(.black, for: .normal)
            self.selectedCity = "\(self.cityArr[index]["city_id"]!)"
            
        }
        
    }
    @IBAction func uploadPhoto(_ sender: UIButton) {
        photoOrId = sender.tag
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
    
    
    @IBAction func backButt(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func next(_ sender: Any) {
        if edit == 1 {
            if chooseCityButt.currentTitle != NSLocalizedString("Choose City", comment: "") {
                updateInfo() }else{
                self.view.makeToast(NSLocalizedString("Please Select a City", comment: ""))
            }
        }else{
            
            print(acceptTerms.on)
            
            if nameField.text != "" && mailField.text !=  "" && passwordField.text != "" && phoneNumberField.text != "" && birthDateField.text != "" && chooseCityButt.currentTitle != "Choose City" && selectedImg == 1 && selectedID == 1 && selectedSelfie == 1 {
                if acceptTerms.on == false {
                    self.view.makeToast("You Have To Accept The Terms And Conditions")
                }else{
                    signUp()}
            }else{
                self.view.makeToast("Please Fill In All the Fields")
            }
        }
    }
    
    
    var selectedCountry = [String:AnyObject]()
    override func viewDidLoad() {
        
        if L102Language.currentAppleLanguage() == "ar" {
            termsButt.setTitle("الموافقة علي الشروط و الأحكتم", for: .normal)
            uploadPhotoButt.setImage(UIImage(named:"uploadar"), for: .normal)
            uploadIDButt.setImage(UIImage(named:"uploadarId"), for: .normal)
            uploadSelfieButt.setImage(UIImage(named:"upload selfie ar"), for: .normal)
            
        }
        self.title = NSLocalizedString("EDIT PROFILE", comment: "")
        if edit == 0 {
            self.title = NSLocalizedString("CREATE PROFILE", comment: "")
            containerView.setHeight(height: 454)
        }
        super.viewDidLoad()
        
        configureLblForDate(textField: birthDateField)
        if let langString = UserDefaults.standard.object(forKey: "language") as? String {
            lang = langString
        }
        if let data = UserDefaults.standard.object(forKey: "selectedCountry") as? NSData{
            if let item = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:AnyObject] {
            selectedCountry = item
            if let numberKey = item["key"] as? String {
                print(numberKey)
                phoneNumberField.text = "\(numberKey)-"
            }
            if let id = item["country_id"] as? Int {
                print(id)
                countryId = id
            }
            self.getCities()
            }}
        if edit == 1 {
            termsButt.isHidden = true
            acceptTerms.isHidden = true
            
            
            signInButt.isHidden = true
            scrollView.contentSize = CGSize(width: 320, height: 700)
            //notificationButt.isHidden = false
            
            titleGrey.text = NSLocalizedString("Edit Your \n Profile", comment: "")
            if let user = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
                userDict = user
                getUser()
            }
            
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getCities(){
        var flag = 0
        HUD.show(.progress)
        print("getting")
        
        var method = HTTPMethod.get
        var par = [String:String]()
        
        // HUD.show(.progress)
        if let data = UserDefaults.standard.object(forKey: "cities\(countryId)\(lang)") as? NSData{
            if let dict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:AnyObject] {
                if let array = dict["cities"] as? [[String : AnyObject]]{
                    flag = 1
                    self.cityArr = array
                    for i in 0..<array.count {
                        self.cityName.append(array[i]["name"] as! String)
                    }
                }
                
            }}
        Alamofire.request("http://myrentoapp.com/api/countries/\(countryId)/cities?language=\(lang)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                
                
                if let dict = value as? [String:AnyObject]{
                    
                    
                    
                    
                    if flag == 0
                    {
                        if let array = dict["cities"] as? [[String : AnyObject]]{
                            self.cityArr = array
                            for i in 0..<array.count {
                                self.cityName.append(array[i]["name"] as! String)
                            }
                        }
                    HUD.hide()
                        
                    }
                    
                    
                    let dat = NSKeyedArchiver.archivedData(withRootObject: dict)
                    UserDefaults.standard.set(dat, forKey: "cities\(self.countryId)\(self.lang)")
                    
                }
                
                
             HUD.hide()
            case .failure(let error):
                print(error)
                
                 HUD.hide()
            }
        }
        
  
        
    }
    func getCityWithId(id:String)->String{
        for i in 0..<cityArr.count {
            let item = cityArr[i]
            if "\(item["city_id"]!)" == id {
                return "\(item["name"]!)"
            }
        }
        return NSLocalizedString("Choose City", comment: "")
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            pickerController.delegate = self
            self.pickerController.sourceType = UIImagePickerControllerSourceType.camera
            pickerController.allowsEditing = true
            self .present(self.pickerController, animated: true, completion: nil)
        }
        else {
            //   let alertWarning = UIAlertView(title:"Warning", message: "You don't have camera", delegate:nil,
            //cancelButtonTitle:"OK", otherButtonTitles:"")
            //   alertWarning.show()
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
            self.pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            pickerController.allowsEditing = true

            self .present(self.pickerController, animated: true, completion: nil)

            
            //self.present(pickerController, animated: true, completion: nil)
        }
    }
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        if photoOrId == 0{
            selectedImg = 1
            uploadPhotoButt.setImage(image, for: .normal)
        }
        else if photoOrId == 1{
            selectedID = 1
            uploadIDButt.setImage(image, for: .normal)
        }
        else {
           selectedSelfie = 1
            uploadSelfieButt.setImage(image, for: .normal)
        }
        dismiss(animated:true, completion: nil)
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        print("Cancel")
    }
    func signUp(){
        HUD.show(.progress)
        let par = ["name":nameField.text!,
                   "email":mailField.text!,
                   "password":passwordField.text!,
                   "city_id":self.selectedCity,
                   "phone":phoneNumberField.text!,
                   "id_image":uploadIDButt.currentImage!.base64String(),
                   "avatar":uploadPhotoButt.currentImage!.base64String(),
                   "license_image":(uploadSelfieButt.currentImage ?? UIImage()).base64String(),
                   "birthday":birthDateField.text!,
                   "locale":lang,
                   "one-signal-player-id":UserDefaults.standard.string(forKey: "onesignalid")!
            
            ] as [String : Any]
        Alamofire.request("http://myrentoapp.com/api/register", method: .post, parameters: par, encoding: URLEncoding.default, headers: ["Accept":"application/json"]).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                HUD.hide()
                print(value)
              
                if let dict = value as? [String:AnyObject] {
                    if let error = dict["errors"] as? [String:AnyObject] {
                        if let erMsg = error["email"] as? String {
                            self.view.makeToast(erMsg)
                            return
                        }
                    if let erMsg = error["email"] as? [String] {
                        var er = ""
                        for i in 0..<erMsg.count {
                            er = er + erMsg[i]
                            if i != erMsg.count - 1 {
                                er = er + "\n"
                            }
                        }
                        self.view.makeToast(er)
                        return
                        }}
                    if let user = dict["user"] as? [String:AnyObject] {
                        self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier: "WaitVerificartionViewController"))!, animated: true)
                    }
                }
                
            case .failure(let error):
                print(error)
                
                HUD.hide()
            }
        }
    }
    func updateInfo(){
        
        HUD.show(.progress)
        var par = ["name":nameField.text!,
                   "email":mailField.text!,
                   "city_id":self.selectedCity,
                   "phone":phoneNumberField.text!,
                   "id_image":uploadIDButt.currentImage!.base64String(),
                   "avatar":uploadPhotoButt.currentImage!.base64String(),
                   "license_image":(uploadSelfieButt.currentImage ?? UIImage()).base64String(),
                   "birthday":birthDateField.text!,
                   "locale":lang
            
            ] as [String : Any]
        if passwordField.text != "" {
            par["password"] = passwordField.text!
            if newPasswordField.text == "" {
                self.view.makeToast("Please Enter Your New Password")
                HUD.hide()
                
                return
            }
            par["new_password"] = newPasswordField.text!
        }
        let headers = ["Accept": "application/json",
                       "Authorization" :"Bearer \(userDict["token"]!)"]
        Alamofire.request("http://myrentoapp.com/api/profile/update", method: .put, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                HUD.hide()
                print(value)
                if let dict = value as? [String:AnyObject] {
                    
                    if let user = dict["user"] as? [String:AnyObject] {
                        UserDefaults.standard.set(user, forKey: "user")
                        self.view.makeToast(NSLocalizedString("Information Was Edited Sucessfully", comment: "") )
                        SDImageCache.shared().removeImage(forKey: "\(user["avatar"]!)", withCompletion: nil)
                        
                        let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
                        self.view.isUserInteractionEnabled = false
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                    }
                    if let errorsDict = value as? [String:AnyObject] {
                        if let errors = errorsDict["errors"] as? [String:AnyObject]{
                            if let message = errors["name"] as? String {
                                self.view.makeToast(message)
                            }
                            if let message = errors["email"] as? String {
                                self.view.makeToast(message)
                            }
                            if let message = errors["city_id"] as? String {
                                self.view.makeToast(message)
                            }
                            if let message = errors["phone"] as? String {
                                self.view.makeToast(message)
                            }
                            if let message = errors["password"] as? String {
                                self.view.makeToast(message)
                            }
                            if let message = errors["id_image"] as? String {
                                self.view.makeToast(message)
                            }
                            if let message = errors["avatar"] as? String {
                                self.view.makeToast(message)
                            }
                            if let message = errors["birthday"] as? String {
                                self.view.makeToast(message)
                            }}
                    }
                }
                
            case .failure(let error):
                print(error)
                
                HUD.hide()
            }
        }
    }
    
    func configureLblForDate(textField:UITextField){
        textField.addTarget(self, action: #selector(SignUpViewController.EditingDidBeginFunction(_:)), for: UIControlEvents.editingDidBegin)
        
    }
    func EditingDidBeginFunction(_ sender : UITextField){
        print("did begin")
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.locale = Locale(identifier: L102Language.currentAppleLanguage())
        sender.tag = 1000
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(SignUpViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        (self.view.viewWithTag(1000) as! UITextField).text = dateFormatter.string(from: sender.date)
        
    }
    
    func getUser(){
        HUD.show(.progress)
        var headers = [String:String]()
        if edit == 1 {
            headers = ["Accept" : "application/json",
                       "Authorization" :"Bearer \(userDict["token"]!)"]
        }
        let url = "http://myrentoapp.com/api/users/\(userDict["user_id"]!)"
        print(url)
        Alamofire.request(url , method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                if let resResponse = value as? [String:AnyObject]{
                    if let resDict = resResponse["user"] as? [String:AnyObject] {
                        /*UIImagePickerControllerDelegate, UINavigationControllerDelegate {
                         @IBOutlet weak var nameField: UITextField!
                         @IBOutlet weak var mailField: UITextField!
                         @IBOutlet weak var passwordField: UITextField!
                         @IBOutlet weak var phoneNumberField: UITextField!
                         @IBOutlet weak var birthDateField: UITextField!
                         @IBOutlet weak var uploadPhotoButt: UIButton!
                         @IBOutlet weak var uploadIDButt: UIButton!
                         @IBOutlet weak var chooseCityButt: UIButton!*/
                        
                        self.nameField.text = "\(self.userDict["name"]!)"
                        self.mailField.text = "\(self.userDict["email"]!)"
                        self.phoneNumberField.text = "\(resDict["phone"]!)"
                        self.birthDateField.text = "\(self.userDict["bitrhday"]!)"
                        SDImageCache.shared().removeImage(forKey: "\(resDict["id_image"]!)", withCompletion: nil)
                        SDImageCache.shared().removeImage(forKey: "\(resDict["license_image"] ?? "" as AnyObject)", withCompletion: nil)

                        SDImageCache.shared().removeImage(forKey: "\(resDict["avatar"]!)", withCompletion: nil)
                        self.uploadIDButt.sd_setImage(with: URL(string:"\(resDict["id_image"]!)"), for: .normal, completed: nil)
                        self.uploadSelfieButt.sd_setImage(with: URL(string:"\(resDict["license_image"] ?? "" as AnyObject)"), for: .normal, completed: nil)
                        self.uploadPhotoButt.sd_setImage(with: URL(string:"\(resDict["avatar"]!)"), for: .normal, completed: nil)
                        self.selectedCity = "\(self.userDict["city_id"]!)"
                        print("xxxxxxxxxxx")
                        print(self.selectedCity)
                        self.chooseCityButt.setTitle(self.getCityWithId(id: "\(self.selectedCity)"), for: .normal)
                        self.chooseCityButt.setTitleColor(.black, for: .normal)
                        
                    }
                    
                }
                HUD.hide()
            case .failure(let error):
                print(error)
                
                HUD.hide()
                
            }
        }
        
        
    }
    
}
extension UIImage {
    func base64String() -> String{
        let imageData: NSData = UIImageJPEGRepresentation(self, 0.1)! as NSData
        let str = imageData.base64EncodedString(options: .lineLength64Characters)
        return str
    }
}
