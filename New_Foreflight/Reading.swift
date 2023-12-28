//
//  Reading.swift
//  New_Foreflight
//
//  Created by John Foster on 12/20/23.
//

import Foundation

func readFile() -> [Airport] {
    _ = "Airports.txt"
    
    var locs: [Airport] = []
    
    do {
        // Creating a path from the main bundle
        if let bundlePath = Bundle.main.path(forResource: "Airports", ofType: "txt") {
            let stringContent = try String(contentsOfFile: bundlePath)
            print("Content string starts from here-----")
            
            let lines = stringContent.components(separatedBy: .newlines)
            
            for line in lines {
                // Splitting the line into sets of components (assuming a colon-separated format)
                let sets = line.components(separatedBy: ":")
                
                // Iterating through each set of components
                for i in stride(from: 0, to: sets.count, by: 3) {
                    // Checking if there are enough components (code, latitude, longitude)
                    if i + 2 < sets.count {
                        // Extracting information
                        let anIACO = sets[i]
                        let aLAT = Double(sets[i + 1]) ?? 0.0
                        let aLONG = Double(sets[i + 2]) ?? 0.0
                        
                        
                        // Use the extracted information to instantiate an object or perform any other actions
                        
                        let L = Airport(id: UUID(), AirportCode: anIACO, latitude: aLAT, longitude: aLONG)
                        
                        locs.append(L)
                        
                    }
                }
            }
            
            print("End at here-----")
        }
    } catch {
        print(error)
    }
    
    return locs
}
