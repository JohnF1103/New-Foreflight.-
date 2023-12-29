//
//  PlatesView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/28/23.
//

import SwiftUI
import PDFKit
import WebKit



struct PlatesView: View {
    
    
    let plateJSON: String
    let curr_ap : Airport
    @State private var isPresentWebView = false
    
    let url: URL! = URL(string: "http://developer.apple.com/iphone/library/documentation/UIKit/Reference/UIWebView_Class/UIWebView_Class.pdf")

    var body: some View {
        
        
        let plates:KeyValuePairs <String, [(String, String)]> = [
            "SID": [("ORKA5", ""), ("JFK5", "")],
            "STAR": [("CARMN4", "")]
        ]
            
        
        
    
        
        NavigationView {
            
            
            
            
            if let chartDictionary = parseAirportCharts(apiOutputString: plateJSON, airport: curr_ap){                
                    // Process the parsed data
                
                List {
                    ForEach(plates, id: \.0) { key, values in
                        Section(header: Text("\(key):")) {
                            ForEach(values, id: \.0) { tuple in
                                HStack {
                                    Spacer().frame(width: 15) // Adjust spacing as needed
                                    
                                    PDFButton
                                   

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
        
    private var PDFButton: some View{
        
        
        Button("Open WebView") {
                    // 2
                    isPresentWebView = true

                }
                .sheet(isPresented: $isPresentWebView) {
                    NavigationStack {
                        // 3
                        WebView(url: url!)

                            .ignoresSafeArea()
                            .navigationTitle("Sarunw")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
    }
    
}
