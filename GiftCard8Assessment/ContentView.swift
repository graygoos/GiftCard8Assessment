//
//  ContentView.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI

/// The main content view that provides tab-based navigation for the news application.
///
/// This view serves as the root container for the three main sections of the app:
/// - **Home**: Displays global news headlines
/// - **Location**: Shows location-based news content
/// - **Search**: Provides search functionality with location prioritization
///
/// The tab view ensures consistent navigation and follows iOS design guidelines
/// with appropriate SF Symbols for each tab.
struct ContentView: View {
    /// The main body of the content view containing the tab navigation.
    ///
    /// Each tab contains its respective view with proper labeling and iconography
    /// for optimal user experience and accessibility.
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            LocationView()
                .tabItem {
                    Label("Location", systemImage: "location")
                }
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ContentView()
}
