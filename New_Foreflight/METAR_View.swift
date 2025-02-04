//
//  METAR_View.swift
//  New_Foreflight
//
//  Created by John Foster on 12/24/23.
//


import SwiftUI

struct METAR_View: View {
    let JSON_Metar: String
    let curr_ap: Airport
    
    @EnvironmentObject private var vm: AirportDetailModel
    
    var body: some View {
        
    

        VStack(spacing: 16) {
            // Airport Information Section
            HStack {
                Image(systemName: "airplane.circle.fill") // Placeholder for airport logo
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
                VStack(alignment: .leading) {
                    Text(curr_ap.AirportCode)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("METAR Information")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 5))
            
            Divider()
            
            // RAW METAR Section
            VStack(alignment: .leading, spacing: 8) {
                Text("RAW METAR")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                Text(vm.curr_metar ?? "NO METAR")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.primary)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)).shadow(radius: 5))
                    
                
            }
            
            
            // Translated METAR Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Translated METAR")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                let order_metar: KeyValuePairs = getComponents(metar: vm.curr_metar ?? "NO METAR")
                
                ForEach(order_metar, id: \.0) { key, value in
                    HStack {
                        Image(systemName: iconName(for: key)) // Function to map keys to system icons
                            .foregroundColor(.blue)
                            .font(.system(size: 14)) // Adjust the size as needed

                        Text("\(key):")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(value)")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 5))
        }
        .padding()
        
        
    }
    
    // Function to map METAR components to system icon names
    private func iconName(for key: String) -> String {
        switch key {
        case "Wind":
            return "wind"
        case "Visibility":
            return "eye"
        case "Clouds(AGL)":
            return "cloud"
        case "Temperature":
            return "thermometer"
        case "Dewpoint":
            return "drop"
        case "Altimeter":
            return "barometer"
        case "Humidity":
            return "humidity"
        default:
            return "info.circle"
        }
    }
}
