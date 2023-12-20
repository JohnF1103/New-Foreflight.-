//
//  Airport.swift
//  New_Foreflight
//
//  Created by John Foster on 12/20/23.
//

import Foundation


struct Airport: Identifiable, Codable, Equatable {
    let id: UUID
    let AirportCode : String
    let latitude: Double
    let longitude: Double
}
