//
//  ContentView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/15/23.
//
import SwiftUI
import MapKit





struct ContentView: View {
    
    // Assuming this code is part of a function or method
    
    @State private var selection = "Military TFRs"
    let colors = ["Military TFRs", "Special Airspaces"]
    
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var airports = [MKPointAnnotation]()
    
    
    @State private var locations: [Airport] = readFile()
    
    @EnvironmentObject private var vm : AirportDetailModel
    
    
    var body: some View {	
        
        ZStack{
            
            
            
            MapView(centerCoordinate: $centerCoordinate, annotations:  airports)
                .edgesIgnoringSafeArea(.all)
        
        

            VStack(spacing: 0){
                AdditionalDataButton
                
                Spacer()
                
                
                ZStack{
                    
                    if vm.DisplayLocationdetail{
                        
                        if vm.selected_airport != nil{
                            
                            LocationPreviewView(airport: vm.selected_airport!)
                            
                                .shadow(color:Color.black.opacity(0.3) , radius: 20)
                                .padding()
                            
                        }
                        
                        
                    }
                    
        
                }
                
            }
            .onAppear{
                
                for airport in locations {
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = CLLocationCoordinate2D(latitude: airport.latitude, longitude: airport.longitude)
                            annotation.title = airport.AirportCode
                            airports.append(annotation)
                        }
            }.onDisappear {
                // Reset the selectedAirport when the ContentView disappears
                vm.selected_airport = nil
            }
            
        }.sheet(item: $vm.sheetlocation, onDismiss: nil){ap in
            
            
            AirportDetailsView(airport: ap, curr_mertar: vm.curr_metar!)
        }
        
        
        
       
        
        
        
    }
}


extension ContentView{
    
    private var AdditionalDataButton: some View{
        
        Button{
            
            

        
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
                .padding(16)
                .foregroundColor(.primary)
                .foregroundColor(.primary)
                .background(.thickMaterial)
                .cornerRadius(10)
                .shadow(radius: 4)
                .padding()
        }
    }
}

