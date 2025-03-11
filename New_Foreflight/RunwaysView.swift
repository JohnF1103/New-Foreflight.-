//
//  RunwaysView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/24/23.
//

import SwiftUI
// TODO: Flesh out the Runway struct
struct Runway : Identifiable{
    var id = UUID()
    var heading1: String
    var heading2: String
    var direction1 : Int
}
struct RunwaysView: View {
    let curr_ap: Airport
    @EnvironmentObject private var vm : AirportDetailModel
    
    var body: some View {
        VStack(spacing:2){
            Titlesection(curr_ap: self.curr_ap, subtitle: "Runways and wind", flightrules: vm.flightrules ?? "Nil").padding(.all)
            Divider()
            let wind: String = "90 at 5-10 kts"
            // TODO: Get this from the METAR instead of having it hardcoded
            let windDirection: Int = 90
            let windSpeed: Int = 5
            let windGust: Int = 10
            
            // TODO: Finish integrating the Runways API
            // NOTE: direction2 = 180 + direction1
            let runway1 = Runway(heading1:"4L",heading2:"22R",direction1:26)
            let runway2 = Runway(heading1:"4R",heading2:"22L",direction1:26)
            let runway3 = Runway(heading1:"11",heading2:"29",direction1:95)
            let data = [runway1,runway2,runway3]
            
        // TODO: Pick out the best runway
            List(data){ runway in
                
                let direction2: Int = 180+runway.direction1
                /*
                    Wind Math
                    angle = runway direction - wind direction
                 
                    Head/Tail = Windspeed * cos(angle)
                    Positive cos = Headwind
                    Negative cos = Tailwind
                 
                    Cross = Windspeed * sin(angle)
                    Positive sin = Right
                    Negative sin = Left
                 */
                let angle_degrees_1: Double = Double(runway.direction1 - windDirection)
                let angle_degrees_2: Double = Double(direction2 - windDirection)
                let angle_radians_1: Double = 1.0/180.0 * Double.pi * angle_degrees_1
                let angle_radians_2: Double = 1.0/180.0 * Double.pi * angle_degrees_2
                
                let headwind_1: Double = Double(windSpeed)*cos(angle_radians_1)
                let crosswind_1: Double = Double(windSpeed)*sin(angle_radians_1)
                let headwind_2: Double = Double(windSpeed)*cos(angle_radians_2)
                let crosswind_2: Double = Double(windSpeed)*sin(angle_radians_2)
                    
                    //Text("Head/Tailwind: \(headwind, specifier: "%.1f")-\(headgust, specifier: "%.1f") kt")
                    //Text("Crosswind: \(crosswind, specifier: "%.1f")-\(crossgust, specifier: "%.1f") kt")
                
                HStack(){
                    Text("\(runway.heading1)-\(runway.heading2)").bold().frame(width:80)
                    Divider()
                    VStack(){
                        Text("Rwy \(runway.heading1)").italic()
                        Text("\(headwind_1) and \(crosswind_1)")
                        Text("Rwy \(runway.heading2)").italic()
                        Text("\(headwind_2) and \(crosswind_2)")
                    }
                    
                }
                
                
                
            }
            
        }
        
    }
}


