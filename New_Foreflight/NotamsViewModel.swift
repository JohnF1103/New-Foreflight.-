//
//  NotamsViewModel.swift
//  New_Foreflight
//
//  Created by John Foster on 12/28/23.
//

import Foundation
import SwiftUI


struct NOTAM: Decodable {
    enum Category: String, Decodable {
        case swift, combine, debugging, xcode
    }

    let location: String
    let value: String
 
}




func parseNOTAMS(json_notams: String) -> [String: [String]]? {
    // Convert the JSON string to Data
    // Check if the JSON data is not empty
    
    
    
    /**THIS IS A TEST STR TO SAVE API CALLS!    TO USE LIVE NOTAMS FROM API USE JSON NOTAMS PARAM**/
    let testnotams = """
    [
        {
            "all": "!EWR 01/136 EWR RWY 04L/22R CLSD 2401160716-2401160800\\nCREATED: 16 Jan 2024 07:16:00 \\nSOURCE: EWR",
            "id": "!EWR 01/136",
            "location": "KEWR",
            "isICAO": false,
            "key": "!EWR 01/136-KEWR",
            "type": "airport",
            "StateCode": "USA",
            "StateName": "United States of America",
            "criticality": -1
        },
        {
            "all": "!EWR 01/135 EWR TWY ALL SFC MARKINGS OBSC 2401160635-2401162359\\nCREATED: 16 Jan 2024 06:36:00 \\nSOURCE: EWR",
            "id": "!EWR 01/135",
            "location": "KEWR",
            "isICAO": false,
            "key": "!EWR 01/135-KEWR",
            "type": "airport",
            "StateCode": "USA",
            "StateName": "United States of America",
            "criticality": -1
        },
        {
            "all": "!EWR 01/133 EWR TWY ALL FICON 1/8IN DRY SN DEICED LIQUID OBS AT 2401160629. 2401160629-2401170629\\nCREATED: 16 Jan 2024 06:29:00 \\nSOURCE: EWR",
            "id": "!EWR 01/133",
            "location": "KEWR",
            "isICAO": false,
            "key": "!EWR 01/133-KEWR",
            "type": "airport",
            "StateCode": "USA",
            "StateName": "United States of America",
            "criticality": -1
        }
    ]
    """
        
    
    
    var notamsDict: [String: [String]] = [:]
    
    //SUB IN API OR TEST VAL HERE! ALSO CALL LOADNOTAMS IN AIRPORTDETAILSVIEW
    if let jsonData = testnotams.data(using: .utf8) {
        do {
            // Parse JSON Data
            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                // Iterate through the list and print "all" values
                for item in jsonArray {
                    if let notamvalue = item["all"] as? String{
                        if let loc = item["location"] as? String{
                            //here
                            
                            if var valuesForLoc = notamsDict[loc] {
                                                       // Append the new "all" value to the existing array
                                                       valuesForLoc.append(notamvalue)
                                                       // Update the dictionary with the modified array
                                                       notamsDict[loc] = valuesForLoc
                                                   } else {
                                                       // If the location key doesn't exist, create a new array with the "all" value
                                                       notamsDict[loc] = [notamvalue]
                                                   }
                        }
                    }
                }
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
    
    return notamsDict.isEmpty ? nil : notamsDict
    
    
}

