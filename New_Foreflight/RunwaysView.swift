//
//  RunwaysView.swift
//  New_Foreflight
//
//  Created by Micheal Lyga on 2/24/25.
//


import SwiftUI

struct RunwayEnd: Identifiable {
    let id = UUID()
    let ident: String
    let direction: Int    // degrees, e.g. 270 for "27"
}

struct RunwaysView: View {
    let curr_ap: Airport
    @EnvironmentObject private var vm: AirportDetailModel

    private var windData: (direction: Int, speed: Int) {
        guard
            let pairs = vm.parsed_metar,
            let windString = pairs.first(where: { $0.0 == "Wind" })?.value
        else { return (0, 0) }

        let comps = windString.split(separator: " ")
        guard comps.count >= 4, let dir = Int(comps[0]) else { return (0, 0) }

        let speedPart = String(comps[2])
        if speedPart.contains("-") {
            let bounds = speedPart.split(separator: "-")
            let maxSpeed = bounds.compactMap { Int($0) }.max() ?? 0
            return (dir, maxSpeed)
        } else {
            return (dir, Int(speedPart) ?? 0)
        }
    }

    private var runwayEnds: [RunwayEnd] {
        vm.runwayNumbers.map { ident in
            let digits = ident.prefix { $0.isNumber }
            let num = Int(digits) ?? 0
            return RunwayEnd(ident: ident, direction: num * 10)
        }
    }

    private func computeWindComponents(bearing: Int,
                                       windDir: Int,
                                       windSpd: Int)
        -> (head: Double, cross: Double)
    {
        let rad = Double(bearing - windDir) * .pi / 180
        let head = Double(windSpd) * cos(rad)
        let cross = Double(windSpd) * sin(rad)
        return (head, cross)
    }

    var body: some View {
        let (windDir, windSpd) = windData

        let bestRunwayIdent: String? = runwayEnds
            .map { end -> (RunwayEnd, Double) in
                let head = computeWindComponents(
                    bearing: end.direction,
                    windDir: windDir,
                    windSpd: windSpd
                ).head
                return (end, head)
            }
            .max { $0.1 < $1.1 }?
            .0.ident

        VStack(spacing: 0) {
            Titlesection(
                curr_ap: curr_ap,
                subtitle: "Runways & Wind",
                flightrules: vm.flightrules ?? "—",
                symbol: "road.lanes"
            )
            .padding(.bottom, 4)

            Divider()

            Text("Wind: \(windDir)° @ \(windSpd) kt")
                .font(.subheadline)
                .padding(.vertical, 8)

            List(runwayEnds) { end in
                let oppDir   = (end.direction + 180) % 360
                let oppIdent = String(format: "%02d", oppDir / 10)

                let comps1 = computeWindComponents(
                    bearing: end.direction,
                    windDir: windDir,
                    windSpd: windSpd
                )
                let comps2 = computeWindComponents(
                    bearing: oppDir,
                    windDir: windDir,
                    windSpd: windSpd
                )

                let label1 = end.ident + (end.ident == bestRunwayIdent ? " [Best]" : "")
                let label2 = oppIdent + (oppIdent == bestRunwayIdent ? " [Best]" : "")

                VStack(alignment: .leading, spacing: 6) {
                    Text("Rwy \(label1) ∕ \(label2)")
                        .bold()
                    Text("\(end.direction)° ∕ \(oppDir)°")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    HStack(alignment: .top) {
                        // —— Primary end ——
                        VStack(spacing: 4) {
                            Text(end.ident)
                                .font(.caption)
                                .bold()

                            HStack(spacing: 4) {
                                Image(systemName: comps1.head >= 0 ? "arrow.down" : "arrow.up")
                                    .foregroundColor(comps1.head >= 0 ? .green : .red)
                                Text("\(abs(comps1.head), specifier: "%.0f") kt")
                                    .font(.caption2)
                            }
                            HStack(spacing: 4) {
                                Image(systemName: comps1.cross >= 0 ? "arrow.right" : "arrow.left")
                                    .foregroundColor(.gray)
                                Text("\(abs(comps1.cross), specifier: "%.0f") kt")
                                    .font(.caption2)
                            }
                        }

                        Spacer()

                        // —— Opposite end ——
                        VStack(spacing: 4) {
                            Text(oppIdent)
                                .font(.caption)
                                .bold()

                            HStack(spacing: 4) {
                                Image(systemName: comps2.head >= 0 ? "arrow.down" : "arrow.up")
                                    .foregroundColor(comps2.head >= 0 ? .green : .red)
                                Text("\(abs(comps2.head), specifier: "%.0f") kt")
                                    .font(.caption2)
                            }
                            HStack(spacing: 4) {
                                Image(systemName: comps2.cross >= 0 ? "arrow.right" : "arrow.left")
                                    .foregroundColor(.gray)
                                Text("\(abs(comps2.cross), specifier: "%.0f") kt")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .listStyle(PlainListStyle())
        }
        .padding(.horizontal)
    }
}
