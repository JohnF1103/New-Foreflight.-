//
//  ContentView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/15/23.
//
import SwiftUI
import MapKit



struct Location: Identifiable, Codable, Equatable {
    let id: UUID
    let AirportCode : String
    let latitude: Double
    let longitude: Double
}


func readFile() -> [Location] {
    var locs: [Location] = []

    let filename = "Airports.txt"
        var str1: String
        var myCounter: Int
        do {
            let contents = try String(contentsOfFile: filename)
            let lines = contents.split(separator:"\n")
            myCounter = lines.count
            str1 = String(myCounter)
            } catch {
                print(error.localizedDescription)
            }
    

    return locs
}

struct ContentView: View {
    @State private var locations: [Location] = readFile()

    var body: some View {
        Map {
            ForEach(locations) { location in
                Annotation(location.AirportCode, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                    Button(action: { print("Clicked on \(location.AirportCode)") }, label: {
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
