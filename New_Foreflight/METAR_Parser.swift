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


func getTime(metar: String) -> String{
    
    var localtime = ""
    
    
    do {
        let observation = try METAR.from(string: metar)
        localtime =  observation.date.formatted(date: .omitted, time: .complete)
    } catch {
        print("Error: \(error)")
    }
    
    
    
    return localtime
}


func visibilityDescription(_ visibility: Visibility) -> String {
      switch visibility {
      case let .equal(value):
          return "Visibility is equal to \(value) meters."

      case let .greaterThan(value):
          return "greater than \(value) meters."

      case let .lessThan(value):
          return "Visibility is less than \(value) meters."

      case let .variable(min, max):
          return "Visibility is variable between \(min) and \(max) meters."
      }
  }


func windDescription(_ wind: Wind) -> String{
    switch wind{
    case .calm:
               return "No winds detected, or variable winds with speed under 3 knots."

           case let .direction(heading, speed, gust):
               if let gustSpeed = gust {
                   return "\(heading)° at \(speed.knots)kts, G\(gustSpeed) kts."
               } else {
                   return "\(heading)° at \(speed.knots)kts"
               }

           case let .directionRange(heading, headingRange, speed, gust):
               if let gustSpeed = gust {
                   return "Wind direction: \(heading)°, Heading Range: \(headingRange), Speed: \(speed) knots, Gust: \(gustSpeed) knots."
               } else {
                   return "Wind direction: \(heading)°, Heading Range: \(headingRange), Speed: \(speed) knots."
               }

           case let .variable(speed, headingRange):
               if let headingRange = headingRange {
                   return "Variable wind direction, Speed: \(speed) knots, Heading Range: \(headingRange)."
               } else {
                   return "Variable wind direction, Speed: \(speed) knots."
               }
           }
       
    
    
}



func getComponents(metar: String) -> Dictionary<String ,String>{
    
    //has to match foreflight exactly so forced to hard code? or does it idk
    
    var localtime = ""
    var description = ""
    var vis = ""
    var clouds = ""
    var temp = ""
    var dewP = ""
    var altimiter = ""
    var humidity = ""

    
    
    do {
        let observation = try METAR.from(string: metar)
        localtime =  observation.date.formatted(date: .omitted, time: .complete)
        
        clouds = observation.conditions.description
        
        print(clouds)
        
        if let vis = observation.visibility{
            
            print(visibilityDescription(observation.visibility!))
        }
        
       
        
        if let winds = observation.wind{
            
            
                
                print(windDescription(winds))
                
            }
        
        
        
        
        
    } catch {
        print("Error: \(error)")
    }
    
    
    
    
    
    
    
    
    var interestingNumbers = ["Time": localtime,
                              "Wind": "",
                              "Clouds(AGL)": "",
                              "Tempature": "",
                              "Dewpoint": "",
                              "Altimiter": "",
                              "Humidity": "",
                              "Density altitude": ""]
    
    return interestingNumbers
}


