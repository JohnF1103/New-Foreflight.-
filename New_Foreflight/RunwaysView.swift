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
}
struct RunwaysView: View {
    let curr_ap: Airport
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        List{
            Text("04L-22R")
            Text("04R-22L")
            Text("11-29")
        }
    }
}

#Preview {
    /*RunwaysView(curr_ap: Airport(
        id: UUID(),AirportCode: "KEWR", latitude: 40.69222222222222, longitdue: -74.16861111111112) )*/
}
