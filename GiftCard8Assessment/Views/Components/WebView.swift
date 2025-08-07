//
//  WebView.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI
import WebKit

/// A SwiftUI wrapper for WKWebView that provides web content display with loading state management.
///
/// This component integrates WKWebView into SwiftUI with proper loading state tracking,
/// navigation support, and error handling. It's designed specifically for displaying
/// news articles and other web content within the app's interface.
///
/// ## Key Features
/// - SwiftUI integration through UIViewRepresentable
/// - Loading state tracking with binding support
/// - Back/forward navigation gesture support
/// - Automatic timeout handling to prevent infinite loading
/// - Proper error handling for network and loading failures
/// - Memory management with coordinator pattern
/// - Thread-safe state updates
///
/// ## Loading Management
/// - Tracks loading state through published binding
/// - Implements 30-second timeout for failed loads
/// - Handles cancellation gracefully (user navigation)
/// - Provides visual feedback through parent view
///
/// ## Usage
/// ```swift
/// @State private var isLoading = false
/// 
/// WebView(url: articleURL, isLoading: $isLoading)
///     .opacity(isLoading ? 0 : 1)
/// ```
struct WebView: UIViewRepresentable {
    /// The URL to load in the web view
    let url: URL
    
    /// Binding to track and communicate loading state to parent view
    @Binding var isLoading: Bool
    
    /// Creates and configures the WKWebView instance.
    ///
    /// This method sets up the web view with proper navigation delegation,
    /// gesture support, and initiates the initial page load.
    ///
    /// - Parameter context: The representable context containing the coordinator
    /// - Returns: Configured WKWebView instance ready for display
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        // Set initial loading state for immediate UI feedback
        DispatchQueue.main.async {
            context.coordinator.parent.isLoading = true
        }
        
        // Load the URL immediately when creating the view
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    /// Updates the web view when the URL changes.
    ///
    /// This method handles URL changes by reloading the web view only when
    /// the new URL differs from the currently loaded URL, preventing
    /// unnecessary reloads and maintaining user navigation state.
    ///
    /// - Parameters:
    ///   - webView: The WKWebView instance to update
    ///   - context: The representable context
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Only reload if the URL has changed and it's different from current URL
        if webView.url != url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    /// Creates the coordinator for handling web view navigation events.
    ///
    /// - Returns: Coordinator instance for managing web view delegate callbacks
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// Coordinator class that handles WKWebView navigation delegate methods.
    ///
    /// This class manages the communication between WKWebView and SwiftUI,
    /// handling loading states, timeouts, and error conditions. It ensures
    /// proper memory management and thread-safe state updates.
    class Coordinator: NSObject, WKNavigationDelegate {
        /// Reference to the parent WebView for state updates
        let parent: WebView
        
        /// Timer for handling loading timeouts
        private var loadingTimer: Timer?
        
        /// Initializes the coordinator with a reference to the parent WebView.
        ///
        /// - Parameter parent: The WebView instance that created this coordinator
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        /// Cleanup method that invalidates any active timers.
        deinit {
            loadingTimer?.invalidate()
        }
        
        /// Called when the web view starts loading a page.
        ///
        /// This method sets the loading state to true and establishes a timeout
        /// timer to prevent infinite loading states. The 30-second timeout ensures
        /// that users don't get stuck with a perpetually loading interface.
        ///
        /// - Parameters:
        ///   - webView: The web view that started loading
        ///   - navigation: The navigation object for this load
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
            
            // Set a timeout to prevent infinite loading states
            loadingTimer?.invalidate()
            loadingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { _ in
                DispatchQueue.main.async {
                    self.parent.isLoading = false
                }
            }
        }
        
        /// Called when the web view finishes loading a page successfully.
        ///
        /// This method clears the timeout timer and sets the loading state to false,
        /// indicating that the content is ready for display.
        ///
        /// - Parameters:
        ///   - webView: The web view that finished loading
        ///   - navigation: The navigation object for this load
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            loadingTimer?.invalidate()
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        /// Called when the web view fails to load a page after starting.
        ///
        /// This method handles loading failures that occur after navigation
        /// has begun, clearing the timeout and updating the loading state.
        ///
        /// - Parameters:
        ///   - webView: The web view that failed to load
        ///   - navigation: The navigation object for this load
        ///   - error: The error that caused the failure
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            loadingTimer?.invalidate()
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        /// Called when the web view fails to start loading a page.
        ///
        /// This method handles early loading failures, such as network connectivity
        /// issues or invalid URLs. It gracefully handles cancellation errors that
        /// occur during normal user navigation.
        ///
        /// - Parameters:
        ///   - webView: The web view that failed to load
        ///   - navigation: The navigation object for this load
        ///   - error: The error that caused the failure
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