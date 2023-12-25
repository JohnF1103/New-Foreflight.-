//
//  METAR_View.swift
//  New_Foreflight
//
//  Created by John Foster on 12/24/23.
//

import SwiftUI



struct METAR_View: View {
    let JSON_Metar : String
    
    
    var body: some View {
                RAW_Metar
                Spacer()

        
        
        
        
        if let parsedText = parseRawText(jsonString: JSON_Metar) {
            
            
            var emptyDict: [String: String] = getComponents(metar: parsedText)

            HStack {
                
                //keys
                                   VStack {
                                       Text("Time")
                                       Text("Wind")
                                       Text("Visibility")
                                       Text("Clouds(AGL)")
                                       Text("Temoature")
                                       Text("Dewpoint")
                                       Text("Altimiter")
                                       Text("Humidity")

                                   }
    //vals
                                   VStack {
                                       Text("SOme string")
                                       Text("Some String")
                                       Text("Some String")
                                       Text("Some String")
                                       Text("Some String")
                                       Text("Some String")
                                       Text("Some String")

                                   }

                                  
                               }
                               .foregroundColor(.primary)
                               .padding()
                               .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.1)))
                               .padding(.horizontal)
           
        } else {
            Text("API ERROR, NIL METAR").foregroundStyle(Color.red)
        }
        
        
    }
}
#Preview {
    METAR_View(JSON_Metar: "hello")
}


extension METAR_View{
    
    private var RAW_Metar: some View{
        
        VStack(spacing: 2){
            Text("METAR")
            
            if let parsedText = parseRawText(jsonString: JSON_Metar) {
                Text(parsedText).foregroundStyle(Color.green)
               
            } else {
                Text("API ERROR, NIL METAR").foregroundStyle(Color.red)
            }
           
        }

        
    }
}
