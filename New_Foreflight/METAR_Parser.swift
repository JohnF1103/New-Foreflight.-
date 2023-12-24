//
//  METAR_Parser.swift
//  New_Foreflight
//
//  Created by John Foster on 12/24/23.
//

import Foundation
import SwiftMETAR


func parseRawText(jsonString: String) -> String? {
    do {
        // Convert the JSON string to Data
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Error converting JSON string to Data.")
            return nil
        }

        // Parse the JSON data
        let json = try JSONSerialization.jsonObject(with: jsonData, options: [])

        // Cast the JSON object to a dictionary
        guard let jsonDict = json as? [String: Any] else {
            print("Error casting JSON to dictionary.")
            return nil
        }

        // Extract the value for the "raw_text" key
        if let dataArray = jsonDict["data"] as? [[String: Any]], let rawText = dataArray.first?["raw_text"] as? String {
            return rawText
        } else {
            print("Error extracting value for 'raw_text' key.")
            return nil
        }
    } catch {
        print("Error parsing JSON: \(error)")
        return nil
    }
}


func getDate(metar: String) -> String{
    
    return "DATE: "
    
}
