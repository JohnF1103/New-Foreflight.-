//
//  MapView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/20/23.
//


import SwiftUI
import MapKit

// Custom polygon class that can hold airspace type information.
class AirspacePolygon: MKPolygon {
    var airspaceType: String?
}

struct MapView: UIViewRepresentable {
    
    @EnvironmentObject private var vm: AirportDetailModel
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var shouldUpdateRegion: Bool
    var annotations: [MKPointAnnotation]
    
    // Static cache for overlays keyed by a string representing the active airspace types.
    private static var overlayCache: [String: [MKOverlay]] = [:]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        // Enforce dark mode and minimalistic appearance.
        mapView.overrideUserInterfaceStyle = .dark
        mapView.mapType = .mutedStandard
        
        mapView.pointOfInterestFilter = .excludingAll  // Hide POIs
         mapView.showsCompass = false
         mapView.showsScale = false
         mapView.showsBuildings = false
         mapView.showsTraffic = false
         
         // 3) Enable 3D globe effect
         mapView.isRotateEnabled = true
         mapView.isPitchEnabled = true
        
        mapView.showsUserLocation = true
        
        
        // Hide default decorations.
    
        // Disable delays on the gesture recognizers so taps are recognized immediately.
        if let recognizers = mapView.gestureRecognizers {
            for recognizer in recognizers {
                recognizer.delaysTouchesBegan = false
                recognizer.delaysTouchesEnded = false
            }
        }
        
        // Set the delegate.
        mapView.delegate = context.coordinator
        
        // Register custom annotation view classes for individual annotations and clusters.
        mapView.register(CustomAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(CustomClusterAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        // Load overlays asynchronously on initial setup.
        DispatchQueue.global(qos: .userInitiated).async {
            let overlays = self.parseGEOjson()
            DispatchQueue.main.async {
                mapView.addOverlays(overlays)
            }
        }
        
        let region = MKCoordinateRegion(
                 center: centerCoordinate,
                 span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
             )
             mapView.setRegion(region, animated: false)
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        // Update annotations (excluding the user location).
        if shouldUpdateRegion {
                let newRegion = MKCoordinateRegion(
                    center: centerCoordinate,
                    span: MKCoordinateSpan(latitudeDelta:0.5, longitudeDelta: 0.5)
                )
            view.setRegion(newRegion, animated: true)
                // Clear the flag on the next run loop to avoid re-centering on any other interaction.
                DispatchQueue.main.async {
                    shouldUpdateRegion = false
                }
            }
        
        
        let nonUserAnnotations = view.annotations.filter { !($0 is MKUserLocation) }
        if annotations.count != nonUserAnnotations.count {
            view.removeAnnotations(nonUserAnnotations)
            view.addAnnotations(annotations)
        }
        
        // Refresh overlays asynchronously only if needed.
        DispatchQueue.global(qos: .userInitiated).async {
            let newOverlays = self.parseGEOjson()
            DispatchQueue.main.async {
                // Only update if there's a change in overlay count.
                if view.overlays.count != newOverlays.count {
                    view.removeOverlays(view.overlays)
                    view.addOverlays(newOverlays)
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    /// Loads and parses GeoJSON files for each airspace type, using caching.
    func parseGEOjson() -> [MKOverlay] {
        // Get the active airspace types from the view model.
        let airspaces = vm.selectedData.compactMap { $0 }
        // Create a cache key from a sorted, comma-separated string.
        let cacheKey = airspaces.sorted().joined(separator: ",")
        if let cachedOverlays = MapView.overlayCache[cacheKey] {
            return cachedOverlays
        }
        
        var overlays = [MKOverlay]()
        for airspace in airspaces {
            let fileName = airspace.lowercased()
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                print("Warning: Unable to load GeoJSON file for \(airspace.lowercased()).")
                continue
            }
            do {
                let data = try Data(contentsOf: url)
                let geoJSONObjects = try MKGeoJSONDecoder().decode(data)
                for item in geoJSONObjects {
                    if let feature = item as? MKGeoJSONFeature {
                        for geo in feature.geometry {
                            if let polygon = geo as? MKPolygon {
                                var coordinates = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                                                           count: polygon.pointCount)
                                polygon.getCoordinates(&coordinates, range: NSRange(location: 0, length: polygon.pointCount))
                                let airspacePolygon = AirspacePolygon(coordinates: coordinates, count: polygon.pointCount)
                                airspacePolygon.airspaceType = airspace
                                overlays.append(airspacePolygon)
                            }
                        }
                    }
                }
            } catch {
                print("Error decoding GeoJSON for \(airspace): \(error.localizedDescription)")
            }
        }
        // Cache the overlays for future use.
        MapView.overlayCache[cacheKey] = overlays
        return overlays
    }
    
    // MARK: - Custom Annotation Views
    
    class CustomAnnotationView: MKAnnotationView {
        
        static let crosshairImage: UIImage? = {
            let size = CGSize(width: 40, height: 40)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let blueColor = UIColor.systemBlue
            let blackColor = UIColor.black
            
            // Adjusted parameters
            let circleRadius: CGFloat = 9
            let circleThickness: CGFloat = 1.0
            let armLength: CGFloat = 1.0
            let armThickness: CGFloat = 3.5
            let outlineWidth: CGFloat = 1.5
            
            // Draw outer black outline for crosshair arms
            context.setStrokeColor(blackColor.cgColor)
            context.setLineWidth(armThickness + outlineWidth * 2)
            context.setLineCap(.square)
            
            context.move(to: CGPoint(x: center.x - circleRadius - armLength, y: center.y))
            context.addLine(to: CGPoint(x: center.x - circleRadius, y: center.y))
            
            context.move(to: CGPoint(x: center.x + circleRadius, y: center.y))
            context.addLine(to: CGPoint(x: center.x + circleRadius + armLength, y: center.y))
            
            context.move(to: CGPoint(x: center.x, y: center.y - circleRadius - armLength))
            context.addLine(to: CGPoint(x: center.x, y: center.y - circleRadius))
            
            context.move(to: CGPoint(x: center.x, y: center.y + circleRadius))
            context.addLine(to: CGPoint(x: center.x, y: center.y + circleRadius + armLength))
            context.strokePath()
            
            // Fill blue outer circle
            let circleRect = CGRect(x: center.x - circleRadius,
                                    y: center.y - circleRadius,
                                    width: circleRadius * 2,
                                    height: circleRadius * 2)
            context.setFillColor(blueColor.cgColor)
            context.fillEllipse(in: circleRect)
            
            // Outer black stroke for circle (thicker)
            context.setStrokeColor(blackColor.cgColor)
            context.setLineWidth(circleThickness)
            context.strokeEllipse(in: circleRect)
            
            // Transparent inner circle (hollow)
            let innerCircleRadius: CGFloat = 4.0
            let innerCircleRect = CGRect(x: center.x - innerCircleRadius,
                                         y: center.y - innerCircleRadius,
                                         width: innerCircleRadius * 2,
                                         height: innerCircleRadius * 2)
            context.setBlendMode(.clear)
            context.fillEllipse(in: innerCircleRect)
            
            // Restore blend mode and draw black outline around transparent hole
            context.setBlendMode(.normal)
            context.setStrokeColor(blackColor.cgColor)
            context.setLineWidth(outlineWidth)
            context.strokeEllipse(in: innerCircleRect)
            
            // Inner blue crosshair arms
            context.setStrokeColor(blueColor.cgColor)
            context.setLineWidth(armThickness)
            context.move(to: CGPoint(x: center.x - circleRadius - armLength, y: center.y))
            context.addLine(to: CGPoint(x: center.x - circleRadius, y: center.y))
            
            context.move(to: CGPoint(x: center.x + circleRadius, y: center.y))
            context.addLine(to: CGPoint(x: center.x + circleRadius + armLength, y: center.y))
            
            context.move(to: CGPoint(x: center.x, y: center.y - circleRadius - armLength))
            context.addLine(to: CGPoint(x: center.x, y: center.y - circleRadius))
            
            context.move(to: CGPoint(x: center.x, y: center.y + circleRadius))
            context.addLine(to: CGPoint(x: center.x, y: center.y + circleRadius + armLength))
            context.strokePath()
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }()
        
        override var annotation: MKAnnotation? {
            didSet {
                guard !(annotation is MKClusterAnnotation) else { return }
                self.image = CustomAnnotationView.crosshairImage
                self.clusteringIdentifier = "cluster"
                self.canShowCallout = false
                self.centerOffset = CGPoint(x: 0, y: 0)
            }
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            let scale: CGFloat = selected ? 1.2 : 1.0
            if animated {
                UIView.animate(withDuration: 0.1) {
                    self.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            } else {
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
    
    class CustomClusterAnnotationView: MKAnnotationView {
        override var annotation: MKAnnotation? {
            didSet {
                guard let cluster = annotation as? MKClusterAnnotation else { return }
                self.image = drawClusterImage(for: cluster)
                self.canShowCallout = false
            }
        }
        
        func drawClusterImage(for cluster: MKClusterAnnotation) -> UIImage? {
            let size = CGSize(width: 40, height: 40)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            
            let circleRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            context.setFillColor(UIColor.systemBlue.cgColor)
            context.fillEllipse(in: circleRect)
            
            let count = cluster.memberAnnotations.count
            let text = "\(count)"
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.boldSystemFont(ofSize: 16)
            ]
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(x: (size.width - textSize.width) / 2,
                                  y: (size.height - textSize.height) / 2,
                                  width: textSize.width,
                                  height: textSize.height)
            text.draw(in: textRect, withAttributes: attributes)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            if annotation is MKClusterAnnotation {
                return mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier, for: annotation)
            } else {
                return mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation)
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = UIColor.clear
                
                // Immediately return the renderer while we update its properties asynchronously.
                DispatchQueue.global(qos: .userInitiated).async {
                    let hotPink = UIColor(red: 1.0, green: 0.4118, blue: 0.7059, alpha: 1.0)
                    var strokeColor = UIColor.white
                    var lineWidth: CGFloat = 2.5
                    var dashPattern: [NSNumber]?
                    
                    if let airspacePolygon = polygon as? AirspacePolygon,
                       let type = airspacePolygon.airspaceType?.lowercased() {
                        switch type {
                        case "class_b":
                            strokeColor = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 1.0)
                        case "class_c":
                            strokeColor = UIColor.systemPink
                        case "class_d":
                            strokeColor = UIColor.blue.withAlphaComponent(0.5)
                        case "special":
                            strokeColor = hotPink
                            lineWidth = 1
                            dashPattern = [NSNumber(value: 6), NSNumber(value: 6)]
                        default:
                            strokeColor = UIColor.white
                        }
                    }
                    
                    // Update the renderer on the main thread
                    DispatchQueue.main.async {
                        renderer.strokeColor = strokeColor
                        renderer.lineWidth = lineWidth
                        if let dashPattern = dashPattern {
                            renderer.lineDashPattern = dashPattern
                        }
                        renderer.setNeedsDisplay()
                    }
                }
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            // Process your annotation selection asynchronously.
            if let annotation = view.annotation, let title = annotation.title ?? nil {
                DispatchQueue.main.async {
                    self.parent.vm.DisplayLocationdetail = true
                    self.parent.vm.selected_airport = Airport(
                        id: UUID(),
                        AirportCode: title,
                        latitude: annotation.coordinate.latitude,
                        longitude: annotation.coordinate.longitude
                    )
                }
            }
        }
    }
}
