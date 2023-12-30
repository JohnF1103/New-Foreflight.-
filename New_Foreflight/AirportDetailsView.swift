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
    @State private var isPlatesViewPresented = false
    
    
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
        ScrollView{
            VStack{
                Imagesection
                    .shadow(color: Color.black.opacity(0.3), radius: 20,x: 0,y:10)
                
                
                VStack(alignment: .leading, spacing: 16){
                    titleseciton
                    Divider()
                    TabSection
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
                .padding()
                
                
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

    private var Imagesection:  some View{
        //add approach plates
        TabView{

            VStack {
                     if let image = image {
                         Image(uiImage: image)
                             .resizable()
                             .scaledToFit()
                     } else {
                         Text("Loading Image...")
                     }
                 }
                 .onAppear {
                     // Make API call when the view appears
                    //this is where we will load the plates NOTAMS & freqs as well.
                     
                     
                     //Good Q for david 2 approaches. load data when view presented VS when parent button clicked?
                     loadImageFromAPI()
                     LoadPlates()
                 }
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width)
                .clipped()
                .padding()
            
        }
        .frame(height: 500)
        .tabViewStyle(PageTabViewStyle())
    }
    
    private var titleseciton: some View{
        
        VStack(alignment: .leading, spacing: 8){
            HStack(spacing: 150){
                Text(airport.AirportCode)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Text("100LL $4.23")
                    .foregroundStyle(Color.red)
                
            }
            
            Text("Airport")
                .font(.title3)
                .foregroundColor(.secondary)
            
            
            
        }
    }
    
    private var TabSection: some View{
        
        VStack(alignment: .leading, spacing: 8){
            
            
            TabView(selection: $selectedItem) {
                ScrollView {
                    METAR_View(JSON_Metar: self.curr_mertar)
                        .padding()
                }.frame(maxWidth: .infinity)
                .tabItem {
                    Image(systemName: "cloud.fill")
                    Text("METAR")
                }
                .tag(1)
                Text("Diaplaying plates...")
                .tabItem {
                    Image(systemName: "road.lanes")
                                    Text("Plates")
                }
                .tag(2)
                
                
                ScrollView{
                    NOTAMS_View_()
                }
                    .padding()
                    .tabItem {
                        Image(systemName: "exclamationmark.triangle")
                        Text("NOTAMS")
                    }
                    .tag(3)
                ScrollView{
                    FrequenciesView()
                    
                }
                    .padding()
                    .tabItem {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                        Text("Frequencies")
                    }
                    .tag(4)
            }
            .onChange(of: selectedItem) {    // SwiftUI 2.0 track changes
                        if 2 == selectedItem {
                        self.isPresenting = true
                        } else {
                            self.oldSelectedItem = $0
                        }
                    }
                .sheet(isPresented: $isPresenting, onDismiss: {
                        self.selectedItem = self.oldSelectedItem
                    }) {
                        PlatesView(plateJSON: self.PlateInfo, curr_ap: self.airport)
                }


            
            
            .frame(height: 200) // Adjust the height as needed
            
            
            
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
        guard let url = URL(string: "https://api.aviationapi.com/v1/charts?apt=\(airport.AirportCode.lowercased())") else {
                print("Invalid URL")
                return
            }

    
        
        
        
        var semaphore = DispatchSemaphore (value: 0)

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
    
    
    
}
