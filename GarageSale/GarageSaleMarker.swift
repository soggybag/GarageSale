//
//  GarageSaleMarker.swift
//  GarageSale
//
//  Created by mitchell hudson on 1/21/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import UIKit
import MapKit
import Parse

class GarageSaleMarker: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    var garageSale: PFObject
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String, garageSale: PFObject) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.garageSale = garageSale
    }
}
