//
//  NOTAMS_View .swift
//  New_Foreflight
//
//  Created by John Foster on 12/24/23.
//

import SwiftUI

struct NOTAMS_View_: View {
    
    let NotamsJson: String
    let curr_ap : Airport
    @EnvironmentObject private var vm : AirportDetailModel
    
    
    var body: some View {
        
        let frequencies:KeyValuePairs <String, String> = [
            "Key1": "112.3",
            "Key2": "121.9"
        ]
        
        
            List {
                ForEach(frequencies, id: \.0) { key, value in

                    HStack {
                        Text("\(key):")
                        Spacer()
                        Text("\(value)")
                    }
                }            .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)) // Adjust padding as needed

            }
           
        
    }
}

