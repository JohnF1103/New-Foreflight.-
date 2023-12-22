//
//  LocationPreviewView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/20/23.
//

import SwiftUI

struct LocationPreviewView: View {
    
    let airport: Airport
    
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0){
            VStack(alignment: .leading, spacing: 16){
                
                
              
                
                imageSection
                titlesection
            }
            
            VStack(spacing:8){
                
                NOTAMButton
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
    
    private var NOTAMButton: some View{
        
        Button{
            
            
            
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
        
        LocationPreviewView(airport: Airport(id: UUID(), AirportCode: "KJFK", latitude: 40.63972222222222, longitude: -73.77888888888889))
        
            .padding()
    }
   
}


