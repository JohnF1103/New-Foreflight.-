//
//  ContentView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/15/23.
//

import SwiftUI
import MapKit

// Assuming your Airport object is defined as:

struct ContentView: View {
    @State private var centerCoordinate = CLLocationCoordinate2D(latitude: 40.6, longitude: -73.7)
    @State private var shouldUpdateRegion = false
    @State private var annotations = [MKPointAnnotation]()
    // Replace this with your actual data source.
    @State private var locations: [Airport] = readFile()
    
    @EnvironmentObject private var vm: AirportDetailModel
    @State private var showAirportSearchDialog = false
    
    var body: some View {
        ZStack {
            // Pass the new binding to MapView.
            MapView(centerCoordinate: $centerCoordinate,
                    shouldUpdateRegion: $shouldUpdateRegion,
                    annotations: annotations)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    AdditionalDataButton
                    Spacer()
                    Button(action: {
                        showAirportSearchDialog = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.headline)
                            .padding(16)
                            .foregroundColor(.primary)
                            .background(.thickMaterial)
                            .cornerRadius(10)
                            .shadow(radius: 4)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                ZStack {
                    if vm.DisplayLocationdetail, let selected = vm.selected_airport {
                        LocationPreviewView(airport: selected)
                            .shadow(color: Color.black.opacity(0.3), radius: 20)
                            .padding()
                    }
                }
            }
            .onAppear {
                for airport in locations {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: airport.latitude,
                                                                   longitude: airport.longitude)
                    annotation.title = airport.AirportCode
                    annotations.append(annotation)
                }
            }
            .onDisappear {
                vm.selected_airport = nil
            }
            
            // Airport search dialog overlay.
            if showAirportSearchDialog {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showAirportSearchDialog = false
                    }
                
                AirportSearchDialog(isPresented: $showAirportSearchDialog, onAirportSelected: { airport in
                    // When a search finds an airport, update centerCoordinate and trigger region update.
                    withAnimation(.easeInOut(duration: 1.0)) {
                        centerCoordinate = CLLocationCoordinate2D(latitude: airport.latitude,
                                                                    longitude: airport.longitude)
                        shouldUpdateRegion = true
                    }
                    vm.selected_airport = airport
                    vm.DisplayLocationdetail = true
                })
            }
        }
        .sheet(item: $vm.sheetlocation, onDismiss: nil) { ap in
            AirportDetailsView(airport: ap, curr_mertar: vm.curr_metar ?? "NIL")
                .presentationDetents([.medium])
        }
    }
    
    // ... (AdditionalDataButton and other methods remain the same)
}

extension ContentView {
    
    private var AdditionalDataButton: some View {
        VStack {
            Menu {
                Button("Airspace", action: Show_Airspace)
                Button("National Defense TFRs", action: showTFRs)
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
        }
    }
    
    func showTFRs() {
        print("CALLING ME NOEN SELECTED")
        vm.selectedData = ["TFR"]
    }
    
    func showSpecialAirspaces() {
        print("CALLING ME NOEN SELECTED")
        vm.selectedData = ["Special"]
    }
    
    func showATClimits() {
        vm.selectedData = ["ASpace_bounds"]
    }
    
    func Show_Airspace() {
        vm.selectedData = ["Class_B", "Class_C", "class_d", "special"]
    }
}
struct AirportSearchDialog: View {
    @Binding var isPresented: Bool
    var onAirportSelected: (Airport) -> Void
    
    @State private var searchText = ""
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Search Airports")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
            }
            .padding(.horizontal)
            
            TextField("Enter 4-letter airport code", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                guard let airport = lookupAirport(code: searchText) else {
                    errorMessage = "No airport found for code: \(searchText)"
                    return
                }
                print("FOUND AIRPORT", airport.latitude, airport.longitude)
                // Animate updating the center coordinate via the onAirportSelected closure.
                withAnimation(.easeInOut(duration: 1.0)) {
                    onAirportSelected(airport)
                }
                isPresented = false
            }) {
                Text("Search")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 8)
        .padding(.horizontal, 40)
    }
    
    func lookupAirport(code: String) -> Airport? {
        let normalizedCode = code.uppercased()
        guard normalizedCode.count == 4 else { return nil }
        
        guard let fileUrl = Bundle.main.url(forResource: "formatted_airports", withExtension: "txt"),
              let content = try? String(contentsOf: fileUrl) else {
            print("Unable to load Airports.txt")
            return nil
        }
        
        let fields = content.components(separatedBy: ":")
        // The file alternates between [Code, Latitude, Longitude]
        for i in stride(from: 0, to: fields.count, by: 3) {
            let fileCode = fields[i].trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            if fileCode == normalizedCode,
               let lat = Double(fields[i + 1].trimmingCharacters(in: .whitespacesAndNewlines)),
               let lon = Double(fields[i + 2].trimmingCharacters(in: .whitespacesAndNewlines)) {
                return Airport(id: UUID(), AirportCode: fileCode, latitude: lat, longitude: lon)
            }
        }
        
        print("No airport found for code: \(normalizedCode)")
        return nil
    }
}



