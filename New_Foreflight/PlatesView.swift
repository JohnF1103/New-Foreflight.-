//
//  PlatesView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/28/23.
//

import SwiftUI
import WebKit





struct PlatesView: View {
    
    
    let plateJSON: String
    let curr_ap : Airport
    @State private var isPresentWebView = false


    var body: some View {
    
        
        NavigationView {
            
            
            
            if let chartDictionary = parseAirportCharts(apiOutputString: plateJSON, airport: curr_ap) {

                // Convert the dictionary to an array of key-value pairs and sort it
                let sortedCharts = chartDictionary.sorted { $0.key < $1.key }

                // Process the parsed data
                List {
                    ForEach(sortedCharts, id: \.0) { key, values in
                        Section(header: Text("\(key):")) {
                            ForEach(values, id: \.0) { tuple in
                                HStack {
                                    Spacer().frame(width: 15) // Adjust spacing as needed
                                    //HERE
                                    
                                    WebViewRow(urlString: tuple.1, chartname: tuple.0)



                                }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)) // Adjust padding as needed
                }
                .navigationTitle("Plates ")
                .navigationBarTitleDisplayMode(.inline)

            } else {
                Text("API ERROR, NIL METAR").foregroundStyle(Color.red)
            }

            
        }
        
        

        
        
    }
}
extension PlatesView{
            
}
