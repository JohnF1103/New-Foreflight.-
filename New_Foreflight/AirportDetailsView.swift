//
//  AirportDetailsView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/23/23.
//

import SwiftUI
import PDFKit

// Add this:



struct AirportDetailsView: View {
    
    @EnvironmentObject private var vm : AirportDetailModel
    @State private var image: UIImage? = nil
    @State private var PlateInfo: String = ""
    @State private var FrequencyInfo: String = ""
    
    @State private var isFreqenciespresented = false
    @State private var FreqapiKey = "9d0b8ab9c176ca96804eac20c1936b5b2b058965c1c0e6ffbfd4c737730dfe8f5d175f8f447b6be1b9875346c5f00cc3"
    
    
    
    @State var isPresenting = false
    @State private var selectedItem = 1
    @State private var oldSelectedItem = 1
    //Should take in a METAR obj potentially
    
    let airport : Airport
    let curr_mertar: String
    
    
    
    /*TOO add these as properties of VM*/
    
    /*  let Notams : String
     let runways : String */
    
    
    
    var body: some View {
        TabView{
            TaxiDiagramSection
                .tabItem {
                    Image(systemName: "airplane.arrival")
                    Text("Airport")
                }
            METAR_View(JSON_Metar: self.curr_mertar, curr_ap: self.airport)
                .tabItem {
                    Image(systemName: "cloud.fill")
                    Text("METAR")
                }
            
            PlatesView(plateJSON: self.PlateInfo, curr_ap: self.airport)
                .tabItem {
                    Image(systemName: "road.lanes")
                    Text("Plates")
                }
            
            FrequenciesView(FreqenciesJSON: self.FrequencyInfo, curr_ap: self.airport)
                .tabItem {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                    Text("Frequencies")
                }
        }
        .tabViewStyle(.page)  // Move this line here
        .onAppear {
            print("Hello I APPEARED!")
            DispatchQueue.main.async {
                loadImageFromAPI()
                LoadFrequencies()
                LoadPlates()
            }
        }
        
        
    }
    
    
}

/*
 #Preview {
 AirportDetailsView(airport: Airport(id: UUID(), AirportCode: "KJFK", latitude: 40.63972222222222, longitude: -73.77888888888889), curr_mertar: "METAR")
 }
 */

extension AirportDetailsView{
    
    private var TaxiDiagramSection: some View{
        VStack{
            Imagesection
                .shadow(color: Color.black.opacity(0.3), radius: 20,x: 0,y:10)
            
            
            VStack(alignment: .leading, spacing: 16){
                Titlesection(curr_ap: airport, subtitle: "Airport", flightrules: vm.flightrules!)
                Divider()
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
            .padding()
            
            
        }
        
        
        
    }
    private var Imagesection:  some View{
        //add approach plates
        
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("Loading Image...")
            }
        }
        
        .scaledToFit()
        .frame(width: UIScreen.main.bounds.width)
        .clipped()
        .padding()
        
        
        .frame(height: 500)
        .tabViewStyle(PageTabViewStyle())
    }
    
    
    
    private var TabSection: some View{
        
        VStack(alignment: .leading, spacing: 8){
            
            
            
            
            
            
            
            
        }
    }
    
    
    private var BackButton: some View{
        
        Button{
            vm.sheetlocation = nil
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
    
    func loadImageFromAPI() {
        guard let url = URL(string: "https://cloudfront.foreflight.com/diagrams/2312/\(airport.AirportCode.lowercased()).jpg") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            }
        }.resume()
    }
    
    
    func LoadPlates(){
        
        //Q for david. Load & parse at the same time? or is it ok to load on view apperence & parse on button click
        //Q for david. frontend exposure. should this be loaded from out OWN API?
        /*guard let url = URL(string: "https://api.aviationapi.com/v1/charts?apt=\(airport.AirportCode.lowercased())") else {
         print("Invalid URL")
         return
         }*/
        
        
        
        
        
        let semaphore = DispatchSemaphore (value: 0)
        
        var request = URLRequest(url: URL(string: "https://api.aviationapi.com/v1/charts?apt=\(airport.AirportCode.lowercased())")!,timeoutInterval: Double.infinity)
        
        
        request.addValue("8bf1b3467a3548a1bb8b643978", forHTTPHeaderField: "X-API-Key")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            
            self.PlateInfo = String(data: data, encoding: .utf8)!
            print("PLATE INFO FOR ", airport.AirportCode.lowercased())
            
            semaphore.signal()
        }
        
        
        task.resume()
        semaphore.wait()
        
        
    }
    
    
    func LoadFrequencies(){
        
        
        //Q for david. Load & parse at the same time? or is it ok to load on view apperence & parse on button click
        //Q for david. frontend exposure. should this be loaded from out OWN API?
        
        
        let semaphore = DispatchSemaphore (value: 0)
        
        var request = URLRequest(url: URL(string: "https://airportdb.io/api/v1/airport/\(self.airport.AirportCode)?apiToken=\(self.FreqapiKey)")!,timeoutInterval: Double.infinity)
        
        
        request.addValue("8bf1b3467a3548a1bb8b643978", forHTTPHeaderField: "X-API-Key")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            
            self.FrequencyInfo = String(data: data, encoding: .utf8)!
            
            semaphore.signal()
        }
        
        
        task.resume()
        semaphore.wait()
        
    }
    
    
    
}
