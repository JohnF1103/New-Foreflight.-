//
//  Untitled.swift
//  New_Foreflight
//
//  Created by John Foster on 2/5/25.
//

import MapKit

/// A custom MKPolygon subclass that stores altitude bounds.
class AirspacePolygon: MKPolygon {
    var lowAltitude: Double
    var highAltitude: Double
    
    init(coordinates coords: UnsafePointer<CLLocationCoordinate2D>, count: Int, lowAltitude: Double, highAltitude: Double) {
        self.lowAltitude = lowAltitude
        self.highAltitude = highAltitude
        super.init(coordinates: coords, count: count)
    }
    
    /// Compute a simple centroid by averaging all coordinates.
    var centroid: CLLocationCoordinate2D {
        var totalLat = 0.0, totalLon = 0.0
        let pointCount = self.pointCount
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        self.getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        for coord in coords {
            totalLat += coord.latitude
            totalLon += coord.longitude
        }
        return CLLocationCoordinate2D(latitude: totalLat/Double(pointCount),
                                      longitude: totalLon/Double(pointCount))
    }
}
