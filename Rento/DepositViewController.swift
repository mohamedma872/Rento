//
//  WirhdrawViewController.swift
//  Rento
//
//  Created by mouhammed ali on 9/5/17.
//  Copyright © 2017 mouhammed ali. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import Toast_Swift
@available(iOS 12.0, *)
class DepositViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var bankLbl: UILabel!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var numberLbl: UILabel!
    @IBOutlet var bankField: UITextField!
    @IBOutlet var bankNameField: UITextField!
    @IBOutlet var accountNumberField: UITextField!
    @IBOutlet var transferCashField: UITextField!
    @IBOutlet var notesField: UITextField!
    var token = ""
    @IBOutlet var paypal: UIButton!
    @IBAction func deposit(_ sender: UIButton) {
        if bankField.text != "" && bankNameField.text != "" && accountNumberField.text != "" && transferCashField.text != "" && notesField.text != "" && uploaded == 1 {
            depositFunc()
        }else{
            self.view.makeToast("Please Fill In All The Indormation")
        }
    }
    @IBOutlet var uploadedImageView: UIImageView!
    @IBAction func uploadImage(_ sender: Any) {
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
        alertViewController.popoverPresentationController?.sourceRect = (sender as AnyObject).frame
        self.present(alertViewController, animated: true, completion: nil)
    }
    var uploaded = 0
    var pickerController = UIImagePickerController()
    override func viewDidLoad() {
        setupNavBar()
        getInfo()
        self.title = NSLocalizedString("RECHARGE", comment: "")
        super.viewDidLoad()
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            token = userDict["token"] as! String
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        uploaded = 1
        uploadedImageView.image = image
        
        dismiss(animated:true, completion: nil)
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        print("Cancel")
    }
    func getInfo(){
        //        let headers = ["Accept": "application/json",
        //                       "X-ACCESS-TOKEN" : "Bearer \(token)"]
        
        Alamofire.request("http://myrentoapp.com/api/info", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                if let resResponse = value as? [String:AnyObject]{
                    if let resDict = resResponse["app"] as? [String:AnyObject] {
                        if let bankNameString = resDict["bank_name"] as? String {
                            self.bankLbl.text = bankNameString
                        }
                        if let accountNameString = resDict["account_name"] as? String {
                            self.nameLbl.text = accountNameString
                        }
                        self.numberLbl.text = "\(resDict["account_number"]!)"
                        
                        if let message = resDict["message"] as? String{
                            self.view.makeToast(message)
                        }
                    }
                }
                HUD.hide()
            case .failure(let error):
                print(error)
                
            }
        }
        
    }
    func depositFunc(){
        HUD.show(.progress)
        let headers = ["Accept": "application/json",
                       "Authorization" : "Bearer \(token)"]
        /*     params.put("balance", Deposit.this.transfer_cash.getText().toString());
         params.put("bank_name", Deposit.this.bank_name_edit.getText().toString());
         params.put("account_name", Deposit.this.user_name_edit.getText().toString());
         params.put("account_number", Deposit.this.account_number.getText().toString());
         params.put("image", Deposit.this.encodedImage);*/
        let par = ["type":"deposit",
                   "bank_name":bankNameField.text!,
                   "account_name": bankNameField.text!,
                   "account_number":accountNumberField.text!,
                   "balance": transferCashField.text!,
                   "image":uploadedImageView.image!.base64String()]
        Alamofire.request("http://myrentoapp.com/api/users/balance/recharge", method: .post, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                
                if let resResponse = value as? [String:AnyObject]{
                    
                    
                    if let message = resResponse["message"] as? String{
                        self.view.makeToast(message)
                        self.navigationController?.popViewController(animated: true)
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
