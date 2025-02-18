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
    
    @State private var selection = ""
    let colors = ["Military TFRs", "Special use airspaces, ATC boundaries"]
    @State private var centerCoordinate = CLLocationCoordinate2D(latitude: 40.6, longitude: -73.7)
    @State private var airports = [MKPointAnnotation]()
    @State private var isPickerVisible = false
    
    //Move this into a DB and implement search.
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
            
            
            AirportDetailsView(airport: ap, curr_mertar: vm.curr_metar ?? "NIL")
                .presentationDetents([.medium])

               
        }
        
        
        
        
        
        
    }
}


extension ContentView{
    
    private var AdditionalDataButton: some View{
        
        
        VStack {
            
            
            Menu {
                Button("Airspace", action: Show_Airspace)
                Button("National Defense TFRs", action:showTFRs )
                Button("ATC Boundaries", action: showATClimits)
                Button("Special use airspaces", action: showSpecialAirspaces)

            } label: {
                
                Image(systemName: "square.on.square")
                    .font(.headline)
                    .padding(16)
                    .foregroundColor(.primary)
                    .background(.thickMaterial)
                    .cornerRadius(10)
                    .shadow(radius: 4)
                    .padding()
            }
            // Image (xmark) to open the Picker
            
            // Picker
            
        }.offset(x:-150)
    }
    
    func showTFRs() {
        
        print("CALLING ME NOEN SELECTED")
        vm.selectedData = ["TFR"]
        
    }
    
    
    func showSpecialAirspaces() {
        print("CALLING ME NOEN SELECTED")

        vm.selectedData = ["Special"]
    }
    
    func showATClimits(){
        vm.selectedData = ["ASpace_bounds"]
    }
    
    func Show_Airspace(){
        vm.selectedData = ["Class_B","Class_C","class_d"]
    }
}
