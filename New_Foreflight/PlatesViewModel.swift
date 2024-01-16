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
func parseAirportCharts(apiOutputString: String, airport: Airport) -> [String: [(String, String)]]? {
    var dpCharts: [(String, String, String)] = []
    var chartDataDictionary: [String: [(String, String)]] = [:]

    do {
        if let jsonData = apiOutputString.data(using: .utf8) {
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: [[String: Any]]] {
                if let firstKey = jsonObject.keys.first, let chartArray = jsonObject[firstKey] {
                    var chartArrayData: [[String: String]] = []

                    for chartEntry in chartArray {
                        if let chartType = chartEntry["chart_code"] as? String, let chartName = chartEntry["chart_name"] as? String, let pdfPath = chartEntry["pdf_path"] as? String {
                            let chartData = (chartName, pdfPath, chartEntry["download_link"] as? String ?? "")
                            chartArrayData.append(["chart_code": chartType, "chart_name": chartName, "pdf_path": pdfPath, "download_link": chartData.2])
                            if chartType == "DP" || chartType == "IAP" || chartType == "STAR" {
                                dpCharts.append(chartData)
                            }
                        }
                    }

                    let SID_STAR_and_IAP_charts = chartArrayData.filter { $0["chart_code"] == "DP" || $0["chart_code"] == "IAP" || $0["chart_code"] == "STAR" }

                    SID_STAR_and_IAP_charts.forEach {
                        if let chartName = $0["chart_name"], let pdfPath = $0["pdf_path"], let chartType = $0["chart_code"] {

                            // Modify the dictionary structure
                            if var existingCharts = chartDataDictionary[chartType] {
                                existingCharts.append((chartName, pdfPath))
                                chartDataDictionary[chartType] = existingCharts
                            } else {
                                chartDataDictionary[chartType] = [(chartName, pdfPath)]
                            }
                        }
                    }
                }
            }
        }
    } catch {
        print("Error parsing JSON: \(error)")
    }

    return chartDataDictionary.isEmpty ? nil : chartDataDictionary
}
