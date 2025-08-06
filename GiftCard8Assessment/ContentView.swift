//
//  ContentView.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI

struct ContentView: View {
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
