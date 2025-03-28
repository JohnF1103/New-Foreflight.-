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
    var length : Int
}
struct RunwaysView: View {
    let curr_ap: Airport
    let windDirection: Int
    let windSpeed: Int
    @EnvironmentObject private var vm : AirportDetailModel
    
    var body: some View {
        VStack(spacing:2){
            Titlesection(curr_ap: self.curr_ap, subtitle: "Runways and wind", flightrules: "VFR",symbol:"road.lanes").padding(.all)
            
            Divider()
            // let wind: String = "300° at 24 kts"
            // TODO: Get this from the METAR instead of having it hardcoded
            let windDirection: Int = self.windDirection
            let windSpeed: Int = self.windSpeed
            
            
            // TODO: Finish integrating the Runways API
            // NOTE: direction2 = 180 + direction1
            let runway1 = Runway(heading1:"4L",heading2:"22R",direction1:26,length:11000)
            let runway2 = Runway(heading1:"4R",heading2:"22L",direction1:26,length:10000)
            let runway3 = Runway(heading1:"11",heading2:"29",direction1:95,length:6726)
            let data : [Runway] = [runway1,runway2,runway3]
            let result : String = BestRunway(data: data, direction: windDirection)
            //Text("\(data.count) Best Runway: \(result)")
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
                
                let string_1a : String = (headwind_1>0) ? "⬇️ \(String(format:"%.1f",headwind_1))":"⬆️ \(String(format:"%.1f",headwind_2))"
                let string_1b : String = (crosswind_1>0) ? "➡️ \(String(format:"%.1f",crosswind_1))":"⬅️ \(String(format:"%.1f",crosswind_2))"
                let string_2a : String = (headwind_2>0) ? "⬇️ \(String(format:"%.1f",headwind_2))":"⬆️ \(String(format:"%.1f",headwind_1))"
                let string_2b : String = (crosswind_2>0) ? "➡️ \(String(format:"%.1f",crosswind_2))":"⬅️ \(String(format:"%.1f",crosswind_1))"
                
                let style_1a = (headwind_1>0) ? Color(red:0.4,green:0.8,blue:0.4) : Color(red:0,green:0,blue:0)
                let style_2a = (headwind_2>0) ? Color(red:0.4,green:0.8,blue:0.4) : Color(red:0,green:0,blue:0)
                
                let full_heading_1 = (runway.heading1 == result) ? "\(runway.heading1) [Best]" : "\(runway.heading1)"
                let full_heading_2 = (runway.heading2 == result) ? "\(runway.heading2) [Best]" : "\(runway.heading2)"
                
                HStack(){
                    VStack(){
                        Text("\(runway.heading1)-\(runway.heading2)").bold().frame(width:80)
                        Text("\(runway.length)'")
                    }
                    Divider()
                    VStack(){
                        Text("Rwy \(full_heading_1)").italic()
                        HStack(){
                            Text("\(string_1a) kts").foregroundStyle(style_1a)
                            Text("\(string_1b) kts").foregroundStyle(.red)
                        }
                        
                        Text("Rwy \(full_heading_2)").italic()
                        HStack(){
                            Text("\(string_2a) kts").foregroundStyle(style_2a)
                            Text("\(string_2b) kts").foregroundStyle(.red)
                        }
                    }
                    
                }
                
                
                
            }
            
            
        }.padding(.all)
        
    }
}
extension RunwaysView{
    func BestRunway(data: [Runway],direction: Int) -> String{
        // More Math:
        // Most Headwind = Smallest difference between runway angle and wind vector angle
        var result : String = "n/a"
        var min_diff : Int = 180
        for runway in data{
            //print("Text: \(runway.heading1)-\(runway.heading2)")
            let diff_1 = abs(direction-runway.direction1) < 180 ? abs(direction-runway.direction1) : abs(abs(direction-runway.direction1)-360)
            //print("diff_1: \(diff_1)")
            if(diff_1<min_diff ){
                result = runway.heading1
                min_diff = diff_1
            }
            let direction2 : Int = 180 + runway.direction1
            let diff_2 = abs(direction-direction2) < 180 ? abs(direction-direction2) : abs(abs(direction-direction2)-360)
           // print("diff_2: \(diff_2)")
            if(diff_2<min_diff){
                result = runway.heading2
                min_diff = diff_2
            }
        }
        return result
    }
}

