//
//  ContentView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/15/23.
//
import SwiftUI
import MapKit


    struct ContentView: View {
        
        @State private var airports: [Airport] = readFile()
        
        var body: some View {
            Map {
                ForEach(airports) { curr_Airport in
                    Annotation(curr_Airport.AirportCode, coordinate: CLLocationCoordinate2D(latitude: curr_Airport.latitude, longitude: curr_Airport.longitude)) {
                        Button(action: { print("Clicked on \(curr_Airport.AirportCode)") }, label: {
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


