import UIKit
import GoogleMaps
import XLPagerTabStrip
import Alamofire
import PKHUD
import SDWebImage
class MapViewController: UIViewController,GMSMapViewDelegate,IndicatorInfoProvider,CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    var map:GMSMapView!
    var longitudes:[Double]!
    var latitudes:[Double]!
    var architectNames:[String]!
    var completedYear:[String]!
    var carsArr = [[String:AnyObject]]()
    var lang = ""
    var token = ""
    var currency = ""
    override func viewDidAppear(_ animated: Bool) {
        
       
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        getCars()
    }
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.logOut(_:)), name: NSNotification.Name(rawValue: "logout"), object: nil)
        if let currencyDict = UserDefaults.standard.object(forKey: "") as? [String:AnyObject]{
            currency = "\(currencyDict["currency"]!)"
        }
        if let langString = UserDefaults.standard.object(forKey: "language") as? String {
            lang = langString
        }

        //

        self.map = GMSMapView(frame: self.view.frame)
        map.isMyLocationEnabled = true
        map.settings.myLocationButton = true
        self.view.addSubview(self.map)
        self.map.delegate = self
        if let userDict = UserDefaults.standard.object(forKey: "user") as? [String:AnyObject] {
            token = userDict["token"] as! String
            getCars()
        }
    }
    //Mark GMSMapViewDelegate Start
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let index:Int! = Int(marker.accessibilityLabel!)
        let CustomMapCell = Bundle.main.loadNibNamed("CustomMapCell", owner: self, options: nil)?[0] as! CustomMapCell
        let item = carsArr[index]

        
        CustomMapCell.carMake.text = "\(item["name"]!)"
        if let countryDict = item["country"] as? [String:AnyObject]{
            CustomMapCell.location.text = "\(countryDict["name"]!)"}
        if let typeDict = item["type"] as? [String:AnyObject]{
            CustomMapCell.carType.text = "\(typeDict["name"]!)"}
        if let modelDict = item["car_model"] as? [String:AnyObject]{
            CustomMapCell.carModel.text = "\(modelDict["name"]!)"}
        CustomMapCell.numberOfDoors.text = "\(item["doors"]!) Doors"
        CustomMapCell.gearType.text = "\(item["gear"]!)"
        CustomMapCell.price.text = "\(item["price"]!) \(currency)"
        if let userDict = item["user"] as? [String:AnyObject]{
            CustomMapCell.userName.text = "\(userDict["name"]!)"
            CustomMapCell.userAd.text = "\(userDict["country"]!),\(userDict["city"]!)"
            CustomMapCell.userAvatar.sd_setImage(with: URL(string:"\(userDict["avatar"]!)"), completed: nil)
            
        }
        CustomMapCell.image.sd_setImage(with: URL(string:"\(item["photo"]!)" ), completed: nil)
        print(item["photo"])
        
      return CustomMapCell
    }

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        //Push to car details
        let index:Int! = Int(marker.accessibilityLabel!)
        let vc = storyboard?.instantiateViewController(withIdentifier: "CarViewController") as! CarViewController
        vc.item = carsArr[index]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //Mark GMSMapViewDelegate End
    
    
    //Handle Logout
    func logOut(_ notification: NSNotification) {
        HUD.show(.progress)
        let headers = ["Accept": "application/json"]
        
        let par = ["one_signal_player_id":UserDefaults.standard.string(forKey: "onesignalid")!
        ]
        Alamofire.request("http://myrentoapp.com/api/logout", method: .get, parameters: par, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                if let resResponse = value as? [String:AnyObject]{
                    if let doneMessage = resResponse["message"] as? String{
                        if doneMessage == "done" {
                            
                            UserDefaults.standard.removeObject(forKey: "user")
                            
                            
                            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "LanguageSelectionViewController") as! LanguageSelectionViewController
                            let navController = UINavigationController(rootViewController: VC1)
                            
                            self.present(navController, animated:true, completion: nil)
                            
                        }
                    }
                }
                
                HUD.hide()
            case .failure(let error):
                print(error)
                HUD.hide()
                //self.view.makeToast(error.localizedDescription)
            }
        }
    }
    //Fetch Cars
    func getCars(){
        var flag = 0
        HUD.show(.progress)
        let headers = ["Accept": "application/json",
                       "Authorization" : "Bearer \(token)"]

        print("getting")
        let url = "http://myrentoapp.com/api/cars"
       
        var method = HTTPMethod.get
        var par = [String:String]()
        
        // HUD.show(.progress)
        if let data = UserDefaults.standard.object(forKey:url) as? NSData{
            if let dict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:AnyObject] {
                if let carsDict = dict["cars"]{
                    if let array = carsDict["data"] as? [[String : AnyObject]]{
                        
                        flag = 1
                        self.carsArr = array
                        self.reloadMap()
                        HUD.hide()
                        
                    }}
            }}
        Alamofire.request("\(url)?language=\(lang)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            switch(response.result) {
                
                
            case .success(let value):
                print(value)
                
                
                if let dict = value as? [String:AnyObject]{
                    
                    print(dict)
                    
                    
                    if flag == 0
                    {
                        if let carsDict = dict["cars"]{
                            if let array = carsDict["data"] as? [[String : AnyObject]]{
                                self.carsArr = array
                                self.reloadMap()
                            }
                            HUD.hide()
                            
                        }}
                    else{
                        
                    }
                    
                    let dat = NSKeyedArchiver.archivedData(withRootObject: dict)
                    UserDefaults.standard.set(dat, forKey: "cars\(self.lang)0")
                    
                }
                
                
                HUD.hide()
            case .failure(let error):
                print(error)
                HUD.hide()
            }
        }
    }
    //Update Map with Cars
    func reloadMap() {
        for i in 0..<carsArr.count {
            let item = carsArr[i]
            
            let coordinates = CLLocationCoordinate2D(latitude: Double("\(item["map_lat"]!)")!, longitude:Double("\(item["map_lng"]!)")!)
            let marker = GMSMarker(position: coordinates)
            marker.icon = UIImage(named: "carSmall")
            marker.map = self.map
            
            marker.groundAnchor =  CGPoint(x: 0.5,y: 0.1)
            marker.accessibilityLabel = "\(i)"
            
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last

   
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude,
                                              longitude: userLocation!.coordinate.longitude, zoom: 13.0)
       
        map.camera = camera
        
        map.settings.compassButton = true
        locationManager.stopUpdatingLocation()
    }

    
    //MARK XLPagerTabStrip Delegate
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title:  NSLocalizedString("IN MAP", comment: ""))
    }
        
}
