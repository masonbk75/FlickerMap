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

var URLArray = [String]()

class FlickerViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    let locationManager = CLLocationManager()

    static var pinLocation = CLLocationCoordinate2D()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupMap()
    }
    
    func setupView() {
        navigationController?.isNavigationBarHidden = false

        collectionView.delegate = self
        collectionView.dataSource = self
        
        let rightBarButton = UIBarButtonItem(title: "Delete Pictures", style: .plain, target: self, action: #selector(deletePictures))
        navigationItem.rightBarButtonItem = rightBarButton

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
        //annotation.title = 
        //annotation.subtitle = "This is roughly where we are..."
        mapView.addAnnotation(annotation)
        let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(viewRegion, animated: true)
    }
    
    @objc  func deletePictures() {
        URLArray.removeAll()
        collectionView.reloadData()
    }
}



extension FlickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return URLArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
