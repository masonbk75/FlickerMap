//
//  ViewController.swift
//  FlickerMap
//
//  Created by Mason Kelly on 9/10/19.
//  Copyright © 2019 Mason Kelly. All rights reserved.
//

/*
 - Add edit button to update coredata
 - Add delete coredata functionality to delete pin button
 - Fix cell width for tags
 - Save pin with tags
 - Different color for different tags
 */

import UIKit
import CoreLocation
import MapKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var menueView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var sandardButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var searchTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var searchBarButton: UIButton!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var littleView: UIView!
    @IBOutlet weak var detailName: UILabel!
    @IBOutlet weak var detailAddress: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    var numberSaved = Int()
    var pinType = Bool()
    var annotationTitle = "New Pin"
    var coverImage = UIImage()
    var pinLocation = CLLocationCoordinate2D()
    var street = String()
    var city = String()
    var zip = String()
    var country = String()
    var state = String()
    
    let locationManager = CLLocationManager()
    var menuShowing = false
    var searchShowing = false
    var detailShowing = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupMap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getSavedPins()
        super.viewDidLoad()
        URLArray.removeAll()
        navigationController?.isNavigationBarHidden = true
    }
    
    func setupView() {
        addGradient()
        leadingConstraint.constant = -180
        searchTopConstraint.constant = -130
        bottomConstraint.constant = -250
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        mapView.addGestureRecognizer(longPressRecognizer)
        
        menueView.layer.shadowColor = UIColor.black.cgColor
        menueView.layer.shadowOffset = CGSize(width: 5, height: 5)
        menueView.layer.shadowRadius = 8.0
        menueView.layer.shadowOpacity = 0.30
        menueView.layer.cornerRadius = 14
        
        buttonView.layer.shadowColor = UIColor.black.cgColor
        buttonView.layer.shadowRadius = 8.0
        buttonView.layer.shadowOpacity = 0.60
        buttonView.layer.cornerRadius = 12
        
        detailView.layer.shadowColor = UIColor.black.cgColor
        detailView.layer.shadowRadius = 8.0
        detailView.layer.shadowOpacity = 0.60
        detailView.layer.cornerRadius = 14
        
        detailImageView.layer.cornerRadius = 14
        littleView.layer.cornerRadius = 3
        
        currentLocationButton.addTarget(self, action: #selector(currentLocationPressed), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(changeMapType), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonClicked), for: .touchUpInside)
        detailButton.addTarget(self, action: #selector(showFlickerView), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deletePin), for: .touchUpInside)

        
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)

        //Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    func setupMap() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest 
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
        }
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(viewRegion, animated: true)
        }
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
    }
    
    func getSavedPins() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedPins")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data)
                let lat = data.value(forKey: "latitude") as! CLLocationDegrees
                let lon = data.value(forKey: "longitude") as! CLLocationDegrees
                let name = data.value(forKey: "name") as! String
                let customCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let customAnnotation = CustomAnnotation(coordinate: customCoordinate, title: name, image: self.coverImage, type: .saved)
                self.mapView.addAnnotation(customAnnotation)
            }
        } catch {
            print("Failed request")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func searchButtonClicked() {
        searchBarButton.alpha = 0
        cancelButton.alpha = 1.0
        buttonView.alpha = 0
        if (searchShowing) {
            searchTopConstraint.constant = -130
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        else {
            searchTopConstraint.constant = 0
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        searchShowing = !searchShowing
    }
    
    func searchLocation(text: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        searchRequest.region = mapView.region
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            for item in response.mapItems {
                print(item.placemark)
                let coordinates = item.placemark.coordinate
                let title = item.name
                let customAnnotation = CustomAnnotation(coordinate: coordinates, title: title!, image: self.coverImage, type: .unsaved)
                self.mapView.addAnnotation(customAnnotation)
            }
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
        
    }
    
    @objc func currentLocationPressed() {
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(viewRegion, animated: true)
        }
    }
    
    @objc func deletePin() {
        let annotations = self.mapView.annotations
        for _annotation in annotations {
            if let annotation = _annotation as? CustomAnnotation {
                if annotation.title == self.annotationTitle {
                    self.mapView.removeAnnotation(annotation)
                    bottomConstraint.constant = -300
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                        self.view.layoutIfNeeded()
                    }, completion: nil)
                    detailShowing = !detailShowing
                }
            }
        }
    }
    
    
    @objc func changeMapType() {
        if (menuShowing) {
            leadingConstraint.constant = -180
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        else {
            leadingConstraint.constant = 0
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
        menuShowing = !menuShowing
        
    }
    
    func showDetailView() {
        if (detailShowing) {
            bottomConstraint.constant = -300
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        else {
            bottomConstraint.constant = 0
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        detailShowing = !detailShowing
    }

    @IBAction func standardButtonPressed(_ sender: Any) {
        mapView.mapType = MKMapType.standard
        leadingConstraint.constant = -180
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        menuShowing = !menuShowing

    }
    
    @IBAction func satelliteButtonPressed(_ sender: Any) {
        mapView.mapType = MKMapType.satellite
        leadingConstraint.constant = -180
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        menuShowing = !menuShowing
    }
    
    @IBAction func hybridButtonPressed(_ sender: Any) {
        mapView.mapType = MKMapType.hybrid
        leadingConstraint.constant = -180
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        menuShowing = !menuShowing

    }

    @objc func tapped(sender: UITapGestureRecognizer) {
        if detailShowing {
            showDetailView()
        }
        buttonView.alpha = 1.0
        leadingConstraint.constant = -180
        searchTopConstraint.constant = -130
        hideKeyboard()
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        menuShowing = !menuShowing
        searchShowing = !searchShowing
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        buttonView.alpha = 1.0
        searchTopConstraint.constant = -130
        searchShowing = !searchShowing
        hideKeyboard()
    }
    
    @IBAction func searchBarButtonTapped(_ sender: Any) {
        searchLocation(text: searchTextField.text!)
        buttonView.alpha = 1.0
        searchTopConstraint.constant = -130
        searchShowing = !searchShowing
        hideKeyboard()
    }
    
    
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
        
        let customCoordinate = CLLocationCoordinate2D(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        
        let location = CLLocation(latitude: customCoordinate.latitude, longitude: customCoordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
            placemarks, error -> Void in
            guard let placeMark = placemarks?.first else { return }
            if let locationName = placeMark.name {
                print("location name: \(locationName)")
                self.annotationTitle = locationName
            }
            let customAnnotation = CustomAnnotation(coordinate: customCoordinate, title: self.annotationTitle, image: self.coverImage, type: .unsaved)
            self.mapView.addAnnotation(customAnnotation)
        })        
    }
    
    private func flickrURLFromParameters(lat: String, lon: String) -> URL {
        // Build base URL
        var components = URLComponents()
        components.scheme = Constants.FlickrURLParams.APIScheme
        components.host = Constants.FlickrURLParams.APIHost
        components.path = Constants.FlickrURLParams.APIPath
        
        // Build query string
        components.queryItems = [URLQueryItem]()
        
        // Query components
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.APIKey, value: Constants.FlickrAPIValues.APIKey))
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.SearchMethod, value: Constants.FlickrAPIValues.SearchMethod))
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.ResponseFormat, value: Constants.FlickrAPIValues.ResponseFormat))
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Extras, value: Constants.FlickrAPIValues.MediumURL))
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.SafeSearch, value: Constants.FlickrAPIValues.SafeSearch))
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.DisableJSONCallback, value: Constants.FlickrAPIValues.DisableJSONCallback))
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Latitude, value: lat))
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Longitude, value: lon))
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Radius, value: "1"))

        return components.url!
    }
    
    private func performFlickrSearch(_ searchURL: URL) {
        let session = URLSession.shared
        let request = URLRequest(url: searchURL)
        let task = session.dataTask(with: request){
            (data, response, error) in
            if (error == nil) {
                // Check response code
                let status = (response as! HTTPURLResponse).statusCode
                if (status < 200 || status > 300) {
                    self.displayAlert("Server returned an error")
                    return;
                }
                /* Check data returned? */
                guard let data = data else {
                    self.displayAlert("No data was returned by the request!")
                    return
                }
                // Parse the data
                let parsedResult: [String:AnyObject]!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
                } catch {
                    self.displayAlert("Could not parse the data as JSON: '\(data)'")
                    return
                }
                // Check for "photos" key in our result
                guard let photosDictionary = parsedResult["photos"] as? [String:AnyObject] else {
                    self.displayAlert("Key 'photos' not in \(String(describing: parsedResult))")
                    return
                }
                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                    self.displayAlert("Cannot find key 'photo' in \(photosDictionary)")
                    return
                }
                // Check number of photos
                if photosArray.count == 0 {
                    self.displayAlert("No Photos Found. Search Again.")
                    return
                } else {
                    print(photosArray.count)
                    let photoDictionary = photosArray[0] as [String: AnyObject]
                    guard let imageUrlString = photoDictionary["url_m"] as? String else {
                        self.displayAlert("Cannot find key 'url_m' in \(photoDictionary)")
                            return
                    }
                    self.fetchImage(imageUrlString);
                    for i  in 0...20 {
                        let photo = photosArray[i]
                        if let imageUrlString = photo["url_m"] as? String {
                            URLArray.append(imageUrlString)
                        }
                        else {
                            self.displayAlert("Cannot find key 'url_m' in \(photo)")
                            return
                        }
                    }
                }
                
            }
            else{
                self.displayAlert((error?.localizedDescription)!)
            }
        }
        task.resume()
    }
    
    private func fetchImage(_ url: String) {
        let imageURL = URL(string: url)
        let task = URLSession.shared.dataTask(with: imageURL!) { (data, response, error) in
            if error == nil {
                let downloadImage = UIImage(data: data!)!
                
                DispatchQueue.main.async(){
                    self.detailImageView.image = downloadImage
                    //self.pinCoverImageView.image = downloadImage
                    // coverImage is UIImage -> just a soul
                    // pinCoverImageview is UIImageView -> body
                }
            }
        }
        
        task.resume()
    }
    
    func displayAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addGradient() {
        let layer = CAGradientLayer()
        let screenSize = UIScreen.main.bounds.size
        layer.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: 165)
        layer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.8).cgColor]
        let view = UIView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.layer.addSublayer(layer)
        detailImageView.addSubview(view)
    }
    
}





extension ViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            print(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MKMarkerAnnotationView()
        guard let annotation = annotation as? CustomAnnotation else {return nil}
        var identifier = ""
        var color = UIColor.red
        switch annotation.type {
            case .saved:
                identifier = "Saved"
                color = UIColor.FlatColor.Red.Valencia
            case .unsaved:
                identifier = "Unsaved"
                self.detailButton.titleLabel?.text = "Click to save pin"
                color = .black
        }
        if let dequedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            annotationView = dequedView
        } else{
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView.markerTintColor = color
        //annotationView.glyphImage = UIImage(named: "pizza")
        annotationView.glyphTintColor = .yellow
        //annotationView.clusteringIdentifier = identifier
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        URLArray.removeAll()
        self.detailImageView.image = UIImage()
        self.annotationTitle = ((view.annotation?.title)!)!
        if let pin = view.annotation as? CustomAnnotation {
            if pin.type == .saved {
                self.pinType = true
            } else {
                self.pinType = false
            }
        }
        let customCoordinate = view.annotation?.coordinate
        let location = CLLocation(latitude: customCoordinate!.latitude, longitude: customCoordinate!.longitude)
        self.pinLocation = customCoordinate!
        
        let searchURL = self.flickrURLFromParameters(lat: String(customCoordinate!.latitude), lon: String(customCoordinate!.longitude))
        print("URL: \(searchURL)")
        self.performFlickrSearch(searchURL)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
            placemarks, error -> Void in
            guard let placeMark = placemarks?.first else { return }
            if let locationName = placeMark.name {
                print("location name: \(locationName)")
                self.detailName.text = locationName
            }
            if let street = placeMark.thoroughfare {
                self.street = street
            }
            if let city = placeMark.subAdministrativeArea {
                self.city = city
            }
            if let state = placeMark.administrativeArea {
                self.state = state
            }
            if let country = placeMark.isoCountryCode {
                self.country = country
            }
            if let zip = placeMark.postalCode {
                self.zip = zip
            }
            self.detailAddress.text = "\(self.street), \(self.city), \(self.state) \(self.zip), \(self.country)"
            print(self.detailAddress.text!)
        })
        
        showDetailView()
    }
    
    
    @objc func showFlickerView() {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FlickerViewController") as! FlickerViewController

        print(self.pinLocation)
        FlickerViewController.type = self.pinType
        FlickerViewController.pinLocation = self.pinLocation
        navigationController?.pushViewController(controller, animated: true)
    }
    
}



extension ViewController:  UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchLocation(text: searchTextField.text!)
        buttonView.alpha = 1.0
        searchTopConstraint.constant = -130
        searchShowing = !searchShowing
        hideKeyboard()
        return true
    }
    
    func hideKeyboard() {
        searchTextField.resignFirstResponder()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if searchTextField.text != "" {
            cancelButton.alpha = 0.0
            searchBarButton.alpha = 1.0
        }
        else {
            cancelButton.alpha = 1.0
            searchBarButton.alpha = 0
        }
    }
    
    @objc func keyboardDidChange(notification: Notification) {
        
    }
        

}


// add option to delete all custome pins or  all searched pins
// Change the padding in images collection view
// save images and pins into CoreData
// after use pure CoreData -> search a pod to use CoreData
// Serach location







//        if !(annotation is CustomAnnotation) {
//            return nil
//        }
//        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
//
//        if annotationView == nil {
//            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Marker")
//            //annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
//            annotationView?.canShowCallout = true
//        } else {
//            annotationView!.annotation = annotation
//        }
//
//        let customAnnotation = annotation as! CustomAnnotation
//
//        let button = UIButton(frame: CGRect(x: 0, y: 205, width: 165, height: 30))
//        button.backgroundColor = .darkGray
//        button.setTitle("Click to see more", for: .normal)
//        button.addTarget(self, action: #selector(showFlickerView), for: .touchUpInside)
//
//        let deleteButton = UIButton(frame: CGRect( x: 169, y: 205, width: 30, height: 30))
//        deleteButton.backgroundColor = .red
//        deleteButton.setImage(UIImage(named: "delete-button"), for: .normal)
//        deleteButton.addTarget(self, action: #selector(deletePins), for: .touchUpInside)
//
//        let pinCoverImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
//        pinCoverImageView.backgroundColor = .gray
//        pinCoverImageView.image = self.coverImage
//        self.pinCoverImageView = pinCoverImageView
//        self.pinLocation = customAnnotation.coordinate
//
//        let detailAnnotationView = UIView()
//        detailAnnotationView.addSubview(pinCoverImageView)
//        detailAnnotationView.addSubview(button)
//        detailAnnotationView.addSubview(deleteButton)
//        let widthConstraint = NSLayoutConstraint(item: detailAnnotationView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
//        detailAnnotationView.addConstraint(widthConstraint)
//        let heightConstraint = NSLayoutConstraint(item: detailAnnotationView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 238)
//        detailAnnotationView.addConstraint(heightConstraint)
//
//        annotationView?.detailCalloutAccessoryView = detailAnnotationView
//
//
//        selectedAnnotation = annotationView
//        return annotationView
