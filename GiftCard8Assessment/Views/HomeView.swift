//
//  HomeView.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI

/// The main home view displaying global news headlines.
///
/// This view provides users with a comprehensive overview of current global news
/// events. It implements a clean, accessible interface with proper loading states,
/// error handling, and pull-to-refresh functionality.
///
/// ## Key Features
/// - Global news headlines from around the world
/// - Loading states with progress indicators and descriptive text
/// - Comprehensive error handling with retry functionality
/// - Pull-to-refresh support for content updates
/// - Navigation to detailed article views
/// - Accessibility support with proper labels and traits
/// - Responsive design with proper background colors
///
/// ## User Experience
/// - Immediate loading indication when fetching news
/// - Clear error messages with actionable retry buttons
/// - Smooth navigation to article details
/// - Consistent visual design following iOS guidelines
///
/// ## Usage
/// This view is typically used as one of the main tabs in the application
/// and automatically loads content when it appears.
struct HomeView: View {
    /// View model managing the home view's state and business logic
    @StateObject private var viewModel = HomeViewModel()
    
    /// The main body of the home view with conditional content based on loading state
    var body: some View {
        NavigationStack {
            Group {
                // Loading state: Show progress indicator with descriptive text
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading global news...")
                            .font(.headline)
                        Text("Getting the latest headlines...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                    
                // Error state: Show error message with retry option
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Unable to load news")
                            .font(.headline)
                        Text(error)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Try Again") {
                            Task { await viewModel.fetchNews() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                    
                // Success state: Show news articles in a list
                } else {
                    List(viewModel.articles) { article in
                        NavigationLink(destination: NewsDetailView(article: article)) {
                            NewsRowView(article: article)
                        }
                        .listRowBackground(Color(.systemBackground))
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        // Pull-to-refresh functionality
                        await viewModel.fetchNews()
                    }
                }
            }
            .navigationTitle("Top Headlines")
            .background(Color(.systemGroupedBackground))
            .task {
                // Automatically load news when view appears
                await viewModel.fetchNews()
            }
        }
    }
}

#Preview {
    HomeView()
}