//
//  SwiftUIView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/31/23.
//

import SwiftUI

struct AnnotationView: View {
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.teal)
            Text("✈️")
                .padding(5)
        }
    }
}


