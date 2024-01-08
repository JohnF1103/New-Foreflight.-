//
//  METAR_View.swift
//  New_Foreflight
//
//  Created by John Foster on 12/24/23.
//

import SwiftUI



struct METAR_View: View {

    
    let JSON_Metar : String
    let curr_ap : Airport

    @EnvironmentObject private var vm : AirportDetailModel

    var body: some View {
        
        
        RAW_Metar
        
    }
}


extension METAR_View{
    
    
    
 
    
    
    
    private var RAW_Metar: some View{
       
        
        VStack(spacing: 2){
            
                        if let parsedText = parseRawText(jsonString: JSON_Metar) {
                Text(parsedText).foregroundStyle(Color.green).padding(.top)
                   

                        
                Titlesection(curr_ap: curr_ap, subtitle: "METAR", flightrules: getFlightRules(metar: parsedText))
                Divider()

                
                let order_metar:KeyValuePairs = getComponents(metar: parsedText)

                            
                            
                
               //translated
                List {
                    ForEach(order_metar, id: \.0) { key, value in
                        
                        HStack {
                            Text("\(key):")
                            Spacer()
                            Text("\(value)")
                        }
                    }            .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)) // Adjust padding as needed
                    
                }
                
               
            } else {
                Text("API ERROR, NIL METAR").foregroundStyle(Color.red)
            }
           
        }.padding(.all)
            .padding(.top)

        
    }
    
}
