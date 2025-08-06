//
//  WebView.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        // Set initial loading state
        DispatchQueue.main.async {
            context.coordinator.parent.isLoading = true
        }
        
        // Load the URL immediately when creating the view
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Only reload if the URL has changed and it's different from current URL
        if webView.url != url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        private var loadingTimer: Timer?
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        deinit {
            loadingTimer?.invalidate()
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
            
            // Set a timeout to prevent infinite loading
            loadingTimer?.invalidate()
            loadingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { _ in
                DispatchQueue.main.async {
                    self.parent.isLoading = false
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            loadingTimer?.invalidate()
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            loadingTimer?.invalidate()
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            loadingTimer?.invalidate()
            // Don't treat cancellation as an error (happens when user navigates away quickly)
            let nsError = error as NSError
            if nsError.code != NSURLErrorCancelled {
                print("WebView failed to load: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
    }
}

#Preview {
    WebView(url: URL(string: "https://www.apple.com")!, isLoading: .constant(false))
}