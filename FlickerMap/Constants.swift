//
//  Constants.swift
//  FlickerMap
//
//  Created by Mason Kelly on 9/10/19.
//  Copyright © 2019 Mason Kelly. All rights reserved.
//

import UIKit

struct Constants {
    
    struct FlickrURLParams {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
    }
    
    struct FlickrAPIKeys {
        static let SearchMethod = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let ResponseFormat = "format"
        static let DisableJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Radius = "radius"

    }
    
    struct FlickrAPIValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "4ffb9a1716650f2602e2837a396f1dbc"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let SafeSearch = "1"
    }
}
