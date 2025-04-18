import SwiftUI

struct FrequenciesView: View {
    
    let FreqenciesJSON: String
    let curr_ap: Airport
    @EnvironmentObject private var vm: AirportDetailModel
    let parsedFrequencies: [String: String]?
    
    @State private var active = ("Unicom", 122.8)
    @State private var SBY = ("", 122.8)
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header Section
            headerSection
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGroupedBackground))
            
            Divider()
            
            // Frequencies List Section
            if let frequenciesDict = parsedFrequencies, !frequenciesDict.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(frequenciesDict.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            Button {
                                if let freq = Double(value) {
                                    self.active = (key, freq)
                                }
                            } label: {
                                HStack {
                                    Text(key)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(value)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                    .padding()
                }
            } else {
                Text("📭 No frequencies to show.")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .background(Color(UIColor.systemBackground))
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Header Section & Frequency Changer

extension FrequenciesView {
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Titlesection(
                curr_ap: curr_ap,
                subtitle: "Nearby frequencies",
                flightrules: vm.flightrules!
            )
            .font(.headline)
            
            frequencySwitcher
        }
    }
    
    private var frequencySwitcher: some View {
        HStack(spacing: 16) {
            frequencyCard(title: "Active", frequency: self.active)
            frequencyCard(title: "Standby", frequency: self.SBY)
            
            Button {
                let temp = self.active
                self.active = self.SBY
                self.SBY = temp
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.title2)
                    .padding(12)
                    .background(Circle().fill(Color.gray.opacity(0.2)))
            }
        }
    }
    
    private func frequencyCard(title: String, frequency: (String, Double)) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(frequency.0) \(frequency.1, specifier: "%.1f")")
                .font(.subheadline)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(RoundedRectangle(cornerRadius: 10).fill(title == "Active" ? Color.blue : Color.green))
                .foregroundColor(.white)
        }
    }
}

