//
//  CustomAnnotation.swift
//  FlickerMap
//
//  Created by Mason Kelly on 9/10/19.
//  Copyright © 2019 Mason Kelly. All rights reserved.
//

import UIKit
import MapKit

enum Type {
    case saved
    case unsaved
}

class CustomAnnotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    var title: String?
    var image: UIImage?
    var type: Type
    
    init(coordinate: CLLocationCoordinate2D, title: String, image: UIImage, type: Type) {
        self.coordinate = coordinate
        self.title = title
        self.image = image
        self.type = type
        super.init()
    }
}



class SearchAnnotation: NSObject, MKAnnotation {
    
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

class SavedAnnotation: NSObject, MKAnnotation {
    
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

// combine all tags into 1 string, seprate with |
// load it -> splits again to [String]
