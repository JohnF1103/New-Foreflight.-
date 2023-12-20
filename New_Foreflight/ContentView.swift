//
//  ContentView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/15/23.
//
import SwiftUI
import MapKit

    
    struct ContentView: View {
        
        @State private var locations: [Airport] = readFile()
        
        var body: some View {
            Map {
                ForEach(locations) { curr_airport in
                    Annotation(curr_airport.AirportCode, coordinate: CLLocationCoordinate2D(latitude: curr_airport.latitude, longitude: curr_airport.longitude)) {
                        Button(action: { print("Clicked on \(curr_airport.AirportCode)") }, label: {
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
            .mapStyle(.hybrid(elevation: .realistic))
        }
    }


