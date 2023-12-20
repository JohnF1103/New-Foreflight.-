//
//  Response.swift
//  New_Foreflight
//
//  Created by John Foster on 12/19/23.
//

import Foundation

struct WeatherMapsResponse: Codable {
    let version: String
    let generated: Int
    let host: String
    let radar: Radar
    let satellite: Satellite
}

struct Radar: Codable {
    let past, nowcast: [Nowcast]
}

struct Nowcast: Codable {
    let time: Int
    let path: String
}

struct Satellite: Codable {
    let infrared: [Nowcast]
}
