//
//  FixDetailView.swift
//  New_Foreflight
//
//  Created by John Foster on 4/17/25.
//

import SwiftUI
import SwiftUI

struct FixDetailView: View {
    @EnvironmentObject private var vm: AirportDetailModel
    let fix: Fix?

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "scope")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text(fix?.Code ?? "FIX")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Fix Coordinates")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()
            }

            // Coordinates
            VStack(spacing: 10) {
                coordinateRow(title: "Latitude", value: fix?.latitude)
                coordinateRow(title: "Longitude", value: fix?.longitude)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 6)
        )
        .padding()
        .frame(maxHeight: .infinity) // This is key to vertical centering
        .background(Color.clear)
    }

    private func coordinateRow(title: String, value: Double?) -> some View {
        HStack {
            Image(systemName: title == "Latitude" ? "location.north.line" : "location.east.line")
                .foregroundColor(.blue)
            Text("\(title):")
                .foregroundColor(.secondary)
            Spacer()
            Text(String(format: "%.5f", value ?? 0.0))
                .font(.system(.body, design: .monospaced))
        }
    }
}
