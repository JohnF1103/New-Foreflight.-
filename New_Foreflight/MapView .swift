//
//  DarkAeronauticalMapView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/31/23.
//

import SwiftUI
import MapKit

struct DarkAeronauticalMapView: UIViewRepresentable {
    
    @EnvironmentObject private var vm: AirportDetailModel
    @Binding var centerCoordinate: CLLocationCoordinate2D
    var annotations: [MKPointAnnotation]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        // Set the delegate for overlay and annotation rendering.
        mapView.delegate = context.coordinator
        
        // Force the dark mode appearance on the map.
        if #available(iOS 13.0, *) {
            mapView.overrideUserInterfaceStyle = .dark
        }
        
        // Use a muted standard map type that works well with a dark theme.
        mapView.mapType = .mutedStandard
        
        // Load and add the aeronautical (VFR sectional) overlays.
        mapView.addOverlays(parseGeoJSON())
        
        // Set the initial region.
        let region = MKCoordinateRegion(center: centerCoordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3))
        mapView.setRegion(region, animated: false)
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        // Update annotations if needed.
        if annotations.count != view.annotations.count {
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
        }
        
        // Refresh the overlays.
        view.removeOverlays(view.overlays)
        view.addOverlays(parseGeoJSON())
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    /// Loads a GeoJSON file based on the currently selected data in your model,
    /// decodes it, and returns an array of MKOverlay objects.
    func parseGeoJSON() -> [MKOverlay] {
        // Use the selectedData property from your environment model.
        guard let url = Bundle.main.url(forResource: vm.selectedData, withExtension: "json") else {
            fatalError("Unable to locate geoJSON file for \(vm.selectedData).json")
        }
        
        var geoJSONObjects: [MKGeoJSONObject] = []
        do {
            let data = try Data(contentsOf: url)
            geoJSONObjects = try MKGeoJSONDecoder().decode(data)
        } catch {
            fatalError("Error decoding geoJSON: \(error)")
        }
        
        // Extract polygons from the GeoJSON features.
        var overlays = [MKOverlay]()
        for object in geoJSONObjects {
            if let feature = object as? MKGeoJSONFeature {
                for geometry in feature.geometry {
                    if let polygon = geometry as? MKPolygon {
                        overlays.append(polygon)
                    }
                }
            }
        }
        return overlays
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: DarkAeronauticalMapView
        
        init(parent: DarkAeronauticalMapView) {
            self.parent = parent
        }
        
        // Render overlays with dark–themed styling.
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygonOverlay = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygonOverlay)
                // Use a dark blue fill with transparency, and a dark gray stroke.
                renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.4)
                renderer.strokeColor = UIColor.darkGray
                renderer.lineWidth = 1.5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        // Handle annotation selections.
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation {
                // Process the annotation selection.
                // For example, update the AirportDetailModel with the selected airport info.
                self.parent.vm.DisplayLocationdetail = true
                self.parent.vm.selected_airport = Airport(
                    id: UUID(),
                    AirportCode: (annotation.title ?? "Unknown")!,
                    latitude: annotation.coordinate.latitude,
                    longitude: annotation.coordinate.longitude
                )
            }
        }
    }
}

