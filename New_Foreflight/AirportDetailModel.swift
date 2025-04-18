//
//  AirportDetailModel.swift
//  New_Foreflight
//
//  Created by John Foster on 12/23/23.
//

import Foundation


class AirportDetailModel: ObservableObject{
    
    //airport optional for sheet. if we are nil we wont display the sheet.
    
    // airport optional for sheet. if we are nil we wont display the sheet.
        @Published var sheetlocation: Airport? = nil
        @Published var fixlocation: Fix? = nil

        @Published var curr_metar: String? = nil
        @Published var parsed_metar: KeyValuePairs<String, String>?
        @Published var DisplayLocationdetail = false
        @Published var DisplayFixDetail = false

        @Published var selected_airport: Airport?
        @Published var selectedFix: Fix?

        @Published var flightrules: String? = "VFR"
        @Published var selectedData: [String?] = ["Class_B", "Class_C", "Class_D", "special"]

        // New property to store runway identifiers
        @Published var runwayNumbers: [String] = []

        // Optional: wind vector, used for parsing wind info
        @Published var wind_vector: String? = nil
   

}



