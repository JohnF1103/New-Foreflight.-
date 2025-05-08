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
        
        var displayConverted : Bool = false
        VStack(spacing: 2){
            Titlesection(curr_ap: self.curr_ap, subtitle: "NOTAMS", flightrules: vm.flightrules ?? "Nil",symbol:"envelope.badge").padding(.all)
            Divider()
            
            if let notamsDict = parseNOTAMS(json_notams: NotamsJson){
                
                let sortedNotams = notamsDict.sorted { $0.key < $1.key }
                
                
                
                List {
                    Button("\(Image(systemName:"sparkles")) Convert NOTAMs"){
                        let convertedNotams = Helper(data: sortedNotams)
                        print(convertedNotams)
                        displayConverted = !displayConverted
                    }
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

extension NOTAMS_View_{
    func Helper(data:[Dictionary<String,[String]>.Element]) -> [Dictionary<String,[String]>.Element]{
        print("Convert NOTAMs")
        var result : [String:[String]] = [:]
        for kvp in data{
            let notamArray : [String] = kvp.value
            var temp : [String] = []
            for notam in notamArray{
                temp.append(ConvertNOTAM(data:notam))
            }
            result[kvp.key] = temp
        }
        return result.sorted{$0.key < $1.key}
    }
    // TODO: Implement AI to actually convert the NOTAMs
    func ConvertNOTAM(data: String) -> String{
        return ":3"
    }
}

