//
//  Titlesection.swift
//  New_Foreflight
//
//  Created by John Foster on 1/8/24.
//

import SwiftUI
extension HorizontalAlignment{
    private struct IconAlignment : AlignmentID{
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.leading]
        }
        
        
        
    }
    static let iconAlignmentGuide = HorizontalAlignment(IconAlignment.self)
}

struct Titlesection: View {
    
    let curr_ap : Airport
    let subtitle: String
    let flightrules :String
    var symbol: String? = nil

    
    var body: some View {
            
        
            
           VStack(alignment: .iconAlignmentGuide, spacing: 8){
                HStack(){
                    Text(curr_ap.AirportCode)
                        .font(.largeTitle)
                        .fontWeight(.semibold).alignmentGuide(.iconAlignmentGuide){
                            context in context[HorizontalAlignment.leading]
                        }
                    Spacer(minLength:1)
                    
                    if(symbol != nil){
                        Image(systemName:symbol!).font(.largeTitle).alignmentGuide(.iconAlignmentGuide){
                            context in context[HorizontalAlignment.center]
                        }
                    }
                    else{
                        Text(" ").alignmentGuide(.iconAlignmentGuide){
                            context in context[HorizontalAlignment.center]
                        }
                    }
                    
                    
                }
               HStack() {
                   Text(subtitle)
                       .font(.title3)
                       .foregroundColor(.secondary).alignmentGuide(.iconAlignmentGuide){
                           context in context[HorizontalAlignment.leading]
                       }
                   
                   Spacer(minLength: 1)
                   Text(flightrules.uppercased())
                    .foregroundStyle(flightrules.lowercased().first == "v" ? Color.green : flightrules.lowercased().first == "i" ? Color.red : Color.white).alignmentGuide(.iconAlignmentGuide){
                            context in context[HorizontalAlignment.center]}
                    
               }
                
                
               
                
                
            
        }
    }
}

