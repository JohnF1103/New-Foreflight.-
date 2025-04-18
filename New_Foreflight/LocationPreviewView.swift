import SwiftUI
import MapKit
import Combine
// MARK: - Models



// (Your existing models below...)
struct ServerResponse: Decodable {
    var metar_data: String? = nil
    var flight_rules: String? = nil
    var metar_components: MetarComponents
}
struct MetarComponents: Decodable {
    var wind: String
    var clouds: [Cloud]
    var visibility: String
    var temperature: String
    var dewpoint: String
    var barometer: String
    var humidity: String
    var elevation: String
    var density_altitude: Double = 0
}
struct Cloud: Decodable {
    var code: String
    var feet: String? = nil
}

// MARK: - LocationPreviewView (unchanged)

struct LocationPreviewView: View {
    let airport: Airport
    @EnvironmentObject private var vm: AirportDetailModel
    @State private var isShowingFlightPlanSheet = false  // controls sheet presentation
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                imageSection
                titlesection
            }
            
            VStack(spacing: 8) {
                AirportINFOButton
                Weatherbutton  // Tapping this triggers the flight planning sheet.
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .offset(y: 65)
        )
        .cornerRadius(10)
        .sheet(isPresented: $isShowingFlightPlanSheet) {
            // Pass the selected airport as the destination.
            FlightPlanSheetView()
                .environmentObject(ActiveNavlogsViewModel.shared)
        }
    }
}

extension LocationPreviewView {
    private var imageSection: some View {
        ZStack {
            Image(systemName: "airplane.departure")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .cornerRadius(10)
        }
        .padding(6)
        .cornerRadius(10)
    }
    
    private var titlesection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(airport.AirportCode)
                .font(.title2)
                .fontWeight(.bold)
            Text("Airport")
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var AirportINFOButton: some View {
        Button {
            Task {
                do {
                    let urlString = "https://wx-svc-x86-272565453292.us-central1.run.app/api/v1/getAirportWeather?airportCode=\(airport.AirportCode)"

                    guard let url = URL(string: urlString) else {
                        errorMessage = "Invalid URL for airport: \(airport.AirportCode)"
                        showErrorAlert = true
                        return
                    }

                    let (data, _) = try await URLSession.shared.data(from: url)
                    guard let jsonString = String(data: data, encoding: .utf8),
                          let jsonData = jsonString.data(using: .utf8) else {
                        errorMessage = "Failed to decode server response"
                        showErrorAlert = true
                        return
                    }

                    let metarData = try JSONDecoder().decode(ServerResponse.self, from: jsonData)
                    vm.curr_metar = metarData.metar_data
                    vm.sheetlocation = airport
                    vm.flightrules = metarData.flight_rules

                    let cloudCode = metarData.metar_components.clouds.first?.code ?? "n/a"
                    let cloudFeet = metarData.metar_components.clouds.first?.feet.map { "\($0)" } ?? ""
                    let cloudAGL = (cloudCode == "CLR") ? "CLR" : "\(cloudCode) at \(cloudFeet)ft"
                    let now = Date.now

                    let interestingNumbers: KeyValuePairs<String, String> = [
                        "Time": now.formatted(date: .omitted, time: .standard),
                        "Wind": metarData.metar_components.wind ?? "n/a",
                        "Visibility": metarData.metar_components.visibility ?? "n/a",
                        "Clouds(AGL)": cloudAGL,
                        "Temperature": metarData.metar_components.temperature ?? "n/a",
                        "Dewpoint": metarData.metar_components.dewpoint ?? "n/a",
                        "Altimeter": metarData.metar_components.barometer ?? "n/a",
                        "Humidity": metarData.metar_components.humidity ?? "n/a",
                        "Density altitude": String(format: "%.2f", metarData.metar_components.density_altitude ?? 0.0)
                    ]

                    vm.parsed_metar = interestingNumbers

                } catch {
                    errorMessage = "Failed to load METAR: \(error.localizedDescription)"
                    showErrorAlert = true
                }
            }
        } label: {
            Text("Airport Info")
                .font(.headline)
                .frame(width: 125, height: 35)
        }
        .buttonStyle(.borderedProminent)
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }


    }
    
    private var Weatherbutton: some View {
        Button {
            isShowingFlightPlanSheet = true
        } label: {
            Text("Plan flight")
                .font(.headline)
                .frame(width: 125, height: 35)
        }
        .buttonStyle(.bordered)
    }
}

// MARK: - CustomMapView (unchanged)

struct CustomMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var routeCoordinates: [CLLocationCoordinate2D]
    // Closure to notify when a new drag point is added.
    var onDragPointAdded: ((CLLocationCoordinate2D) -> Void)?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        // Add a pan gesture recognizer for handling drags on the route.
        let panGesture = UIPanGestureRecognizer(target: context.coordinator,
                                                action: #selector(Coordinator.handlePan(_:)))
        panGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(panGesture)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        // Remove existing overlays and annotations (if needed) to update view cleanly.
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        // Re-add annotations for each route coordinate inserted (except start/end if desired).
        for coord in routeCoordinates.dropFirst().dropLast() {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coord
            uiView.addAnnotation(annotation)
        }
        if routeCoordinates.count >= 2 {
            let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
            uiView.addOverlay(polyline)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: CustomMapView
        // Holds the index of the inserted point during a drag.
        var draggingIndex: Int? = nil
        // New: work item to throttle overlay updates.
        var overlayUpdateWorkItem: DispatchWorkItem?
        // New properties for hold-to-drag:
        var gestureStartTime: Date? = nil
        var draggingActivated: Bool = false
        // The required hold duration in seconds before dragging starts.
        let holdDuration: TimeInterval = 0.3

        init(_ parent: CustomMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemPink
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        // Allow our gesture to recognize simultaneously with built-in gestures.
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

            switch gesture.state {
            case .began:
                // Record the start time but don't insert yet.
                gestureStartTime = Date()
                draggingActivated = false
            case .changed:
                // Check if the hold duration has passed.
                if !draggingActivated, let startTime = gestureStartTime,
                   Date().timeIntervalSince(startTime) >= holdDuration {
                    // Now try to activate dragging.
                    if let (segmentIndex, distance) = nearestSegment(to: location, in: mapView) {
                        // If there are FAA fixes (i.e. more than just departure and destination)
                        // allow insertion only in the last segment.
                        if parent.routeCoordinates.count > 2 && segmentIndex != parent.routeCoordinates.count - 2 {
                            return
                        }
                        if distance < 20 {
                            let newIndex = segmentIndex + 1
                            parent.routeCoordinates.insert(coordinate, at: newIndex)
                            draggingIndex = newIndex

                            let annotation = MKPointAnnotation()
                            annotation.coordinate = coordinate
                            mapView.addAnnotation(annotation)
                           
                            parent.onDragPointAdded?(coordinate)
                            draggingActivated = true
                        }
                    }
                } else if draggingActivated, let index = draggingIndex {
                    // Update the dragged point's coordinate.
                    parent.routeCoordinates[index] = coordinate
                    // Throttle overlay updates.
                    overlayUpdateWorkItem?.cancel()
                    let workItem = DispatchWorkItem {
                        mapView.removeOverlays(mapView.overlays)
                        if self.parent.routeCoordinates.count >= 2 {
                            let polyline = MKPolyline(coordinates: self.parent.routeCoordinates, count: self.parent.routeCoordinates.count)
                            mapView.addOverlay(polyline)
                        }
                    }
                    overlayUpdateWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: workItem)
                }
            case .ended, .cancelled:
                draggingIndex = nil
                gestureStartTime = nil
                draggingActivated = false
                overlayUpdateWorkItem?.cancel()
                mapView.removeOverlays(mapView.overlays)
                if parent.routeCoordinates.count >= 2 {
                    let polyline = MKPolyline(coordinates: parent.routeCoordinates, count: parent.routeCoordinates.count)
                    mapView.addOverlay(polyline)
                }
            default:
                break
            }
        }

        // Finds the nearest segment (pair of consecutive points) to the touch.
        func nearestSegment(to point: CGPoint, in mapView: MKMapView) -> (Int, CGFloat)? {
            guard parent.routeCoordinates.count >= 2 else { return nil }
            var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
            var bestSegment: Int?
            for i in 0..<(parent.routeCoordinates.count - 1) {
                let pt1 = mapView.convert(parent.routeCoordinates[i], toPointTo: mapView)
                let pt2 = mapView.convert(parent.routeCoordinates[i + 1], toPointTo: mapView)
                let distance = distanceFrom(point, toLineSegment: pt1, pt2)
                if distance < minDistance {
                    minDistance = distance
                    bestSegment = i
                }
            }
            if let best = bestSegment {
                return (best, minDistance)
            }
            return nil
        }

        // Calculates the perpendicular distance from a point to a line segment.
        func distanceFrom(_ point: CGPoint, toLineSegment pt1: CGPoint, _ pt2: CGPoint) -> CGFloat {
            let a = point.x - pt1.x
            let b = point.y - pt1.y
            let c = pt2.x - pt1.x
            let d = pt2.y - pt1.y
            let dot = a * c + b * d
            let lenSq = c * c + d * d
            var param: CGFloat = -1
            if lenSq != 0 {
                param = dot / lenSq
            }
            var xx: CGFloat, yy: CGFloat
            if param < 0 {
                xx = pt1.x
                yy = pt1.y
            } else if param > 1 {
                xx = pt2.x
                yy = pt2.y
            } else {
                xx = pt1.x + param * c
                yy = pt1.y + param * d
            }
            let dx = point.x - xx
            let dy = point.y - yy
            return sqrt(dx * dx + dy * dy)
        }
    }
}

// MARK: - FlightPlanSheetView (Modified)




struct FlightPlanSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var activeNavlogsVM: ActiveNavlogsViewModel

    // Remove the fixed destinationAirport parameter so both endpoints are editable.
    @State private var departure: String = ""
    @State private var destination: String = ""
    @State private var cruisingAltitude: String = ""
    @State private var aircraftType: String = ""
    // The route description now holds intermediate waypoints (fix codes)
    @State private var routeDescription: String = ""
    @State private var TAS: String = ""

    // Coordinates for departure and destination.
    @State private var departureCoordinate: CLLocationCoordinate2D? = nil
    @State private var destinationCoordinate: CLLocationCoordinate2D? = nil
    // The full route: departure, intermediate fixes, destination.
    @State private var routeCoordinates: [CLLocationCoordinate2D] = []
    @State private var customWaypoints: [CLLocationCoordinate2D] = []

    
    // Map region state.
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.0, longitude: -98.0),
        span: MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 10.0)
    )
    
    let aircraftOptions = [
        "PA-28-151",
        "C172",
        "C182",
        "Boeing 737",
        "Airbus A320",
        "Beechcraft G36 Bonanza",
        "Cessna 162"
    ]
    
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    
    // Combine publisher for debouncing route description updates.
    @State private var routeDescriptionPublisher = PassthroughSubject<String, Never>()
    @State private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize with a default region (centered on continental US).
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.0, longitude: -98.0),
            span: MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 10.0)
        ))
    }
    
    // MARK: - Helper Methods
    
    /// Returns a map region that fits the two coordinates.
    private func regionForCoordinates(coord1: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D) -> MKCoordinateRegion {
        let latCenter = (coord1.latitude + coord2.latitude) / 2.0
        let lonCenter = (coord1.longitude + coord2.longitude) / 2.0
        let latDelta = abs(coord1.latitude - coord2.latitude) * 1.5
        let lonDelta = abs(coord1.longitude - coord2.longitude) * 1.5
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latCenter, longitude: lonCenter),
            span: MKCoordinateSpan(latitudeDelta: max(latDelta, 0.05), longitudeDelta: max(lonDelta, 0.05))
        )
    }
    
    /// Updates routeCoordinates by scanning the departure, destination, and route description.
    /// – If the first token in the route description is a valid airport code, it will override departure.
    /// – If the last token is a valid airport code, it will override destination.
    private func updateRouteCoordinatesFromDescription() {
        let tokens = routeDescription
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .map { String($0) }

        var newRoute: [CLLocationCoordinate2D] = []
        var updatedCustomWaypoints: [CLLocationCoordinate2D] = []

        if let first = tokens.first, first.count == 4, let depAirport = lookupAirport(code: first) {
            departure = depAirport.AirportCode
            departureCoordinate = CLLocationCoordinate2D(latitude: depAirport.latitude, longitude: depAirport.longitude)
        }

        if let last = tokens.last, last.count == 4, let destAirport = lookupAirport(code: last) {
            destination = destAirport.AirportCode
            destinationCoordinate = CLLocationCoordinate2D(latitude: destAirport.latitude, longitude: destAirport.longitude)
        }

        guard let dep = departureCoordinate, let dest = destinationCoordinate else { return }

        newRoute.append(dep)

        for token in tokens.dropFirst().dropLast() {
            if let fix = lookupFIXX(code: token) {
                newRoute.append(fix)
            } else if let coord = parseCoordinate(token) {
                // Find the index of the coordinate in original route description
                let latLonString = String(format: "%.6f,%.6f", coord.latitude, coord.longitude)

                // Check if this coordinate matches a token exactly in the routeDescription
                if let tokenIndex = tokens.firstIndex(of: latLonString),
                   tokenIndex < routeCoordinates.count {
                    let existingCoord = routeCoordinates[tokenIndex]
                    newRoute.append(existingCoord)
                    updatedCustomWaypoints.append(existingCoord)
                } else if let matched = customWaypoints.first(where: {
                    abs($0.latitude - coord.latitude) < 0.0001 &&
                    abs($0.longitude - coord.longitude) < 0.0001
                }) {
                    newRoute.append(matched)
                    updatedCustomWaypoints.append(matched)
                } else {
                    newRoute.append(coord)
                    updatedCustomWaypoints.append(coord)
                }
            }
        }

        newRoute.append(dest)

        routeCoordinates = newRoute
        customWaypoints = updatedCustomWaypoints
        region = regionForCoordinates(coord1: dep, coord2: dest)
    }


    /// Updates the route using the current departure and destination text fields.
    
    // MARK: - Modern Card Modifier
    
    private func modernCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemBackground)))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
            .padding(.horizontal)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Fixed Map Preview Card at the top.
                modernCard {
                    VStack(alignment: .leading, spacing: 4) {
                        CustomMapView(
                            region: $region,
                            routeCoordinates: $routeCoordinates,
                            onDragPointAdded: { newPoint in
                                
                                
                                let pointString = String(format: "%.6f,%.6f", newPoint.latitude, newPoint.longitude)
                                var tokens = routeDescription
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                                    .split(separator: " ")
                                    .map { String($0) }

                                // If we have at least 2 tokens (departure + destination), insert before destination
                                if tokens.count >= 2 {
                                    tokens.insert(pointString, at: tokens.count - 1)
                                } else {
                                    // Otherwise, just append
                                    tokens.append(pointString)
                                }

                                // Update routeDescription and publish
                                routeDescription = tokens.joined(separator: " ")
                                routeDescriptionPublisher.send(routeDescription)
                            }
                        )

                        .frame(height: 180)
                        .cornerRadius(8)
                        .overlay(
                            Text("Route Preview")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(5),
                            alignment: .topLeading
                        )
                    }
                }
                .padding(.vertical, 10)
                
                // Scrollable Form with editable fields.
                ScrollView {
                    VStack(spacing: 10) {
                        // Flight Details Card.
                        modernCard {
                            VStack(spacing: 8) {
                                // Departure & Destination Row.
                                
                                
                                // Intermediate Fixes via Route Description.
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Route Description (Intermediate Fixes)")
                                        .font(.headline)
                                    TextEditor(text: $routeDescription)
                                        .frame(height: 40)
                                        .padding(8)
                                        .background(RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1))
                                        // Instead of immediate onChange, send the value to a publisher.
                                        .onChange(of: routeDescription) { newValue in
                                            routeDescriptionPublisher.send(newValue)
                                        }
                                        // Debounce updates for 300 milliseconds.
                                        .onReceive(routeDescriptionPublisher.debounce(for: .milliseconds(300), scheduler: RunLoop.main)) { _ in
                                            updateRouteCoordinatesFromDescription()
                                        }
                                }
                                
                                // FAA Fix & Cruising Altitude Row.
                                HStack {
                                   
                                    Spacer()
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Cruising Altitude")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        TextField("Altitude", text: $cruisingAltitude)
                                            .padding(8)
                                            .frame(maxWidth: .infinity, minHeight: 45)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color(.secondarySystemBackground))
                                            )
                                            .keyboardType(.numberPad)
                                    }
                                }
                                
                                // Aircraft Type & TAS Row.
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Aircraft Type")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Picker("Aircraft Type", selection: $aircraftType) {
                                            ForEach(aircraftOptions, id: \.self) { option in
                                                Text(option).tag(option)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .padding(8)
                                        .frame(maxWidth: .infinity, minHeight: 45)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(.secondarySystemBackground))
                                        )
                                    }
                                    Spacer()
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("TAS")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        TextField("TAS", text: $TAS)
                                            .padding(8)
                                            .frame(maxWidth: .infinity, minHeight: 45)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color(.secondarySystemBackground))
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Submit Button Card.
                        modernCard {
                            Button(action: {
                                // Validate required fields.
                                if departure.trimmingCharacters(in: .whitespaces).isEmpty ||
                                    destination.trimmingCharacters(in: .whitespaces).isEmpty ||
                                    cruisingAltitude.trimmingCharacters(in: .whitespaces).isEmpty ||
                                    aircraftType.trimmingCharacters(in: .whitespaces).isEmpty ||
                                    TAS.trimmingCharacters(in: .whitespaces).isEmpty {
                                    validationMessage = "Please fill in all required fields."
                                    showValidationAlert = true
                                    return
                                }
                                
                                let baseURL = "https://nav-service-272565453292.us-central1.run.app/api/v1/ComputeNavlog"

                                // Add parentheses around coordinates in the routeDescription
                                let fixedRoute = routeDescription
                                    .split(separator: " ")
                                    .map { part -> String in
                                        let trimmed = part.trimmingCharacters(in: .whitespaces)
                                        let isCoordinate = trimmed.range(of: #"^-?\d+(\.\d+)?,-?\d+(\.\d+)?$"#, options: .regularExpression) != nil
                                        return isCoordinate ? "(\(trimmed))" : trimmed
                                    }
                                    .joined(separator: " ")

                                let routeQuery = fixedRoute.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                let aircraftQuery = aircraftType.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                let cruiseALTQuery = "\(cruisingAltitude)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                let tasQuery = "\(TAS)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

                                let fullURLString = "\(baseURL)?route=\(routeQuery)&aircraft=\(aircraftQuery)&CruiseALT=\(cruiseALTQuery)&TAS=\(tasQuery)"

                                print("Calling URL: \(fullURLString)")

                                
                                fetchNavLog(from: fullURLString) { navLogData in
                                    guard let navLogData = navLogData else {
                                        print("Failed to parse navlog data.")
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        activeNavlogsVM.activeNavlogs.append(navLogData)
                                        print("New NavLog Created: \(navLogData.title)")
                                        dismiss()
                                    }
                                }
                                dismiss()
                            }) {
                                Text("Submit Flight Plan")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea(.keyboard))
            .navigationTitle("Plan Your Flight")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            .alert(isPresented: $showValidationAlert) {
                Alert(title: Text("Missing Information"),
                      message: Text(validationMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
        .onDisappear {
            cancellables.forEach { $0.cancel() }
        }
    }
}







// MARK: - Helper functions

func lookupFIXX(code: String) -> CLLocationCoordinate2D? {
    let normalizedCode = code.uppercased()
    guard !normalizedCode.isEmpty else { return nil }
    
    guard let fileUrl = Bundle.main.url(forResource: "fixx", withExtension: "txt"),
          let content = try? String(contentsOf: fileUrl) else {
        print("Unable to load FIXX.txt")
        return nil
    }
    
    let fields = content.components(separatedBy: ":")
    // Process the file in steps of three: [FixCode, Latitude, Longitude]
    for i in stride(from: 0, to: fields.count, by: 3) {
        let fixCode = fields[i].trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if fixCode == normalizedCode,
           let lat = Double(fields[i+1].trimmingCharacters(in: .whitespacesAndNewlines)),
           let lon = Double(fields[i+2].trimmingCharacters(in: .whitespacesAndNewlines)) {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }
    
    print("No fix found for code: \(normalizedCode)")
    return nil
}

private func parseCoordinate(_ token: String) -> CLLocationCoordinate2D? {
    let components = token.split(separator: ",")
    if components.count == 2,
       let lat = Double(components[0]),
       let lon = Double(components[1]) {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    return nil
}


func lookupAirport(code: String) -> Airport? {
    let normalizedCode = code.uppercased()
    guard normalizedCode.count == 4 else { return nil }
    
    guard let fileUrl = Bundle.main.url(forResource: "formatted_airports", withExtension: "txt"),
          let content = try? String(contentsOf: fileUrl) else {
        print("Unable to load Airports.txt")
        return nil
    }

    let fields = content.components(separatedBy: ":")
    
    // The file alternates between [Code, Latitude, Longitude], so process it in steps of 3.
    for i in stride(from: 0, to: fields.count, by: 3) {
        let fileCode = fields[i].trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if fileCode == normalizedCode,
           let lat = Double(fields[i + 1].trimmingCharacters(in: .whitespacesAndNewlines)),
           let lon = Double(fields[i + 2].trimmingCharacters(in: .whitespacesAndNewlines)) {
            return Airport(id: UUID(), AirportCode: fileCode, latitude: lat, longitude: lon)
        }
    }

    print("No airport found for code: \(normalizedCode)")
    return nil
}


// MARK: - Networking & Parsing Helpers

func fetchNavLog(from urlString: String, completion: @escaping (NavLogData?) -> Void) {
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        completion(nil)
        return
    }
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
            print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }
        let navLog = parseNavLogResponse(responseString)
        completion(navLog)
    }.resume()
}

func parseNavLogResponse(_ response: String) -> NavLogData? {
    // Expected response format:
    // "Distance 173.7-Total ETE: 86:12-Total Fuel Burn: 18.84gallons-[27:02, 61:20, 86:12]-[8.982535799199017, 14.697548229504424, 18.843472213792523]-[Node: KPOU, Bearing: 165.0, Distance: 33.31369041097834, Node: (41.1164,-73.5935), Bearing: 200.0, Distance: 29.816762769418574, Node: KJFK, Bearing: 354.0, Distance: 0.0]"
    
    let parts = response.components(separatedBy: "^")
    guard parts.count >= 6 else {
        print("Unexpected response format; expected at least 6 parts but got \(parts.count)")
        return nil
    }
    
    // 1. Parse total distance.
    let distanceStr = parts[0].replacingOccurrences(of: "Distance ", with: "").trimmingCharacters(in: .whitespaces)
    guard let totalDistance = Double(distanceStr) else {
        print("Invalid total distance")
        return nil
    }
    
    // 2. Parse total ETE.
    let totalETE = parts[1].replacingOccurrences(of: "Total ETE: ", with: "").trimmingCharacters(in: .whitespaces)
    
    // 3. Parse total fuel burn.
    let fuelBurnPart = parts[2].replacingOccurrences(of: "Total Fuel Burn: ", with: "").trimmingCharacters(in: .whitespaces)
    guard let gallonsRange = fuelBurnPart.range(of: "gallons") else {
        print("Invalid fuel burn format")
        return nil
    }
    let totalFuelBurnStr = fuelBurnPart[..<gallonsRange.lowerBound].trimmingCharacters(in: .whitespaces)
    guard let totalFuelBurn = Double(totalFuelBurnStr) else {
        print("Invalid fuel burn value")
        return nil
    }
    
    // 4. Parse waypoint ETES.
    let eteArrayString = parts[3].trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
    let waypointETEs = eteArrayString
        .split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespaces) }
    
    // 5. Parse fuel burns.
    let fuelBurnsArrayString = parts[4].trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
    let fuelBurns = fuelBurnsArrayString
        .split(separator: ",")
        .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
    
    // 6. Parse the flight route from the last part.
    let routePart = parts[5].trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
    
    print("ROUTE PART " + routePart)
    let flightSegments = parseRoute(from: routePart)
    
    if flightSegments.isEmpty {
        print("No flight segments were parsed from the route string.")
        return nil
    }
    
    // Form the title from the first and last segment.
    
    print("FINAL PARSED =  \(flightSegments)")
    let title = "\(flightSegments.first!.node) \(flightSegments.last!.node)"
    
    return NavLogData(
        title: title,
        totalDistance: totalDistance,
        totalETE: totalETE,
        totalFuelBurn: totalFuelBurn,
        waypointETEs: waypointETEs,
        fuelBurns: fuelBurns,
        flightSegments: flightSegments
    )
}

/// This helper takes a route string (without the surrounding brackets) and returns an array of FlightSegment.
/// For example, given:
/// "Node: KPOU, Bearing: 165.0, Distance: 33.31369041097834, Node: (41.1164,-73.5935), Bearing: 200.0, Distance: 29.816762769418574, Node: KJFK, Bearing: 354.0, Distance: 0.0"
/// it will return three FlightSegment objects.
func parseRoute(from routeString: String) -> [FlightSegment] {
    var segments: [FlightSegment] = []
    
    let pattern = #"Node: (.*?), Bearing: ([\d.]+), Distance: ([\d.]+)"#
    
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
        print("Invalid regex")
        return []
    }

    let nsString = routeString as NSString
    let matches = regex.matches(in: routeString, options: [], range: NSRange(location: 0, length: nsString.length))

    for match in matches {
        guard match.numberOfRanges == 4 else { continue }

        let node = nsString.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespaces)
        let bearingString = nsString.substring(with: match.range(at: 2)).trimmingCharacters(in: .whitespaces)
        let distanceString = nsString.substring(with: match.range(at: 3)).trimmingCharacters(in: .whitespaces)

        if let bearing = Double(bearingString), let distance = Double(distanceString) {
            segments.append(FlightSegment(node: node, bearing: bearing, distance: distance))
        }
    }

    return segments
}







// MARK: - Main ContentView


