//
//  WebView.swift
//  New_Foreflight
//
//  Created by John Foster on 12/28/23.
//

import Foundation
import WebKit
import SwiftUI

struct WebView: UIViewRepresentable {
    // 1
    let url: URL

    
    // 2
    func makeUIView(context: Context) -> WKWebView {

        return WKWebView()
    }
    
    // 3
    func updateUIView(_ webView: WKWebView, context: Context) {

        let request = URLRequest(url: url)
        webView.load(request)
    }
}
