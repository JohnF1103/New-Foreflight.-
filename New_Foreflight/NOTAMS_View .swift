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
        
       
        VStack(spacing: 2){
            Titlesection(curr_ap: self.curr_ap, subtitle: "NOTAMS", flightrules: vm.flightrules ?? "Nil").padding(.all)
            Divider()
            
            if let notamsDict = parseNOTAMS(json_notams: NotamsJson){
                
                let sortedNotams = notamsDict.sorted { $0.key < $1.key }

                
                
                List {
                    ForEach(sortedNotams, id: \.0) { key, values in
                        Section(header: Text("\(key):")) {
                            ForEach(values, id: \.self) {string in
                                Text(string)
                            }
                            
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)) // Adjust padding as needed
                }
                
            }else{
                
                Text("API ERROR NO NOTAMS").foregroundStyle(Color.red)
            }
        }.padding(.all)
           
        
    }
}

