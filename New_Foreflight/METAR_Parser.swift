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

func getFlightRules(metar:String) -> String{
    
    let met = METAR(metar)
    var fr = ""
    
    if let flightrules = met?.icaoFlightRules{
        
        fr = "\(flightrules)"
    }
    
    return fr
}



func getComponents(metar: String) -> KeyValuePairs<String ,String>{
    
    //has to match foreflight exactly so forced to hard code? or does it idk
    
    
    var localtime = ""
    var winds = ""
    var vis = ""
    var clouds = ""
    var temp = ""
    var dew = ""
    var altimiter = ""
    var humidity = ""

    // Example usage:

    
    let met = METAR(metar)
        

    if let time = met?.date.formatted(date: .omitted, time: .standard){
        localtime = time
    }else{
        print("error nil")
    }

    
    
    if let direction = met?.wind?.direction  {
        let windDirectionString = "\(direction)"
        let windspeedString = met?.wind?.speed
        
        winds = "\(windDirectionString) at \(windspeedString!)kts"

    } else {
        print("Default value for nil case")
    }
    
    if let vis_ = met?.visibility?.measurement.value {
        vis = "\(vis_)sm"
        
    }else{
        print("error vis nil")
    }
    
    
    
    if let clouds_ = met?.cloudLayers.first?.coverage {
        let cloud_height = met?.cloudLayers.first?.height
        clouds = "\(clouds_) \(cloud_height!)"
    }else{
        clouds = "error clouds nil"
    }
    
    
    if let dew_ = met?.dewPoint{
        dew = "\(dew_)"
    }else{
        dew = "dewpoint nil"
    }
    
    if let temp_ = met?.temperature{
        temp = "\(temp_)"
    }else{
        temp = "temp nil"
    }
    
    if let alt = met?.qnh?.converted(to: .inchesOfMercury){
        altimiter = "\(alt)"
    }else{
        altimiter = "alt nil"
    }
    
    if let hum = met?.relativeHumidity{
        humidity = "\( hum * 100)"
    }else{
        humidity = "hum nil"
    }
    

    

    let interestingNumbers: KeyValuePairs = ["Time": localtime,
                              "Wind": winds,
                              "Visibility" : vis,
                              "Clouds(AGL)": clouds,
                              "Tempature": temp,
                              "Dewpoint": dew,
                              "Altimiter": altimiter,
                              "Humidity": humidity,
                              "Density altitude": "formula"]
    
    
   
    

    
    return interestingNumbers
}


