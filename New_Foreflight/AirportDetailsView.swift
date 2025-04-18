//
//  AirportDetailsView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/20/23.
//


import SwiftUI
import PDFKit

struct AirportDetailsView: View {
    
    @EnvironmentObject private var vm: AirportDetailModel
    @State private var image: UIImage? = nil
    @State private var PlateInfo: String = ""
    @State private var FrequencyInfo: String = ""
    @State private var ParsedFrequencies: [String: String]? = nil
    @State private var NotamsInfo: String = ""
    
    @State private var selectedItem = 0

    
    @State private var isFreqenciespresented = false
    @State private var FreqapiKey = "9d0b8ab9c176ca96804eac20c1936b5b2b058965c1c0e6ffbfd4c737730dfe8f5d175f8f447b6be1b9875346c5f00cc3"
    @State private var NOTAMapikey = "f482ac5e-2eac-48ff-b603-0ad8c36c0cee"
    
    
    
    
    
    let airport: Airport
    let curr_mertar: String
    
    var body: some View {
           NavigationView {
               VStack(spacing: 0) {
                   // Drag Indicator for sheet-style UI
                   Capsule()
                       .fill(Color.secondary.opacity(0.4))
                       .frame(width: 40, height: 6)
                       .padding(.top, 8)
                   
                   // Swipeable TabView using page style
                   TabView(selection: $selectedItem) {
                       TaxiDiagramSection
                           .tag(0)
                       
                       ScrollView {
                           METAR_View(JSON_Metar: curr_mertar, curr_ap: airport)
                               .padding()
                       }
                       .tag(1)
                       
                       RunwaysView(curr_ap:airport)
                           .padding()
                           .tag(2)
                       
                       PlatesView(plateJSON: PlateInfo, curr_ap: airport)
                           .tag(4)
                       
                       FrequenciesView(FreqenciesJSON: FrequencyInfo,
                                       curr_ap: airport,
                                       parsedFrequencies: ParsedFrequencies)
                           .tag(5)
                       
                       NOTAMS_View_(NotamsJson: NotamsInfo, curr_ap: airport)
                           .tag(6)
                   }
                   .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
               }
               .background(Color(.systemBackground))
               .navigationBarItems(leading: BackButton)
               .onAppear {
                   Task {
                       async let plates = loadPlates()
                       async let freqs = loadFrequencies()
                       async let notams = loadNOTAMS()
                       async let image = loadImageFromAPI()
                       async let runways  = loadRunways()


                       // Wait for all to finish
                       _ = await (plates, freqs, notams, image, runways)
                   }

               }
           }
           .navigationViewStyle(StackNavigationViewStyle())
       }
}

extension AirportDetailsView {
    
    // MARK: - Sections
    
    private var TaxiDiagramSection: some View {
        VStack(spacing: 16) {
            // Image section in a rounded, card-style view
            Imagesection
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            
            // Title section with a divider
            VStack(alignment: .leading, spacing: 8) {
                Titlesection(curr_ap: airport,
                             subtitle: "Airport",
                             flightrules: vm.flightrules ?? "")
                .padding(.horizontal)
                
                Divider()
                    .background(Color.gray.opacity(0.4))
            }
        }
        .padding()
    }
    
    private var Imagesection: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit() // Ensures the full image is visible
            } else {
                ZStack {
                    Color.gray.opacity(0.1)
                    Text("Loading Image...")
                        .foregroundColor(.gray)
                        .font(.headline)
                }
                .frame(height: 200)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal) // Leaves a margin on the sides
    }
    
    private var BackButton: some View {
        Button(action: {
            vm.sheetlocation = nil
        }) {
            Image(systemName: "xmark")
                .foregroundColor(.primary)
                .padding(10)
                .background(Color(.systemGray5))
                .clipShape(Circle())
        }
    }
    
    // MARK: - Networking Functions
    @MainActor
    func loadImageFromAPI() async {
        guard let url = URL(string: "https://cloudfront.foreflight.com/diagrams/2312/\(airport.AirportCode.lowercased()).jpg") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                self.image = uiImage
            }
        } catch {
            print("Error loading image: \(error.localizedDescription)")
        }
    }
    
    func loadPlates() async {
        guard let url = URL(string: "https://api.aviationapi.com/v1/charts?apt=\(airport.AirportCode.lowercased())") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("8bf1b3467a3548a1bb8b643978", forHTTPHeaderField: "X-API-Key")
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let str = String(data: data, encoding: .utf8) {
                await MainActor.run {
                    self.PlateInfo = str
                }
            }
            print("Plate info loaded for \(airport.AirportCode.lowercased())")
        } catch {
            print("Error loading plates: \(error.localizedDescription)")
        }
    }
    
    func loadFrequencies() async {
        guard let url = URL(string: "https://frq-svc-272565453292.us-central1.run.app/api/v1/getAirportFrequencies?airportCode=\(airport.AirportCode.uppercased())") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let string = String(data: data, encoding: .utf8) ?? ""
            let parsed = (try? JSONDecoder().decode([String: String].self, from: data)) ?? [:]
            
            await MainActor.run {
                self.FrequencyInfo = string
                self.ParsedFrequencies = parsed
            }
        } catch {
            print("Error loading frequencies: \(error.localizedDescription)")
        }
    }
    
    func loadNOTAMS() async {
        guard let url = URL(string: "https://applications.icao.int/dataservices/api/notams-realtime-list?api_key=\(NOTAMapikey)&format=json&locations=\(airport.AirportCode)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("8bf1b3467a3548a1bb8b643978", forHTTPHeaderField: "X-API-Key")
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let str = String(data: data, encoding: .utf8) {
                await MainActor.run {
                    self.NotamsInfo = str
                }
            }
        } catch {
            print("Error loading NOTAMs: \(error.localizedDescription)")
        }
    }
    
        // MARK: - Networking Functions

    func loadRunways() async {
        // 1) Parse the METAR wind vector (e.g. "27005KT")
        if let rawVec = vm.wind_vector?.split(separator: " ").first {
            let dirPart   = rawVec.prefix(3)                 // "270"
            let speedPart = rawVec.dropFirst(3).dropLast(2)  // "05"
        
        }

        // 2) Build the AirportDB URL using your existing FreqapiKey
        guard let url = URL(string:
            "https://airportdb.io/api/v1/airport/\(airport.AirportCode)/?apiToken=\(FreqapiKey)"
        ) else {
            print("Invalid AirportDB URL")
            return
        }

        // 3) Minimal Codable for just the runway idents
        struct AirportDBResponse: Codable {
            struct Runway: Codable {
                let le_ident: String
                let he_ident: String
            }
            let runways: [Runway]
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let resp = try JSONDecoder().decode(AirportDBResponse.self, from: data)

            // 4) Extract and dedupe all ends (["04L","22R",...])
            let idents = resp.runways
                .flatMap { [$0.le_ident, $0.he_ident] }
                .filter { !$0.isEmpty }

            vm.runwayNumbers = Array(Set(idents))
                .sorted { $0 < $1 }
            
            print("RWYS \(vm.runwayNumbers)" )

        } catch {
            print("Error loading runways:", error)
        }
    }


    

}

