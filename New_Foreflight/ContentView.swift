
//
//  ContentView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/15/23.
//
import SwiftUI
import Foundation
import MapKit

struct RainOverlay: View {
    var body: some View {
        // Customize this view to display rain data (e.g., raindrops, layers, etc.)
        Circle()
            .foregroundColor(.blue)
            .opacity(0.5)
            .frame(width: 20, height: 20)
    }
}

struct ContentView: View {
    var body: some View {
        Map {
            // Add your map annotations or other map features here if needed
        }
        .mapStyle(.hybrid(elevation: .realistic))
        .overlay(
            RainOverlay()
                // Adjust the overlay position as needed
                .offset(x: 50, y: -50)
        )
    }
}

