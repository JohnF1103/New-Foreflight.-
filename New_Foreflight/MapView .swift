//
//  MapView .swift
//  New_Foreflight
//
//  Created by John Foster on 12/31/23.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {

           
           
    @EnvironmentObject private var vm : AirportDetailModel

    @Binding var centerCoordinate: CLLocationCoordinate2D
    var annotations : [MKPointAnnotation]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.addOverlays(self.parseGEOjson())
        
        let region = MKCoordinateRegion(center: centerCoordinate, span: MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3))
           mapView.setRegion(region, animated: false)

        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        print("hello")
        
        
        if annotations.count != view.annotations.count{
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
        }
        
        view.removeOverlays(view.overlays)
        view.addOverlays(self.parseGEOjson())
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    // Example URL for testing purposes
    // let url = URL("https://api.weather.gov/gridpoints/ALY/74,67/forecast")!
 
    func parseGEOjson() ->[MKOverlay]{
        //add logic for toggles on the map here
        
        //vm.whatever we label
        if(vm.selectedData == "radar"){
            
            // TODO: Make a proper parser that turns coordinates into a full gridpoint thingy
            var a = [MKOverlay]()
            return a
            
        }
        
        guard let url = Bundle.main.url(forResource: vm.selectedData, withExtension: "json") else {
            
            fatalError("Uable to get geoJSON update API creds.")
        }
        var geoJSon = [MKGeoJSONObject]()
        
        do{
            let data = try Data(contentsOf:url)
            geoJSon = try MKGeoJSONDecoder().decode(data)
            
        }catch {
            fatalError("error no obj to decode")
        }
        var overlays = [MKOverlay]()
        for item in geoJSon{
            if let feature = item as? MKGeoJSONFeature{
                for geo in feature.geometry{
                    if let polygon = geo as? MKPolygon{
                        
                        overlays.append(polygon)
                        
                        
                    }
                }
            }
        }
        return overlays
    }
    
    class Coordinator: NSObject,MKMapViewDelegate{
        
        @EnvironmentObject private var vm : AirportDetailModel

        var parent: MapView
        
        init(parent: MapView) {
            self.parent = parent
        }
        
        
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon{

                let renderer = MKPolygonRenderer(polygon:polygon)
                renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
                renderer.strokeColor = UIColor.black
                return renderer
            }

            return MKOverlayRenderer(overlay: overlay)
        }
        
        
        
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            
            
               if let annotation = view.annotation {
                   //Process your annotation here
                   
                   //maybe nil check ap code
                   self.parent.vm.DisplayLocationdetail = true
                   self.parent.vm.selected_airport = Airport(id: UUID(), AirportCode: annotation.title!!, latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                   
                   
               }
           }
        
        
        
        
       
    }
}



