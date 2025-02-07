//
//  LocationPreviewView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/20/23.
//

import SwiftUI

struct ServerResponse: Decodable {
    /**/
    var metar_data: String? = nil
    var flight_rules: String? = nil
    var metar_components: MetarComponents
}
struct MetarComponents: Decodable{
    var wind: String
    var clouds: [Cloud]
    var visibility: String
    var temperature: String
    var dewpoint: String
    var barometer: String
    var humidity: String
    var elevation: String
    var density_altitude: Int = 0
}
struct Cloud: Decodable{
    var code: String
    var feet: String
}
struct LocationPreviewView: View {
    
    let airport: Airport
    @EnvironmentObject private var vm : AirportDetailModel
    
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0){
            VStack(alignment: .leading, spacing: 16){
                
                
              
                
                imageSection
                titlesection
            }
            
            VStack(spacing:8){
                
                AirportINFOButton
                Weatherbutton
            }
            
          
            
            
            
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 10)
            .fill(.ultraThinMaterial)
            .offset(y:65)
        
        )
        
        .cornerRadius(10)
        
    }
    
}

extension LocationPreviewView{
    
    
    private var imageSection: some View{
        
        
        
        ZStack{
            Image(systemName: "airplane.departure")
                
            
            
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .cornerRadius(10)
            
        }
        
        .padding(6)
        .cornerRadius(10)
        
        
        
        
    }
    
    private var titlesection: some View{
        
        VStack(alignment: .leading, spacing: 4){
            Text(airport.AirportCode)
            
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Airport")
            
                .font(.subheadline)
        
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var AirportINFOButton: some View{
        
        Button{
            var curr_metar_of_selected_Airport = ""

            //changes view
            
            //**TODO** Use completion handler to capture return value of async funciton.
            
            let semaphore = DispatchSemaphore (value: 0)
            //var request = URLRequest(url: URL(string: "https://api.checkwx.com/metar/\(airport.AirportCode)/decoded")!,timeoutInterval: Double.infinity)
            var request = URLRequest(url: URL(string: "https://wx-svc-x86-272565453292.us-central1.run.app/api/v1/getAirportInfo?airportCode=KEWR")!,timeoutInterval: Double.infinity)

            request.httpMethod = "GET"

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
              guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                return
              }
                
                 curr_metar_of_selected_Airport = String(data: data, encoding: .utf8)!
                print(curr_metar_of_selected_Airport)

              semaphore.signal()
            }


            task.resume()
            semaphore.wait()
            let jsonData = curr_metar_of_selected_Airport.data(using:.utf8)!
            let metarData : ServerResponse = try! JSONDecoder().decode(ServerResponse.self,from: jsonData)
            vm.curr_metar = metarData.metar_data
            print(metarData.metar_components)
            vm.sheetlocation = airport
            let cloudCode = String(metarData.metar_components.clouds.first?.code ?? "n/a")
            let cloudFeet = String(metarData.metar_components.clouds.first?.feet ?? "")
            let cloudAGL = cloudCode + " at " + cloudFeet + "ft"
            // TODO: Get this dictionary fixed up here instead of METAR_Parser
            let interestingNumbers: KeyValuePairs<String,String> = ["Time": "0",
                                                     "Wind": metarData.metar_components.wind,
                                                     "Visibility" : metarData.metar_components.visibility,
                                                                    "Clouds(AGL)": cloudAGL,
                                                     "Temperature": metarData.metar_components.temperature,
                                                     "Dewpoint": metarData.metar_components.dewpoint,
                                                     "Altimeter": metarData.metar_components.barometer,
                                                     "Humidity": metarData.metar_components.humidity,
                                                     "Density altitude": String(metarData.metar_components.density_altitude)]
            vm.flightrules = metarData.flight_rules
            vm.parsed_metar = interestingNumbers
            
            
        }label: {
            Text("Airport Info")
                .font(.headline)
                .frame(width: 125, height: 35)
        }.buttonStyle(.borderedProminent)
    }
    
    
    private var Weatherbutton: some View{
        Button{
            
            
            
        }label: {
            Text("Plan flight")
            
                .font(.headline)
                .frame(width: 125, height: 35)
        }.buttonStyle(.bordered)
        
    }
  
    
    
}

/*#Preview {
    
    ZStack{
        
        Color.green.ignoresSafeArea()
        
        //LocationPreviewView(airport: Airport(id: UUID(), AirportCode: "KJFK", latitude: 40.63972222222222, longitude: -73.77888888888889))
        
            .padding()
    }
   
}
*/

