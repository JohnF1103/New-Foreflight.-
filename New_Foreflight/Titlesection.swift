//
//  Titlesection.swift
//  New_Foreflight
//
//  Created by John Foster on 1/8/24.
//

import SwiftUI

struct Titlesection: View {
    
    let curr_ap : Airport
    let subtitle: String
    let flightrules :String
    var symbol: String? = nil

    
    var body: some View {

            
            VStack(alignment: .leading, spacing: 8){
                HStack(spacing: 150){
                    Text(curr_ap.AirportCode)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    if(symbol != nil){
                        Image(systemName:symbol!).font(.largeTitle)
                    }
                    else{
                        Text("")
                    }
                    
                }
                HStack() {
                    Text(subtitle)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Spacer(minLength: 1)
                    Text(flightrules.uppercased())
                        .foregroundStyle(flightrules.lowercased().first == "v" ? Color.green : flightrules.lowercased().first == "i" ? Color.red : Color.white)
                }
                
                
               
                
                
            
        }
    }
}

