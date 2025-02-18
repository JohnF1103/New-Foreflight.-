import SwiftUI
import MapKit

// Custom polygon class that can hold airspace type information.
class AirspacePolygon: MKPolygon {
    var airspaceType: String?
}

struct MapView: UIViewRepresentable {
    
    @EnvironmentObject private var vm: AirportDetailModel
    @Binding var centerCoordinate: CLLocationCoordinate2D
    var annotations: [MKPointAnnotation]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        // Enforce dark mode and minimalistic appearance
        mapView.overrideUserInterfaceStyle = .dark
        mapView.mapType = .mutedStandard
        
        // Hide default decorations for a sleek look
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsPointsOfInterest = false
        
        mapView.delegate = context.coordinator
        
        // Add overlays for each airspace type (e.g., Class_B and Class_C)
        mapView.addOverlays(self.parseGEOjson())
        
        let region = MKCoordinateRegion(center: centerCoordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3))
        mapView.setRegion(region, animated: false)
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        if annotations.count != view.annotations.count {
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
        }
        // Refresh overlays
        view.removeOverlays(view.overlays)
        view.addOverlays(self.parseGEOjson())
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    /// Loops over the airspace types defined in the view model (e.g., ["Class_B", "Class_C"]),
    /// loads each corresponding GeoJSON file, and converts decoded polygons into AirspacePolygons.
    func parseGEOjson() -> [MKOverlay] {
        var overlays = [MKOverlay]()
        
        // Use compactMap to unwrap any nil values in vm.airspaces.
        for airspace in vm.selectedData.compactMap({ $0 }) {
            // Convert to a file name. For example, "Class_C" becomes "class_c"
            let fileName = airspace.lowercased()
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                print("Warning: Unable to load GeoJSON file for \(airspace). Skipping this airspace.")
                continue // Skip this airspace type instead of crashing.
            }
            
            do {
                let data = try Data(contentsOf: url)
                let geoJSONObjects = try MKGeoJSONDecoder().decode(data)
                for item in geoJSONObjects {
                    if let feature = item as? MKGeoJSONFeature {
                        for geo in feature.geometry {
                            if let polygon = geo as? MKPolygon {
                                // Extract the polygon's coordinates
                                var coordinates = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: polygon.pointCount)
                                polygon.getCoordinates(&coordinates, range: NSRange(location: 0, length: polygon.pointCount))
                                
                                // Create an AirspacePolygon with the same coordinates
                                let airspacePolygon = AirspacePolygon(coordinates: coordinates, count: polygon.pointCount)
                                airspacePolygon.airspaceType = airspace  // Tag it with its type
                                overlays.append(airspacePolygon)
                            }
                        }
                    }
                }
            } catch {
                print("Error decoding GeoJSON for \(airspace): \(error.localizedDescription)")
            }
        }
        return overlays
    }


    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: MapView
        
        init(parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                   if let polygon = overlay as? MKPolygon {
                       let renderer = MKPolygonRenderer(polygon: polygon)
                       renderer.fillColor = UIColor.clear // Set fill color to clear

                       // Determine the stroke color and pattern based on the airspace type
                       if let airspacePolygon = polygon as? AirspacePolygon,
                          let type = airspacePolygon.airspaceType?.lowercased() {
                           switch type {
                           case "class_b":
                               // Use the same shade of blue for Class B airspaces
                               renderer.strokeColor = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 1.0)
                               renderer.lineWidth = 2.5
                               renderer.lineDashPattern = nil // Solid line
                           case "class_c":
                               // Use pink for Class C airspaces
                               renderer.strokeColor = UIColor.systemPink
                               renderer.lineWidth = 2.5
                               renderer.lineDashPattern = nil // Solid line
                           case "class_d":
                               // Use a slightly more transparent shade of blue for Class D airspaces
                               renderer.strokeColor = UIColor.blue.withAlphaComponent(0.5) // 50% transparency
                               renderer.lineWidth = 2.5
                               renderer.lineDashPattern = nil // Solid line
                           default:
                               renderer.strokeColor = UIColor.white // Default color
                               renderer.lineWidth = 2.5
                               renderer.lineDashPattern = nil // Solid line
                           }
                       } else {
                           renderer.strokeColor = UIColor.white // Default color
                           renderer.lineWidth = 2.5
                           renderer.lineDashPattern = nil // Solid line
                       }
                       return renderer
                   }
                   return MKOverlayRenderer(overlay: overlay)
               } 
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation {
                self.parent.vm.DisplayLocationdetail = true
                self.parent.vm.selected_airport = Airport(
                    id: UUID(),
                    AirportCode: (annotation.title ?? "nil")!,
                    latitude: annotation.coordinate.latitude,
                    longitude: annotation.coordinate.longitude
                )
            }
        }
    }
}

