//
//  LocationPreviewView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/20/23.
//

import SwiftUI
import MapKit

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

struct LocationPreviewView: View {
    
    let airport: Airport
    @EnvironmentObject private var vm: AirportDetailModel
    @State private var isShowingFlightPlanSheet = false  // controls sheet presentation
    
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
            FlightPlanSheetView(destinationAirport: airport)
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
            var curr_metar_of_selected_Airport = ""
                       // Changes view (and fetches weather data)
                       let semaphore = DispatchSemaphore(value: 0)
                    
                       let urlString = "https://wx-svc-x86-272565453292.us-central1.run.app/api/v1/getAirportWeather?airportCode=\(airport.AirportCode)"
                       var request = URLRequest(url: URL(string: urlString)!, timeoutInterval: Double.infinity)
                       request.httpMethod = "GET"
                       
                       let task = URLSession.shared.dataTask(with: request) { data, response, error in
                           guard let data = data else {
                               print(String(describing: error))
                               semaphore.signal()
                               return
                           }
                           curr_metar_of_selected_Airport = String(data: data, encoding: .utf8)!
                           print(curr_metar_of_selected_Airport)
                           semaphore.signal()
                       }
                       task.resume()
                       semaphore.wait()
                       let jsonData = curr_metar_of_selected_Airport.data(using: .utf8)!
                       let metarData: ServerResponse = try! JSONDecoder().decode(ServerResponse.self, from: jsonData)
                       vm.curr_metar = metarData.metar_data
                       print(metarData.metar_components)
                       vm.sheetlocation = airport
                       let cloudCode = String(metarData.metar_components.clouds.first?.code ?? "n/a")
                       let cloudFeet = String(metarData.metar_components.clouds.first?.feet ?? "")
                       let cloudAGL = (cloudCode == "CLR") ? "CLR" : "\(cloudCode) at \(cloudFeet)ft"
                       let now = Date.now
                       let interestingNumbers: KeyValuePairs<String,String> = [
                           "Time": now.formatted(date: .omitted, time: .standard),
                           "Wind": metarData.metar_components.wind,
                           "Visibility": metarData.metar_components.visibility,
                           "Clouds(AGL)": cloudAGL,
                           "Temperature": metarData.metar_components.temperature,
                           "Dewpoint": metarData.metar_components.dewpoint,
                           "Altimeter": metarData.metar_components.barometer,
                           "Humidity": metarData.metar_components.humidity,
                           "Density altitude": String(format: "%.2f", metarData.metar_components.density_altitude)
                       ]
                       vm.flightrules = metarData.flight_rules
                       vm.parsed_metar = interestingNumbers        } label: {
            Text("Airport Info")
                .font(.headline)
                .frame(width: 125, height: 35)
        }
        .buttonStyle(.borderedProminent)
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


//
// CustomMapView: A UIViewRepresentable wrapper for MKMapView that draws a pink polyline
// from the departure coordinate to the destination coordinate.
//
// MARK: - CustomMapView with Draggable Route
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
                   // Check if touch is near any segment of the route.
                   if let (segmentIndex, distance) = nearestSegment(to: location, in: mapView) {
                        // If within threshold, insert a new coordinate.
                        if distance < 20 {
                             let newIndex = segmentIndex + 1
                             parent.routeCoordinates.insert(coordinate, at: newIndex)
                             draggingIndex = newIndex
                             
                             // Add an annotation at the new point.
                             let annotation = MKPointAnnotation()
                             annotation.coordinate = coordinate
                             mapView.addAnnotation(annotation)
                             
                             // Notify that a new drag point was added.
                             parent.onDragPointAdded?(coordinate)
                        }
                   }
              case .changed:
                   if let index = draggingIndex {
                        // Update the coordinate for the dragged point.
                        parent.routeCoordinates[index] = coordinate
                        mapView.removeOverlays(mapView.overlays)
                        if parent.routeCoordinates.count >= 2 {
                             let polyline = MKPolyline(coordinates: parent.routeCoordinates, count: parent.routeCoordinates.count)
                             mapView.addOverlay(polyline)
                        }
                   }
              case .ended, .cancelled:
                   draggingIndex = nil
              default:
                   break
              }
         }

         // Finds the nearest segment (pair of consecutive points) to the touch.
         // Returns the segment's starting index and the distance from the touch point.
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
struct FlightPlanSheetView: View {
    @Environment(\.dismiss) var dismiss
    let destinationAirport: Airport

    @State private var departure: String = ""
    @State private var cruisingAltitude: String = ""
    @State private var aircraftType: String = ""
    @State private var routeDescription: String = "" // Holds the formatted route details.
    @State private var region: MKCoordinateRegion
    @State private var departureCoordinate: CLLocationCoordinate2D? = nil
    // Route coordinates array: will contain departure, any inserted points, and destination.
    @State private var routeCoordinates: [CLLocationCoordinate2D] = []

    init(destinationAirport: Airport) {
        self.destinationAirport = destinationAirport
        // Center the map on the destination airport.
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: destinationAirport.latitude,
                                           longitude: destinationAirport.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    // Helper to calculate a region that fits both coordinates with padding.
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
    
    // Updates the route description using the format:
    // DEPARTURE_CODE  (lat,lon)  (lat,lon)  ARRIVAL_CODE
    private func updateRouteDescription() {
        // Validate departure airport.
        guard let depAirport = lookupAirport(code: departure.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            routeDescription = ""
            return
        }
        var description = "\(depAirport.AirportCode)"
        
        // Intermediate points: all inserted points (if any) are between departure and destination.
        let intermediatePoints = routeCoordinates.dropFirst().dropLast()
        for point in intermediatePoints {
            let lat = String(format: "%.4f", point.latitude)
            let lon = String(format: "%.4f", point.longitude)
            description += " (\(lat),\(lon))"
        }
        description += " \(destinationAirport.AirportCode)"
        routeDescription = description
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Plan Your Flight")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                
                CustomMapView(
                    region: $region,
                    routeCoordinates: $routeCoordinates,
                    onDragPointAdded: { newPoint in
                        // After a new point is added via drag, update the route description.
                        updateRouteDescription()
                    }
                )
                .frame(height: 200)
                .cornerRadius(10)
                .overlay(
                    Text("Route Preview")
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(5),
                    alignment: .topLeading
                )
                .padding(.horizontal, 20)
                
                // Rectangular box for route description.
                VStack(alignment: .leading) {
                    Text("Route Description")
                        .font(.headline)
                        .padding(.horizontal, 4)
                    TextEditor(text: $routeDescription)
                        .frame(height: 100)
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                        .disabled(true)
                }
                .padding(.horizontal, 20)
                
                VStack(spacing: 15) {
                    TextField("Departure (4-letter code)", text: $departure)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .onChange(of: departure) { newValue in
                            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                            // Only update if the trimmed input is exactly 4 letters.
                            if trimmed.count == 4 {
                                if let depAirport = lookupAirport(code: trimmed) {
                                    print("Found departure airport: \(depAirport.AirportCode) at \(depAirport.latitude), \(depAirport.longitude)")
                                    departureCoordinate = CLLocationCoordinate2D(latitude: depAirport.latitude,
                                                                                 longitude: depAirport.longitude)
                                    let destCoordinate = CLLocationCoordinate2D(latitude: destinationAirport.latitude,
                                                                                longitude: destinationAirport.longitude)
                                    region = regionForCoordinates(coord1: departureCoordinate!, coord2: destCoordinate)
                                    // Initialize the route with departure and destination.
                                    routeCoordinates = [departureCoordinate!, destCoordinate]
                                    updateRouteDescription()
                                } else {
                                    print("No airport found for code: \(trimmed)")
                                    departureCoordinate = nil
                                    region = MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: destinationAirport.latitude,
                                                                       longitude: destinationAirport.longitude),
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    )
                                    routeCoordinates = []
                                    routeDescription = ""
                                }
                            } else {
                                departureCoordinate = nil
                                region = MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: destinationAirport.latitude,
                                                                   longitude: destinationAirport.longitude),
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                )
                                routeCoordinates = []
                                routeDescription = ""
                            }
                        }
                    
                    // Destination is read-only.
                    TextField("Destination", text: .constant(destinationAirport.AirportCode))
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .disabled(true)
                    
                    TextField("Cruising Altitude", text: $cruisingAltitude)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .keyboardType(.numberPad)
                    
                    TextField("Aircraft Type", text: $aircraftType)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button(action: {
                    // Handle submission as needed.
                    print("Sending to backend")
                    print("Route Object: \(routeDescription)")
                    dismiss()
                }) {
                    Text("Submit")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.red)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

/// Generic lookup function that reads from Airports.txt in your app bundle.
/// Assumes each nonempty line is formatted as: CODE,latitude,longitude,...
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
