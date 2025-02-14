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
    var heading : String
    var direction : Int
}
struct RunwaysView: View {
    let curr_ap: Airport
    @EnvironmentObject private var vm : AirportDetailModel
    
    var body: some View {
        VStack(spacing:2){
            Titlesection(curr_ap: self.curr_ap, subtitle: "Runways and wind", flightrules: vm.flightrules ?? "Nil").padding(.all)
            Divider()
            /*
             Head/Tailwind: wind speed * sin(a)
             Crosswind: wind speed * cos(a)
             */
            let wind: String = "310 at 11-25 kts"
            // TODO: Get this from the METAR instead of having it hardcoded
            let windDirection: Int = 310
            let windSpeed: Int = 11
            let windGust: Int = 25
            
            // TODO: Finish integrating the Runways API
            // NOTE: Most runway headings are
            let runway1 = Runway(heading:"4L-22R",direction:26)
            let runway2 = Runway(heading:"4R-22L",direction:26)
            let runway3 = Runway(heading:"11-29",direction:95)
            let data = [runway1,runway2,runway3]
            
        // TODO: Pick out the best runway
            List(data){ runway in
                let headwind: Double = abs(Double(windSpeed)*sin(1.0/180.0 * Double.pi * Double(runway.direction - windDirection)))
                let headgust: Double = abs(Double(windGust)*sin(1.0/180.0 * Double.pi * Double(runway.direction - windDirection)))
                let crosswind: Double = abs(Double(windSpeed)*cos(1.0/180.0 * Double.pi * Double(runway.direction - windDirection)))
                let crossgust: Double = abs(Double(windGust)*cos(1.0/180.0 * Double.pi * Double(runway.direction - windDirection)))
                VStack(){
                    
                    Text(runway.heading).bold()
                    Text("Head/Tailwind: \(headwind, specifier: "%.1f")-\(headgust, specifier: "%.1f") kt")
                    Text("Crosswind: \(crosswind, specifier: "%.1f")-\(crossgust, specifier: "%.1f") kt")
                }
                
                
                
                
            }
            
        }
        
    }
}


