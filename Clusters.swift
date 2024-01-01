//
//  Clusters.swift
//  New_Foreflight
//
//  Created by John Foster on 12/31/23.
//

import CoreLocation

import Foundation
import SwiftUI
import MapKit

struct PlaceCluster : Hashable {
    static func == (lhs: PlaceCluster, rhs: PlaceCluster) -> Bool {
        let areEqual = lhs.hashValue == rhs.hashValue
        
        return areEqual
    }
    
   
    
    let items : [MKMapItem]
    let center : CLLocationCoordinate2D
    var size :Int {
        items.count
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(self.center.latitude.hashValue)
    }
    
    internal init(items: [MKMapItem]) {
        self.items = items
        let intoCoord =  CLLocationCoordinate2D(latitude: 0.0,longitude: 0.0)
        let factor = 1.0 / Double(items.count)
        self.center = items.reduce( intoCoord ) { runningAverage, mapItem in
            let itemCoord = mapItem.placemark.coordinate
            let lat = itemCoord.latitude * factor
            let lon = itemCoord.longitude * factor
            return CLLocationCoordinate2D(latitude: runningAverage.latitude + lat, longitude: runningAverage.longitude + lon)
        }
    }
}
