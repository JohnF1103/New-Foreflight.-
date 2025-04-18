
//
//  ForeflightDarkMap.swift
//  New_Foreflight
//
//  Created by John Foster on 4/15/25.
//

import SwiftUI
import MapLibre
import CoreLocation

// MARK: – Annotation Models

class AirportAnnotation: MLNPointAnnotation {
    let size: String

    init(code: String, name: String?, coordinate: CLLocationCoordinate2D, size: String) {
        self.size = size
        super.init()
        self.title = code.isEmpty ? "IDENT" : code
        self.subtitle = name
        self.coordinate = coordinate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FixAnnotation: MLNPointAnnotation {
    let code: String

    init(code: String, coordinate: CLLocationCoordinate2D) {
        self.code = code
        super.init()
        self.title = code
        self.coordinate = coordinate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: – Utilities

extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)
        return String(format:"#%06x", rgb)
    }
}

class AirspacePolygon: MLNPolygonFeature {
    var airspaceType: String?
    var color: UIColor = .white
    private var _attributes: [String: Any] = [:]

    override var attributes: [String: Any] {
        get { _attributes }
        set {
            _attributes = newValue
            if let c = newValue["color"] as? UIColor { self.color = c }
            if let t = newValue["airspaceType"] as? String { self.airspaceType = t }
        }
    }
}

// MARK: – ForeflightDarkMap

struct ForeflightDarkMap: UIViewRepresentable {
    @EnvironmentObject private var vm: AirportDetailModel

    private let styleURL = URL(string:
      "https://api.maptiler.com/maps/01963fe9-4c44-7f44-9eca-8cfbde436c1a/style.json?key=vAmQKJhC7QAkBQYnOb7c")!

    // Caches
    private static var airportAnnotationsCache: [AirportAnnotation]?
    private static var fixAnnotationsCache:    [FixAnnotation]?
    private static var overlayCache: [String:[AirspacePolygon]] = [:]

    // Zoom thresholds
    private let overlayZoomThreshold: Double = 3.0
    private let fixLoadZoomThreshold:   Double = 6.0

    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var shouldUpdateRegion: Bool

    func makeUIView(context: Context) -> MLNMapView {
        let mapView = MLNMapView(frame: .zero, styleURL: styleURL)
        mapView.delegate = context.coordinator

        // Initial camera
        let cam = MLNMapCamera(lookingAtCenter: centerCoordinate,
                               altitude: 1, pitch: 0, heading: 0)
        mapView.setCamera(cam, animated: false)
        mapView.compassView.isHidden = true
        mapView.logoView.isHidden    = true
        mapView.gestureRecognizers?.forEach {
            $0.delaysTouchesBegan = false
            $0.delaysTouchesEnded = false
        }

        // Bounds constraint
        let sw = CLLocationCoordinate2D(latitude: 24.396308, longitude: -125.0)
        let ne = CLLocationCoordinate2D(latitude: 49.384358, longitude:  -66.93457)
        context.coordinator.allowedBounds = MLNCoordinateBounds(sw: sw, ne: ne)

        // Load & cache annotations
        if ForeflightDarkMap.airportAnnotationsCache == nil {
            ForeflightDarkMap.airportAnnotationsCache = loadAirportAnnotationsFromFile()
        }
        if ForeflightDarkMap.fixAnnotationsCache == nil {
            ForeflightDarkMap.fixAnnotationsCache    = loadFixAnnotationsFromFile()
        }

        // Add initial airports
        if mapView.zoomLevel > overlayZoomThreshold,
           let airports = ForeflightDarkMap.airportAnnotationsCache {
            let vis = airports.filter { mapView.visibleCoordinateBounds.contains($0.coordinate) }
            mapView.addAnnotations(vis)
        }
        // Add initial fixes
        if mapView.zoomLevel >= fixLoadZoomThreshold,
           let fixes = ForeflightDarkMap.fixAnnotationsCache {
            let visF = fixes.filter { mapView.visibleCoordinateBounds.contains($0.coordinate) }
            mapView.addAnnotations(visF)
        }

        return mapView
    }

    func updateUIView(_ mapView: MLNMapView, context: Context) {
        if shouldUpdateRegion {
            let cam = MLNMapCamera(lookingAtCenter: centerCoordinate,
                                   altitude: 45000, pitch: 0, heading: 0)
            mapView.setCamera(cam, animated: true)
            DispatchQueue.main.async { shouldUpdateRegion = false }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // MARK: – GeoJSON + CSV Loaders

    func parseGeoJSON() async -> [AirspacePolygon] {
        let airspaces = vm.selectedData.compactMap { $0 }
        let key = airspaces.sorted().joined(separator: ",")
        if let cached = ForeflightDarkMap.overlayCache[key] { return cached }

        var overlays = [AirspacePolygon]()
        for space in airspaces {
            let fname = space.lowercased()
            guard let url = Bundle.main.url(forResource: fname, withExtension: "json")
            else { continue }
            do {
                let data = try Data(contentsOf: url)
                guard let shape = try? MLNShape(data: data,
                                     encoding: String.Encoding.utf8.rawValue)
                else { continue }

                let polys: [MLNPolygon] = {
                    if let coll = shape as? MLNShapeCollection {
                        return coll.shapes.compactMap { $0 as? MLNPolygon }
                    } else if let p = shape as? MLNPolygon {
                        return [p]
                    }
                    return []
                }()

                for poly in polys {
                    var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                                          count: Int(poly.pointCount))
                    poly.getCoordinates(&coords, range: NSRange(location: 0, length: Int(poly.pointCount)))
                    let asp = AirspacePolygon(coordinates: coords, count: poly.pointCount)

                    // classify
                    var type = space.trimmingCharacters(in: .whitespaces).lowercased()
                    if let feat = poly as? MLNPolygonFeature,
                       let props = feat.attributes as? [String:Any],
                       let name  = props["NAME"] as? String {
                        let low = name.lowercased()
                        if      low.contains("class b")      { type = "class_b" }
                        else if low.contains("class c")     { type = "class_c" }
                        else if low.contains("class d")     { type = "class_d" }
                        else if low.contains("special")
                             || low.contains("moa")
                             || low.contains("restricted")
                             || low.contains("alert")
                             || low.contains("prohibited") { type = "special" }
                        else { type = "default" }
                    }
                    asp.airspaceType = type
                    asp.color        = getColor(for: type)
                    asp.attributes   = ["color": asp.color, "airspaceType": type]
                    overlays.append(asp)
                }
            } catch {
                print("GeoJSON error: \(error)")
            }
        }
        ForeflightDarkMap.overlayCache[key] = overlays
        return overlays
    }

    func getColor(for type: String) -> UIColor {
        switch type.lowercased() {
        case "class_b": return UIColor(red: 173/255, green: 216/255, blue: 255/255, alpha: 1)
        case "class_c": return UIColor(red: 255/255, green: 105/255, blue: 180/255, alpha: 1)
        case "class_d": return UIColor(red:   0/255, green: 102/255, blue: 204/255, alpha: 1)
        case "special": return UIColor(red: 255/255, green: 140/255, blue:   0/255, alpha: 1)
        default:        return UIColor(red: 230/255, green:  80/255, blue: 150/255, alpha: 1)
        }
    }

    func loadAirportAnnotationsFromFile() -> [AirportAnnotation] {
        guard let url = Bundle.main.url(forResource: "converted_airports4", withExtension: "csv")
        else { return [] }
        do {
            let csv = try String(contentsOf: url)
            let lines = csv.components(separatedBy: .newlines).filter { !$0.isEmpty }
            return lines.compactMap { line in
                let cols = line.split(separator: ",").map(String.init)
                guard cols.count >= 7,
                      let lat = Double(cols[3]),
                      let lon = Double(cols[4]) else { return nil }
                return AirportAnnotation(
                    code: cols[1],
                    name: cols[2],
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    size: cols[6]
                )
            }
        } catch {
            print("Airport CSV error: \(error)")
            return []
        }
    }

    func loadFixAnnotationsFromFile() -> [FixAnnotation] {
        guard let path = Bundle.main.path(forResource: "fixx", ofType: "txt") else { return [] }
        do {
            let txt = try String(contentsOfFile: path)
            let lines = txt.components(separatedBy: .newlines).dropFirst()
            return lines.compactMap { line in
                let parts = line.components(separatedBy: ",")
                guard parts.count >= 3,
                      let lat = Double(parts[1]),
                      let lon = Double(parts[2]) else { return nil }
                let code = parts[0].isEmpty ? "FIX" : parts[0]
                return FixAnnotation(code: code,
                                     coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
        } catch {
            print("Fix TXT error: \(error)")
            return []
        }
    }

    // MARK: – Coordinator


    class Coordinator: NSObject, MLNMapViewDelegate {
        var parent: ForeflightDarkMap
        var allowedBounds: MLNCoordinateBounds?
        private var annotationUpdateWorkItem: DispatchWorkItem?
        var overlayUpdateTask: Task<Void, Never>?
        var isAdjustingCamera = false

        /// At what zoom level airport labels appear
        let labelZoomThreshold: Double = 7.0
        /// At what zoom level FIX IDs appear
        let fixLabelZoomThreshold: Double = 8.0

        init(_ parent: ForeflightDarkMap) {
            self.parent = parent
        }

        func addOverlaySourceAndLayer(to style: MLNStyle, overlays: [AirspacePolygon]) {
            let features: [MLNPolygonFeature] = overlays.map { polygon in
                let feature = MLNPolygonFeature(
                    coordinates: polygon.coordinates,
                    count: polygon.pointCount
                )
                let colorHex = polygon.color.toHexString()
                feature.attributes = [
                    "airspaceType": polygon.airspaceType ?? "default",
                    "color": colorHex
                ]
                return feature
            }

            let source = MLNShapeSource(identifier: "airspace-source",
                                        features: features,
                                        options: nil)
            style.addSource(source)

            // Special fill
            let specialFill = MLNFillStyleLayer(identifier: "special-fill", source: source)
            specialFill.fillColor   = NSExpression(forKeyPath: "color")
            specialFill.fillOpacity = NSExpression(forConstantValue: 0.25)
            specialFill.predicate    = NSPredicate(format: "airspaceType == %@", "special")
            style.addLayer(specialFill)

            // Default fill
            let defaultFill = MLNFillStyleLayer(identifier: "default-fill", source: source)
            defaultFill.fillColor   = NSExpression(forKeyPath: "color")
            defaultFill.fillOpacity = NSExpression(forConstantValue: 0.2)
            defaultFill.predicate    = NSPredicate(format: "airspaceType == %@", "default")
            style.addLayer(defaultFill)

            // Shadow
            let shadow = MLNLineStyleLayer(identifier: "airspace-shadow", source: source)
            shadow.lineColor   = NSExpression(forKeyPath: "color")
            shadow.lineWidth   = NSExpression(forConstantValue: 6)
            shadow.lineOpacity = NSExpression(forConstantValue: 0.2)
            shadow.lineJoin    = NSExpression(forConstantValue: "round")
            shadow.lineCap     = NSExpression(forConstantValue: "round")
            style.addLayer(shadow)

            // Class D outline (dashed)
            let classD = MLNLineStyleLayer(identifier: "classD-outline", source: source)
            classD.lineColor       = NSExpression(forKeyPath: "color")
            classD.lineWidth       = NSExpression(forConstantValue: 2)
            classD.lineDashPattern = NSExpression(forConstantValue: [2, 4])
            classD.lineJoin        = NSExpression(forConstantValue: "round")
            classD.lineCap         = NSExpression(forConstantValue: "round")
            classD.predicate        = NSPredicate(format: "airspaceType == %@", "class_d")
            style.addLayer(classD)

            // Solid outline for others
            let outline = MLNLineStyleLayer(identifier: "airspace-outline", source: source)
            outline.lineColor  = NSExpression(forKeyPath: "color")
            outline.lineWidth  = NSExpression(forConstantValue: 2)
            outline.lineJoin   = NSExpression(forConstantValue: "round")
            outline.lineCap    = NSExpression(forConstantValue: "round")
            outline.predicate   = NSPredicate(format: "airspaceType != %@", "class_d")
            style.addLayer(outline)
        }
        func mapView(_ mapView: MLNMapView, didSelect view: MLNAnnotationView) {
            guard let ann = view.annotation, !(ann is MLNUserLocation) else { return }

            let coordinate = ann.coordinate
            
            // Center the map on the selected annotation without changing the zoom
            mapView.setCenter(coordinate, animated: true)

            if let fix = ann as? FixAnnotation {
                // Selected FIX
                DispatchQueue.main.async {
                    print("SELECTED FIX \(fix.code)")
                    self.parent.vm.DisplayFixDetail = true
                    self.parent.vm.selectedFix = Fix(
                        id: UUID(),
                        Code: fix.code,
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )
                }
            } else {
                // Selected airport
                guard let title = ann.title ?? nil else { return }

                DispatchQueue.main.async {
                    self.parent.vm.DisplayLocationdetail = true
                    self.parent.vm.selected_airport = Airport(
                        id: UUID(),
                        AirportCode: title,
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )
                }
            }
        }






        func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            Task {
                let overlays = await parent.parseGeoJSON()
                await MainActor.run {
                    self.addOverlaySourceAndLayer(to: style, overlays: overlays)

                    // Airports
                    if let airports = ForeflightDarkMap.airportAnnotationsCache {
                        let vis = airports.filter {
                            mapView.visibleCoordinateBounds.contains($0.coordinate)
                        }
                        mapView.addAnnotations(vis)
                    }

                    // FIXes
                    if let fixes = ForeflightDarkMap.fixAnnotationsCache {
                        let visF = fixes.filter {
                            mapView.visibleCoordinateBounds.contains($0.coordinate)
                        }
                        mapView.addAnnotations(visF)
                    }

                    // Immediately sync FIX labels
                    self.updateFixAnnotations(for: mapView, currentZoom: mapView.zoomLevel)
                }
            }
        }

        func mapView(_ mapView: MLNMapView, viewFor annotation: MLNAnnotation) -> MLNAnnotationView? {
            if annotation is MLNUserLocation { return nil }

            // FIX annotations
            if let fix = annotation as? FixAnnotation {
                let id   = FixAnnotationView.reuseIdentifier
                let view = (mapView.dequeueReusableAnnotationView(withIdentifier: id)
                            as? FixAnnotationView)
                           ?? FixAnnotationView(reuseIdentifier: id)

                let showLabel = mapView.zoomLevel >= fixLabelZoomThreshold
                view.update(code: fix.code, showLabel: showLabel)
                return view
            }

            // Airport annotations
            let id = "customAnnotation"
            let annView = mapView.dequeueReusableAnnotationView(withIdentifier: id)
                        ?? CustomAnnotationView(reuseIdentifier: id)
            if let custom = annView as? CustomAnnotationView {
                let rawTitle = annotation.title ?? ""
                let code     = (rawTitle!.isEmpty ? "IDENT" : rawTitle) ?? "NIL"
                custom.updateLabel(with: code)
            }
            return annView
        }

        func mapView(_ mapView: MLNMapView, regionDidChangeAnimated animated: Bool) {
            // Keep within allowed bounds
            if let b = allowedBounds,
               !b.contains(mapView.centerCoordinate),
               !isAdjustingCamera {
                isAdjustingCamera = true
                let cam = MLNMapCamera(lookingAtCenter: b.center,
                                       altitude: mapView.camera.altitude,
                                       pitch: mapView.camera.pitch,
                                       heading: mapView.camera.heading)
                mapView.setCamera(cam, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isAdjustingCamera = false
                }
                return
            }

            let zoom = mapView.zoomLevel

            // Debounce airport annotation updates
            annotationUpdateWorkItem?.cancel()
            let airportUpdate = DispatchWorkItem { [weak self, weak mapView] in
                guard let self = self, let mv = mapView else { return }
                self.updateAirportAnnotations(for: mv, currentZoom: zoom)
            }
            annotationUpdateWorkItem = airportUpdate
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                if !airportUpdate.isCancelled {
                    airportUpdate.perform()
                }
            }

            // Smoothly adjust airspace outline width
            overlayUpdateTask?.cancel()
            overlayUpdateTask = Task { [weak self, weak mapView] in
                guard let self = self,
                      let mv = mapView,
                      let style = mv.style,
                      let lineLayer = style.layer(withIdentifier: "airspace-outline")
                                         as? MLNLineStyleLayer else { return }

                let newWidth: CGFloat
                switch zoom {
                case ..<6:    newWidth = 1.0
                case 6..<10:  newWidth = 2.0
                case 10..<13: newWidth = 3.0
                default:      newWidth = 3.5
                }

                await MainActor.run {
                    lineLayer.lineWidth = NSExpression(forConstantValue: newWidth)
                }
            }

            // Update FIX annotations (including labels)
            updateFixAnnotations(for: mapView, currentZoom: zoom)

            // Toggle airport labels
            let showAirLabels = zoom > labelZoomThreshold
            for ann in mapView.annotations ?? [] {
                if let v = mapView.view(for: ann) as? CustomAnnotationView {
                    v.setLabelVisible(showAirLabels)
                }
            }
        }

        private func updateAirportAnnotations(for mapView: MLNMapView, currentZoom: Double) {
            guard let airports = ForeflightDarkMap.airportAnnotationsCache else { return }

            // Hide all if zoom too low
            if currentZoom <= 5.5 {
                let toRemove = mapView.annotations?
                    .filter { !($0 is MLNUserLocation) } ?? []
                mapView.removeAnnotations(toRemove)
                return
            }

            // Determine allowed sizes
            let allowedSizes: Set<String>
            switch currentZoom {
            case ..<6:    allowedSizes = []
            case 6..<7:  allowedSizes = ["large_airport"]
            case 7..<9:  allowedSizes = ["large_airport", "medium_airport"]
            default:     allowedSizes = ["large_airport", "medium_airport", "small_airport"]
            }

            let bounds = mapView.visibleCoordinateBounds
            let visible = airports.filter {
                bounds.contains($0.coordinate) && allowedSizes.contains($0.size)
            }

            let existing = mapView.annotations?
                .compactMap { $0 as? AirportAnnotation } ?? []

            let toAdd = visible.filter { va in
                !existing.contains { ca in
                    abs(ca.coordinate.latitude  - va.coordinate.latitude)  < 0.0001 &&
                    abs(ca.coordinate.longitude - va.coordinate.longitude) < 0.0001
                }
            }
            let toRemove = existing.filter { ca in
                !visible.contains { va in
                    abs(va.coordinate.latitude  - ca.coordinate.latitude)  < 0.0001 &&
                    abs(va.coordinate.longitude - ca.coordinate.longitude) < 0.0001
                }
            }

            if !toRemove.isEmpty { mapView.removeAnnotations(toRemove) }
            if !toAdd.isEmpty    { mapView.addAnnotations(toAdd) }
        }

        private func updateFixAnnotations(for mapView: MLNMapView, currentZoom: Double) {
            guard let fixes = ForeflightDarkMap.fixAnnotationsCache else { return }

            // Remove all if below load threshold
            if currentZoom < parent.fixLoadZoomThreshold {
                let rem = mapView.annotations?
                    .compactMap { $0 as? FixAnnotation } ?? []
                mapView.removeAnnotations(rem)
                return
            }

            // Figure which FIXes should be visible
            let visible  = fixes.filter {
                mapView.visibleCoordinateBounds.contains($0.coordinate)
            }
            let existing = mapView.annotations?
                .compactMap { $0 as? FixAnnotation } ?? []

            let toAdd = visible.filter { fix in
                !existing.contains {
                    abs($0.coordinate.latitude  - fix.coordinate.latitude)  < 0.0001 &&
                    abs($0.coordinate.longitude - fix.coordinate.longitude) < 0.0001
                }
            }
            let toRemove = existing.filter { ex in
                !visible.contains { vis in
                    abs(vis.coordinate.latitude  - ex.coordinate.latitude)  < 0.0001 &&
                    abs(vis.coordinate.longitude - ex.coordinate.longitude) < 0.0001
                }
            }

            if !toRemove.isEmpty { mapView.removeAnnotations(toRemove) }
            if !toAdd.isEmpty    { mapView.addAnnotations(toAdd) }

            // Show or hide FIX IDs based on the new threshold
            let showLabel = currentZoom >= fixLabelZoomThreshold
            for case let fix as FixAnnotation in mapView.annotations ?? [] {
                if let v = mapView.view(for: fix) as? FixAnnotationView {
                    // update(...) will recreate the SwiftUI view with the correct showLabel
                    v.update(code: fix.code, showLabel: showLabel)
                }
            }
        }
    }

}

// MARK: – CoordinateBounds Extension

extension MLNCoordinateBounds {
    var center: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: (ne.latitude + sw.latitude) / 2.0,
            longitude: (ne.longitude + sw.longitude) / 2.0
        )
    }
    func contains(_ c: CLLocationCoordinate2D) -> Bool {
        c.latitude  >= sw.latitude  && c.latitude  <= ne.latitude &&
        c.longitude >= sw.longitude && c.longitude <= ne.longitude
    }
}

// MARK: – Annotation Views

class FixAnnotationView: MLNAnnotationView, Identifiable, ObservableObject {
    
    var isFix = true

    static let reuseIdentifier = "fixAnnotation"
    private var hosting: UIHostingController<FIXView>

    override init(reuseIdentifier: String?) {
        hosting = UIHostingController(rootView: FIXView(code: "", showLabel: false))
        super.init(reuseIdentifier: reuseIdentifier)
        hosting.view.backgroundColor = .clear
        addSubview(hosting.view)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        hosting.view.frame = bounds
    }

    override var annotation: MLNAnnotation? {
        didSet {
            guard let fix = annotation as? FixAnnotation else { return }
            update(code: fix.code, showLabel: !hosting.view.isHidden)
        }
    }

    func update(code: String, showLabel: Bool) {
        hosting.rootView = FIXView(code: code, showLabel: showLabel)
        let size = hosting.sizeThatFits(in: CGSize(width: 100, height: 100))
        frame.size = size
        hosting.view.frame = bounds
    }

    func setLabelVisible(_ v: Bool) {
        hosting.view.isHidden = false
        hosting.rootView = FIXView(code: (annotation as? FixAnnotation)?.code ?? "", showLabel: v)
    }
}

class CustomAnnotationView: MLNAnnotationView {
    static var crosshairImage: UIImage? = {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        let center = CGPoint(x: size.width/2, y: size.height/2)
        let blue = UIColor.systemBlue.cgColor
        let black = UIColor.black.cgColor
        // Outer arms
        ctx.setStrokeColor(black); ctx.setLineWidth(3.5 + 1.5*2)
        ctx.setLineCap(.square)
        ctx.move(to: CGPoint(x: center.x-9-1, y: center.y))
        ctx.addLine(to: CGPoint(x: center.x-9, y: center.y))
        ctx.move(to: CGPoint(x: center.x+9, y: center.y))
        ctx.addLine(to: CGPoint(x: center.x+9+1, y: center.y))
        ctx.move(to: CGPoint(x: center.x, y: center.y-9-1))
        ctx.addLine(to: CGPoint(x: center.x, y: center.y-9))
        ctx.move(to: CGPoint(x: center.x, y: center.y+9))
        ctx.addLine(to: CGPoint(x: center.x, y: center.y+9+1))
        ctx.strokePath()
        // Blue circle
        ctx.setFillColor(blue); ctx.fillEllipse(in: CGRect(x: center.x-9, y: center.y-9, width:18, height:18))
        ctx.setStrokeColor(black); ctx.setLineWidth(1); ctx.strokeEllipse(in: CGRect(x: center.x-9, y: center.y-9, width:18, height:18))
        // Transparent inner
        ctx.setBlendMode(.clear); ctx.fillEllipse(in: CGRect(x: center.x-4, y: center.y-4, width:8, height:8))
        ctx.setBlendMode(.normal); ctx.setStrokeColor(black); ctx.setLineWidth(1.5)
        ctx.strokeEllipse(in: CGRect(x: center.x-4, y: center.y-4, width:8, height:8))
        // Inner blue arms
        ctx.setStrokeColor(blue); ctx.setLineWidth(3.5)
        ctx.move(to: CGPoint(x: center.x-9-1, y: center.y))
        ctx.addLine(to: CGPoint(x: center.x-9, y: center.y))
        ctx.move(to: CGPoint(x: center.x+9, y: center.y))
        ctx.addLine(to: CGPoint(x: center.x+9+1, y: center.y))
        ctx.move(to: CGPoint(x: center.x, y: center.y-9-1))
        ctx.addLine(to: CGPoint(x: center.x, y: center.y-9))
        ctx.move(to: CGPoint(x: center.x, y: center.y+9))
        ctx.addLine(to: CGPoint(x: center.x, y: center.y+9+1))
        ctx.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }()

    private let imageView = UIImageView()
    private let codeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .center
        l.layer.cornerRadius = 4
        l.clipsToBounds = true
        l.layer.shadowColor = UIColor.black.cgColor
        l.layer.shadowOpacity = 0.4
        l.layer.shadowOffset = CGSize(width:0, height:1)
        l.layer.shadowRadius = 2
        l.layer.masksToBounds = false
        return l
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        frame = CGRect(x:0, y:0, width:40, height:55)
        imageView.image = CustomAnnotationView.crosshairImage
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        addSubview(codeLabel)
        codeLabel.isHidden = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x:0, y:0, width:40, height:40)
        codeLabel.frame = CGRect(x:0, y:40, width:40, height:15)
    }

    override var annotation: MLNAnnotation? {
        didSet {
            guard !(annotation is MLNUserLocation) else { return }
            let rawTitle = annotation?.title ?? ""
            let code = rawTitle!.isEmpty ? "IDENT" : rawTitle
            updateLabel(with: code ?? "NIL")
        }
    }

    func updateLabel(with code: String) {
        codeLabel.text = code
        codeLabel.sizeToFit()
        let w = max(codeLabel.frame.width + 8, 40)
        codeLabel.frame.size.width = w
        codeLabel.center.x = bounds.width/2
    }

    func setLabelVisible(_ v: Bool) {
        codeLabel.isHidden = !v
    }

    override var intrinsicContentSize: CGSize { CGSize(width:40, height:55) }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let s: CGFloat = selected ? 1.2 : 1.0
        if animated {
            UIView.animate(withDuration:0.1) {
                self.transform = CGAffineTransform(scaleX: s, y: s)
            }
        } else {
            transform = CGAffineTransform(scaleX: s, y: s)
        }
    }
}
