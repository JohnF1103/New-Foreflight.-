//
//  Fix.swift
//  New_Foreflight
//
//  Created by John Foster on 4/18/25.
//

import SwiftUI


struct Fix: Identifiable, Codable, Equatable {
    let id: UUID
    let Code : String
    let latitude: Double
    let longitude: Double
}
