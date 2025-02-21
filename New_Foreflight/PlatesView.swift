import SwiftUI
import WebKit

struct PlatesView: View {
    let plateJSON: String
    let curr_ap: Airport
    @EnvironmentObject private var vm: AirportDetailModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Title Section
                Titlesection(curr_ap: curr_ap, subtitle: "PLATES", flightrules: vm.flightrules!)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .padding(.horizontal)

                // Plates Section
                if let chartDictionary = parseAirportCharts(apiOutputString: plateJSON, airport: curr_ap) {
                    ForEach(chartDictionary.sorted(by: { $0.key < $1.key }), id: \.key) { key, values in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(key):")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(values, id: \.0) { chartName, urlString in
                                WebViewRow(urlString: urlString, chartname: chartName)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    )
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                } else {
                    Text("API ERROR, NIL METAR")
                        .foregroundColor(.red)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
    }
}

