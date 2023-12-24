//
//  LocationPreviewView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/20/23.
//

import SwiftUI

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
            
            var semaphore = DispatchSemaphore (value: 0)

            var request = URLRequest(url: URL(string: "https://api.checkwx.com/metar/\(airport.AirportCode)/decoded")!,timeoutInterval: Double.infinity)


            request.addValue("8bf1b3467a3548a1bb8b643978", forHTTPHeaderField: "X-API-Key")

            request.httpMethod = "GET"

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
              guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                return
              }
                
                 curr_metar_of_selected_Airport = String(data: data, encoding: .utf8)!
                

              semaphore.signal()
            }


            task.resume()
            semaphore.wait()
            
            
            vm.sheetlocation = airport
            vm.curr_metar = curr_metar_of_selected_Airport
            
            
            
        }label: {
            Text("Airport Info")
                .font(.headline)
                .frame(width: 125, height: 35)
        }.buttonStyle(.borderedProminent)
    }
    
    
    private var Weatherbutton: some View{
        Button{
            
            
            
        }label: {
            Text("View NOTAMS")
            
                .font(.headline)
                .frame(width: 125, height: 35)
        }.buttonStyle(.bordered)
        
    }
  
    
    
}

#Preview {
    
    ZStack{
        
        Color.green.ignoresSafeArea()
        
        //LocationPreviewView(airport: Airport(id: UUID(), AirportCode: "KJFK", latitude: 40.63972222222222, longitude: -73.77888888888889))
        
            .padding()
    }
   
}


