//
//  FrequenciesViewModel.swift
//  New_Foreflight
//
//  Created by John Foster on 12/28/23.
//

import Foundation
import SwiftUI

// TODO: Make this irrelevant
/*func parseFrequencies(json_frequencies: String) -> [String: String]? {
    // Convert the JSON string to Data
    // Check if the JSON data is not empty
    
    var frequenciesDictionary = [String: String]()

    if !json_frequencies.isEmpty, let jsonData = json_frequencies.data(using: .utf8) {
        do {
            // Parse JSON data
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                // Extract "freqs" key and its values
                if let freqs = jsonObject["freqs"] as? [[String: Any]] {
                    // Iterate through frequency entries
                    for freq in freqs {
                        // Print frequency description and value
                        if let description = freq["description"] as? String,
                           let frequencyValue = freq["frequency_mhz"] as? String {
                            frequenciesDictionary[description] = frequencyValue
                            print("INSIDE FREQ PARSER")
                        } else {
                            print("Invalid frequency entry")
                        }
                    }
                } else {
                    print("No 'freqs' key found or it does not contain an array")
                }
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }

    return frequenciesDictionary.isEmpty ? nil : frequenciesDictionary
}
*/
