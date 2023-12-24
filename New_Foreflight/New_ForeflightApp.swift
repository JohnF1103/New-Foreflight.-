//
//  New_ForeflightApp.swift
//  New_Foreflight
//
//  Created by John Foster on 12/15/23.
//

import SwiftUI

@main
struct New_ForeflightApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AirportDetailModel())
        }
    }
}
