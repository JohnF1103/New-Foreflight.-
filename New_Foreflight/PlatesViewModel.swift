//
//  PlatesViewModel.swift
//  New_Foreflight
//
//  Created by John Foster on 12/28/23.
//

import SwiftUI



struct AirportChartResponse: Decodable {
    
    let charts: [String: [Plate]]
}

struct Plate: Decodable {
    let state: String
    let stateFull: String
    let city: String
    let volume: String
    let airportName: String
    let isMilitary: String
    let faaIdent: String
    let icaoIdent: String
    let chartSeq: String
    let chartCode: String
    let chartName: String
    let pdfName: String
    let pdfPath: String
}
func parseAirportCharts(apiOutputString: String, airport: Airport) -> [String: (String, String)]? {
    print("INSDOE HERE")

    var allcharts: [String: String] = [:]
    do {
        if let jsonData = apiOutputString.data(using: .utf8) {
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: [[String: Any]]] {
                
                
                if let firstKey = jsonObject.keys.first,
                              let chartArray = jsonObject[firstKey] {
                    var chartArrayData: [[String: String]] = []
                    
                    for chartEntry in chartArray {
                        if let chartType = chartEntry["chart_code"] as? String, let chartName = chartEntry["chart_name"] as? String {
                            let chartData = ["chart_code": chartType, "chart_name": chartName]
                            chartArrayData.append(chartData)
                        }
                    }
                    
                    // Print the resulting array of dictionaries
                    let starCharts = chartArrayData.filter { $0["chart_code"] == "STAR" }
                                    
                                    // Print the values of the "STAR" charts
                        starCharts.forEach { print($0["chart_name"] ?? "") }
                }
            }
        }
    } catch {
        print("Error parsing JSON: \(error)")
    }    
    return nil
}


