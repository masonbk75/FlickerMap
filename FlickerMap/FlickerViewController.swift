//
//  FlickerViewController.swift
//  FlickerMap
//
//  Created by Mason Kelly on 9/10/19.
//  Copyright © 2019 Mason Kelly. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

var URLArray = [String]()

class FlickerViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var createNewTagButton: UIButton!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var savedTagsCollectionView: UICollectionView!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    let locationManager = CLLocationManager()

    static var pinLocation = CLLocationCoordinate2D()
    static var type = Bool()
    var latitude = Double()
    var longitude = Double()
    var name = String()
    var street = String()
    var city = String()
    var zip = String()
    var country = String()
    var state = String()
    
    var tagList = [String]()
    var tagWidth = [Float]()
    var savedTagList = ["Bar", "Drinks", "Friends", "Hotel", "Lunch", "Nice", "Park", "Restaurant", "Rooftop", "Shopping", "Sushi", "View", "Outdoors", "To try"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupMap()
        getLocationInfo()
    }
    
    func setupView() {
        navigationController?.isNavigationBarHidden = false

        collectionView.delegate = self
        collectionView.dataSource = self
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
        savedTagsCollectionView.delegate = self
        savedTagsCollectionView.dataSource = self
        
        let rightBarButtonSave = UIBarButtonItem(title: "Save Pin", style: .plain, target: self, action: #selector(savePin))
        rightBarButtonSave.tintColor = .white
        let rightBarButtonEdit = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editPin))
        rightBarButtonEdit.tintColor = .white
        
        if (FlickerViewController.type) {
            navigationItem.rightBarButtonItem = rightBarButtonEdit
        } else {
            navigationItem.rightBarButtonItem = rightBarButtonSave
        }
        createNewTagButton.addTarget(self, action: #selector(createNewTag), for: .touchUpInside)
    }
    
    func setupMap() {
        print(FlickerViewController.pinLocation)
        zoomToPin(coordinate: FlickerViewController.pinLocation)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
        }
        
        mapView.delegate = self;
    }
    
    func zoomToPin(coordinate: CLLocationCoordinate2D) {
        print(coordinate)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
        mapView.setRegion(viewRegion, animated: true)
    }
    
    func getLocationInfo() {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: FlickerViewController.pinLocation.latitude, longitude: FlickerViewController.pinLocation.longitude)
        self.latitude = FlickerViewController.pinLocation.latitude
        self.longitude = FlickerViewController.pinLocation.longitude
        geoCoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error -> Void in
            guard let placeMark = placemarks?.first else { return }
            if let locationName = placeMark.name {
                print(locationName)
                self.name = locationName
                self.nameLabel.text = locationName
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
            self.addressLabel.text = "\(self.street), \(self.city), \(self.state) \(self.zip), \(self.country)"
        })
    }
    
    @objc  func deletePictures() {
        URLArray.removeAll()
        collectionView.reloadData()
    }
    
    @objc func savePin() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "SavedPins", in: context)
        let newEntity = NSManagedObject(entity: entity!, insertInto: context)
        
        newEntity.setValue(latitude, forKey: "latitude")
        newEntity.setValue(longitude, forKey: "longitude")
        newEntity.setValue(name, forKey: "name")
        newEntity.setValue(tagList, forKey: "tags")
        
        do {
          try context.save()
            print("saved")
        } catch {
            print("failed saving")
        }
    }
    
    @objc func editPin() {
        print("edit")
    }
    
    @objc func createNewTag() {
        let alert = UIAlertController(title: "Add a custom tag!", message: "Please enter your custom tag.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.autocapitalizationType = .words
            textField.placeholder = "Tag name"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            guard let newEntry = textField?.text else { return }
            self.tagList.append(newEntry)
            self.savedTagList.append(newEntry)
            textField!.layoutIfNeeded()
            let tagLabelWidth = textField!.text!.count * 10
            self.tagWidth.append(Float(tagLabelWidth))
            print(self.tagList)
            print(self.tagWidth)
            self.tagsCollectionView.reloadData()
            self.savedTagsCollectionView.reloadData()
        }))
        alert.addAction((UIAlertAction(title: "Cancel", style: .cancel, handler: nil)))
        self.present(alert, animated: true, completion: nil)
    }
    
}



extension FlickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.tagsCollectionView {
            return tagList.count
        }
        if collectionView == self.savedTagsCollectionView {
            return savedTagList.count
        }
        return URLArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickerCollectionViewCell", for: indexPath) as! FlickerCollectionViewCell
            
            if let imageURL = URL(string: URLArray[indexPath.row]) {
                let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                    if error == nil {
                        let downloadImage = UIImage(data: data!)!
                        DispatchQueue.main.async(){
                            cell.imageView.image = downloadImage
                        }
                    }
                }
                task.resume()
            }
            return cell
        }
        if collectionView == self.tagsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagsCollectionViewCell", for: indexPath) as! TagsCollectionViewCell
            
            cell.tagLabel.text = self.tagList[indexPath.row]
            cell.tagLabel.frame.size.width = CGFloat(tagWidth[indexPath.row])
            cell.layer.cornerRadius = 5
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SavedTagsCollectionViewCell", for: indexPath) as! SavedTagsCollectionViewCell
            
            cell.tagLabel.text = self.savedTagList[indexPath.row]
            let tagWidth = self.savedTagList[indexPath.row].count * 10
            print(tagWidth)
            cell.tagLabel.frame.size.width = CGFloat(tagWidth)
            //let widthConstraint = NSLayoutConstraint(item: cell.tagLabel!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(tagWidth))
            //cell.tagLabel.addConstraint(widthConstraint)
            
            print("width: \(cell.tagLabel.frame.width)")
            cell.layer.cornerRadius = 5
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.tagsCollectionView {
            self.tagList.remove(at: indexPath.row)
            self.tagWidth.remove(at: indexPath.row)
            self.tagsCollectionView.reloadData()
        }
        if collectionView == self.savedTagsCollectionView {
            self.tagList.append(self.savedTagList[indexPath.row])
            let tagLabelWidth = self.savedTagList[indexPath.row].count * 10
            self.tagWidth.append(Float(tagLabelWidth))
            self.tagsCollectionView.reloadData()
        }
    }
}




extension FlickerViewController : CLLocationManagerDelegate, MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            print(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    
}




class TagsView: UIView {
    // add your coolection view
}

// in the controller -> use TagsView only
