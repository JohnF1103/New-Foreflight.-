//
//  FIXView.swift
//  New_Foreflight
//
//  Created by John Foster on 4/17/25.
//
import SwiftUI

struct FIXView: View {
    let code: String
    let showLabel: Bool

    private let lightBlue = Color(red: 102/255, green: 217/255, blue: 239/255)

    var body: some View {
        VStack(spacing: showLabel ? 4 : 0) {
            // Curved star with border
            ZStack {
                // Black border behind the sparkle
                Image(systemName: "sparkle")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 17, height: 17) // slightly larger for the border effect
                    .foregroundColor(.black)

                // Blue sparkle on top
                Image(systemName: "sparkle")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 15, height: 15)
                    .foregroundColor(lightBlue)
                    .shadow(color: .black.opacity(0.9), radius: 2, x: 0, y: 2)
            }

            // Label
            if showLabel {
                Text(code)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 2)
                    .padding(.horizontal, 4)
                    .fixedSize()
            }
        }
        .padding(.vertical, showLabel ? 6 : 2)
    }
}

