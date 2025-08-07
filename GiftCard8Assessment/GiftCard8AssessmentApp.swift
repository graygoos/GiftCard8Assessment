//
//  GiftCard8AssessmentApp.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI

/// The main entry point for the GiftCard8Assessment news application.
///
/// This app provides a comprehensive news reading experience with three main features:
/// - **Home**: Global news headlines from around the world
/// - **Location**: Location-based news tailored to the user's region
/// - **Search**: Search functionality with location-prioritized results
///
/// The app follows MVVM architecture pattern and implements proper caching,
/// error handling, and accessibility features throughout.
@main
struct GiftCard8AssessmentApp: App {
    /// The main scene configuration for the app.
    ///
    /// Creates a window group containing the main content view with tab navigation.
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#Preview {
    ContentView()
}
