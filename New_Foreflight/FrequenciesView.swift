//
//  FrequenciesView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/28/23.
//

import SwiftUI

struct FrequenciesView: View {
    
    let FreqenciesJSON: String
    let curr_ap : Airport
    var body: some View {
        
        
        let frequencies:KeyValuePairs <String, String> = [
            "GRD": "112.3",
            "TWR": "112.3",
            "APPRCH": "112.3",
            "DEP": "112.3",
            "TWR2": "112.3",
            "CTR": "112.3",
            "ATIS": "112.3",
            "blah blah": "112.3",
          

        ]
        
        HStack{
            NavigationView {
                List {
                    ForEach(frequencies, id: \.0) { key, value in

                        HStack {
                            Text("\(key):")
                            Spacer()
                            Text("\(value)")
                        }
                    }            .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)) // Adjust padding as needed

                }
                .navigationTitle("Nearby Frequencies")
                .navigationBarTitleDisplayMode(.inline)
            }
            
            VStack(spacing: 10) {
                Text("Acvive frequency Unicom 122.8")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                    .foregroundColor(.white)
                
                Text("Standby frequecy GRD 121.9")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.green))
                    .foregroundColor(.white)
            }.offset(y:-195
            )
            
            
        }
        
        
     
    }
}
