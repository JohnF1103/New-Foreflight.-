import SwiftUI
import MapKit

// Data model for each flight segment.
struct FlightSegment: Identifiable {
    let id = UUID()
    let node: String
    let bearing: Double
    let distance: Double
}

// Data model for the navlog.
struct NavLogData: Identifiable {
    var id = UUID()
    let title: String
    let totalDistance: Double      // in nautical miles
    let totalETE: String           // in format "MM:SS"
    let totalFuelBurn: Double      // in gallons
    let waypointETEs: [String]     // array of ETE times for each waypoint
    let fuelBurns: [Double]        // fuel burn at each waypoint (cumulative)
    let flightSegments: [FlightSegment]
}

// Row view that can be used elsewhere if needed.
struct NavlogRow: View {
    let navLog: NavLogData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("ETE: \(navLog.title)")
                .font(.headline)
            Text("Distance: \(String(format: "%.2f", navLog.totalDistance)) NM")
                .font(.subheadline)
        }
        .padding(4)
    }
}

// Main view to display the navlog.
struct NavLogView: View {
    let navLog: NavLogData
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                flightSegmentsAndWaypointsSection
            }
            .padding()
        }
        // Replace the plain black background with a dark gradient background.
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 0.12, green: 0.12, blue: 0.12, opacity: 1.0),
                    Color(.sRGB, red: 0.05, green: 0.05, blue: 0.05, opacity: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
        .navigationTitle("NavLog")
    }
    
    // Header with overall flight information using a refined dark gradient.
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(navLog.title)
                .font(.title)
                .fontWeight(.bold)
            Text("Total Distance: \(String(format: "%.2f", navLog.totalDistance)) NM")
                .font(.headline)
            Text("Total ETE: \(navLog.totalETE)")
                .font(.headline)
            Text("Total Fuel Burn: \(String(format: "%.2f", navLog.totalFuelBurn)) gallons")
                .font(.headline)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.sRGB, red: 0.18, green: 0.18, blue: 0.25, opacity: 1.0),
                    Color(.sRGB, red: 0.05, green: 0.05, blue: 0.1, opacity: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
        .foregroundColor(.white)
    }
    
    // Combined flight segments and waypoint information section.
    private var flightSegmentsAndWaypointsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Flight Segments & Waypoints")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            
            // Using indices to combine flight segment and waypoint info.
            ForEach(Array(navLog.flightSegments.enumerated()), id: \.element.node) { index, segment in
                VStack(alignment: .leading, spacing: 8) {
                    // Flight Segment Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Node: \(segment.node)")
                            .fontWeight(.semibold)
                        Text("Bearing: \(String(format: "%.2f", segment.bearing))°")
                            .font(.subheadline)
                        Text("Distance: \(String(format: "%.2f", segment.distance)) NM")
                            .font(.subheadline)
                    }
                    
                    // Waypoint info (if available)
                    if index < navLog.waypointETEs.count && index < navLog.fuelBurns.count {
                        Divider()
                            .background(Color.white.opacity(0.5))
                        HStack {
                            Text("Waypoint \(index + 1) (\(navLog.flightSegments[index+1].node)) :")
                                .fontWeight(.semibold)
                                .lineLimit(1)                    // Ensures it stays in one line
                                .minimumScaleFactor(0.75)        // Shrinks the text if necessary
                            Spacer()
                            HStack(spacing: 12) {
                                Text("ETE: \(navLog.waypointETEs[index])")
                                Text("Fuel: \(String(format: "%.2f", navLog.fuelBurns[index])) gal")
                            }
                        }
                        .font(.subheadline)
                    }
                }
                .padding()
                // Use a card style with a dark, slightly translucent background and subtle shadow.
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.sRGB, red: 0.15, green: 0.15, blue: 0.18, opacity: 0.95))
                )
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
                .foregroundColor(.white)
            }
        }
    }
}

// View model to hold active navlogs.
final class ActiveNavlogsViewModel: ObservableObject {
    static let shared = ActiveNavlogsViewModel()
    @Published var activeNavlogs: [NavLogData] = []
}

