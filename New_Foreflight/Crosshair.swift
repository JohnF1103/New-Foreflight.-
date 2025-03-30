//
//  Crosshair.swift
//  New_Foreflight
//
//  Created by John Foster on 2/18/25.
//

import SwiftUI

struct CrosshairView: View {
    var body: some View {
        ZStack {
            // Blue circle
            Circle()
                .fill(Color.blue)
                .frame(width: 20, height: 20)
            
            // Horizontal line
            Rectangle()
                .fill(Color.blue)
                .frame(width: 40, height: 2)
            
            // Vertical line
            Rectangle()
                .fill(Color.blue)
                .frame(width: 2, height: 40)
        }
    }
}
