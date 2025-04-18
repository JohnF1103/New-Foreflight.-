import SwiftUI
import WebKit

struct PlatesView: View {
    let plateJSON: String
    let curr_ap: Airport
    @EnvironmentObject private var vm: AirportDetailModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGroupedBackground))

            Divider()

            if let chartDictionary = parseAirportCharts(apiOutputString: plateJSON, airport: curr_ap) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ForEach(chartDictionary.sorted(by: { $0.key < $1.key }), id: \.key) { key, values in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .foregroundColor(.accentColor)
                                    Text(key.uppercased())
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal)

                                ForEach(values, id: \.0) { chartName, urlString in
                                    PlateCardView(chartName: chartName, urlString: urlString)
                                        .transition(.opacity.combined(with: .scale))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                .frame(maxHeight: .infinity)
            } else {
                errorView
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemGray6), Color(.systemBackground)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

extension PlatesView {
    private var headerSection: some View {
        Titlesection(
            curr_ap: curr_ap,
            subtitle: "PLATES",
            flightrules: vm.flightrules!
        )
        .font(.headline)
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
    }

    private var errorView: some View {
        Text("⚠️ API Error — No plates available.")
            .font(.body)
            .foregroundColor(.red)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal)
    }
}

// MARK: - Plate Card
struct PlateCardView: View {
    let chartName: String
    let urlString: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "link")
                    .foregroundColor(.gray)
                Text(chartName)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.gray)
                    .underline()
            }

            WebViewRow(urlString: urlString, chartname: chartName)
                .frame(height: 1) // Invisible preview placeholder
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground).opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

