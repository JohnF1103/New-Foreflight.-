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
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        print("hello")
        if annotations.count != view.annotations.count{
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func AnnotationCLicked(annotation: MKAnnotation){
        vm.DisplayLocationdetail.toggle()
        vm.selected_airport = Airport(id: UUID(), AirportCode: annotation.title?.debugDescription ?? "nil", latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
     
        
       
    }
    
    class Coordinator: NSObject,MKMapViewDelegate{
        
        @EnvironmentObject private var vm : AirportDetailModel

        var parent: MapView
        
        init(parent: MapView) {
            self.parent = parent
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



