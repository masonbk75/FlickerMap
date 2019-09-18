//
//  CustomAnnotation.swift
//  FlickerMap
//
//  Created by Mason Kelly on 9/10/19.
//  Copyright © 2019 Mason Kelly. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    var title: String?
    let image: UIImage?
    
    init(coordinate: CLLocationCoordinate2D, title: String, image: UIImage) {
        self.coordinate = coordinate
        self.title = title
        self.image = image
        super.init()
    }
}
