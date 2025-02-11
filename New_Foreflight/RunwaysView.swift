//
//  RunwaysView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/24/23.
//

import SwiftUI
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
            TabView(){
                // TODO: get vm.parsed_metar from the integration branch
                // this is an example wind vector
                let wind_speed: Int = 9
                let wind_direction: Int = 240
                let runway_example = Runway(heading:"4L-22R",direction:40)
                var head_tail: Double = wind_speed*sin(Double(wind_direction-runway_example.direction))
                var cross: Double =
                print(head_tail)
                print(cross)
            }
        }
        
    }
}


