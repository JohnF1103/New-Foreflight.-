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
    
    @State private var active = ("Unicom",122.8.rounded())
    @State private var SBY = ("",122.8.rounded())


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
        

    
        
        HStack {
            NavigationView {
                
                if let frequenciesDict = parseFrequencies(json_frequencies: FreqenciesJSON) {
                    
                    List {
                        ForEach(frequenciesDict.sorted(by: { $0.0 < $1.0 }), id: \.key) { key, value in

                            Button {
                                print(key)
                                self.active = (key, Double(value)!)
                            } label: {
                                VStack {
                                    Text("\(key):")
                                    Text("\(value):")
                                }
                            }
                            .id(UUID()) // Use UUID as a stable identifier
                            .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)) // Adjust padding as needed
                        }
                    }
                    .navigationTitle("Frequencies")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            
            VStack(spacing: 10) {
                Text("Active: \(self.active.0) \(self.active.1, specifier: "%.1f")")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                    .foregroundColor(.white)
                    .frame(width: 200) // Set a fixed width for the container
                
                Text("Standby: \(self.SBY.0) \(self.SBY.1,specifier: "%.1f")")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.green))
                    .foregroundColor(.white)
                
                    .frame(width: 200) // Set a fixed width for the container
                
                Button {
                    
                    let temp = self.active
                    self.active = self.SBY
                    self.SBY = temp
                } label: {
                    Image(systemName: "arrowshape.left.arrowshape.right.fill")
                }
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray))
                .padding()


            }.ignoresSafeArea()
            Spacer()
        }.ignoresSafeArea()

        
        
     
    }
}
