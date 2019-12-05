//
//  LocationAnnotation.swift
//  MelbourenHistorySight
//
//  Created by Lynn on 4/9/19.
//  Copyright © 2019 JunfanDang. All rights reserved.
//

import UIKit
import MapKit
class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(newTitle: String, newSubtitle: String, lat: Double, long: Double) {
        self.title = newTitle
        self.subtitle = newSubtitle
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    init(sight: Sight){
        self.title = sight.name!
        self.subtitle = "latitude:" + String(sight.latitude) + "longitude:" + String(sight.longitude)
        coordinate = CLLocationCoordinate2D(latitude: sight.latitude, longitude: sight.longitude)
    }
}
