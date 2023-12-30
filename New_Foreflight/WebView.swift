//
//  WebView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/28/23.
//

import Foundation
import WebKit
import SwiftUI

struct WebViewRow: View {
    let urlString: String
    let chartname: String
    @State private var isPresented = false

    var body: some View {
        Button(action: {
            isPresented.toggle()
        }) {
            Text(chartname)
        }
        .sheet(isPresented: $isPresented) {
            
            NavigationStack{
                WebView(urlString: urlString)
                    .ignoresSafeArea()
                    .navigationTitle(chartname)
                    .navigationBarTitleDisplayMode(.inline)
                
            }
           
        }
    }
}



struct WebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }
    }
}
