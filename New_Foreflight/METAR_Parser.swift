//
//  METAR_Parser.swift
//  New_Foreflight
//
//  Created by John Foster on 12/24/23.
//

import Foundation
import METAR







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











func getComponents(metar: String) -> Dictionary<String ,String>{
    
    //has to match foreflight exactly so forced to hard code? or does it idk
    
    
    var localtime = ""
    var description = ""
    var winds = "" 
    var vis = ""
    var clouds = ""
    var temp = ""
    var dewP = ""
    var altimiter = ""
    var humidity = ""

    // Example usage:
    
    
    let met = METAR(metar)
        
    print(met?.visibility)
    print(met?.cloudLayers)
    print(met?.temperature)
    print(met?.dewPoint)
    print(met?.qnh?.converted(to: .inchesOfMercury))
    print(met?.relativeHumidity)
    

    
    
    if let direction = met?.wind?.direction  {
        let windDirectionString = "\(direction)"
        let windspeedString = met?.wind?.speed
        
        winds = "\(windDirectionString) at \(windspeedString!)kts"

    } else {
        print("Default value for nil case")
    }


    var interestingNumbers = ["Time": "",
                              "Wind": winds,
                              "Clouds(AGL)": "",
                              "Tempature": "",
                              "Dewpoint": "",
                              "Altimiter": "",
                              "Humidity": "",
                              "Density altitude": ""]
    
    return interestingNumbers
}


