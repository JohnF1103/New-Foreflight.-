//
//  AirportDetailsView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/23/23.
//

import SwiftUI

struct AirportDetailsView: View {
    
    @EnvironmentObject private var vm : AirportDetailModel
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
   

#Preview {
    AirportDetailsView(airport: Airport(id: UUID(), AirportCode: "KJFK", latitude: 40.63972222222222, longitude: -73.77888888888889), curr_mertar: "METAR")
}


extension AirportDetailsView{
    
    private var Imagesection:  some View{
        //add approach plates
        TabView{
            Image(systemName: "square.and.arrow.up.fill")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width)
                .clipped()
            
        }
        .frame(height: 500)
        .tabViewStyle(PageTabViewStyle())
    }
    
    private var titleseciton: some View{
        
        VStack(alignment: .leading, spacing: 8){
            
            Text(airport.AirportCode)
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("Airport")
                .font(.title3)
                .foregroundColor(.secondary)
            
            
            
        }
    }
    
    private var TabSection: some View{
        
        VStack(alignment: .leading, spacing: 8){
            
            
            TabView {
                        ScrollView {
                            METAR_View(JSON_Metar: self.curr_mertar)
                                .padding()
                        }
                        .tabItem {
                            Image(systemName: "1.circle")
                            Text("First")
                        }
                        .tag(1)
                        
                        Text("Second View")
                            .padding()
                            .tabItem {
                                Image(systemName: "2.circle")
                                Text("Second")
                            }
                            .tag(2)
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
    
   
    
    
}
