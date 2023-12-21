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
    
    
    
    @State private var showLocationPreview = false
    @State private var selectedAirport: Airport?
    
    @State private var locations: [Airport] = readFile()
    
    
    var body: some View {
        
        ZStack{
            
            Map{
              
            
                ForEach(locations) { curr_airport in
                                    Annotation(curr_airport.AirportCode, coordinate: CLLocationCoordinate2D(latitude: curr_airport.latitude, longitude: curr_airport.longitude)) {
                                        Button(action: { print("Clicked on \(curr_airport.AirportCode)")
                                            
                                            
                                            self.selectedAirport = curr_airport
                                            self.showLocationPreview.toggle()
                                                
                                            
                                            
                                        }, label: {
                                            ZStack{
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(Color.teal)
                                                Text("✈️")
                                                    .padding(5)
                                            }
                                        })
                                    }
                                }
                
            }
                .ignoresSafeArea()
            

            VStack(spacing: 0){
                
                
                Spacer()
                
                
                ZStack{
                    
                    if showLocationPreview{
                        
                        if self.selectedAirport != nil{
                            
                            LocationPreviewView(airport: self.selectedAirport!)
                            
                                .shadow(color:Color.black.opacity(0.3) , radius: 20)
                                .padding()
                            
                        }
                        
                        
                    }
                    
                    
                }
                
            }
            
            
        }
        
        
        
        
       
        
        
        
    }
}
