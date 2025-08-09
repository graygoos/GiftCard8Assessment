//
//  LocationView.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI

/// A view that displays location-based news content with comprehensive status information.
///
/// This sophisticated view handles the complex process of displaying location-aware
/// news content while providing clear feedback about location detection status.
/// It implements multiple fallback strategies and comprehensive error handling
/// to ensure users always receive relevant content.
///
/// ## Key Features
/// - Real-time location status updates with clear user feedback
/// - Location-based news content with topic information
/// - Comprehensive error handling with retry functionality
/// - Multiple empty states for different scenarios
/// - Pull-to-refresh support with location-aware refresh logic
/// - Accessibility support throughout the interface
/// - Responsive design with proper visual hierarchy
///
/// ## Location Strategy
/// 1. **Status Header**: Shows current location detection status
/// 2. **Content Display**: Presents location-specific news when available
/// 3. **Fallback Handling**: Gracefully handles location detection failures
/// 4. **Error Recovery**: Provides clear retry mechanisms for users
///
/// ## User Experience
/// - Clear indication of location detection progress
/// - Informative status messages about data source
/// - Appropriate loading states and error messages
/// - Consistent visual design following iOS guidelines
struct LocationView: View {
    /// View model managing location detection and news fetching logic
    @StateObject private var viewModel = LocationViewModel()
    
    /// The main body of the location view with status header and conditional content
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Location status header providing user feedback
                VStack(spacing: 8) {
                    // Primary status line with location icon and status text
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundStyle(.blue)
                        Text(viewModel.locationStatus)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Secondary status line showing content details when available
                    if let _ = viewModel.countryCode, !viewModel.articles.isEmpty {
                        HStack {
                            Text("Local News • \(viewModel.topic.capitalized)")
                                .font(.caption)
                                .foregroundStyle(.blue)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(viewModel.articles.count) articles")
                                .font(.caption2)
                                .foregroundStyle(.gray)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 8)
                .background(Color(.systemGroupedBackground))
                
                // Main content area with conditional states
                Group {
                    // Loading state: Show progress with location-specific messaging
                    if viewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading local news...")
                                .font(.headline)
                            Text("Finding news in your region...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                        
                    // Error state: Show error with location-specific retry option
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundStyle(.orange)
                            Text("Unable to load local news")
                                .font(.headline)
                            Text(error)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                            
                            Button("Try Again") {
                                viewModel.requestLocationBasedNews()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                        
                    // Empty state: Show when no articles are available for the location
                    } else if viewModel.articles.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "newspaper")
                                .font(.largeTitle)
                                .foregroundStyle(.gray)
                            Text("No local news available")
                                .font(.headline)
                            if let country = viewModel.countryCode {
                                Text("No news found for \(country.uppercased())")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Button("Refresh") {
                                viewModel.requestLocationBasedNews()
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                        
                    // Success state: Show location-based news articles
                    } else {
                        List(viewModel.articles) { article in
                            NavigationLink(destination: NewsDetailView(article: article)) {
                                NewsRowView(article: article)
                            }
                            .listRowBackground(Color(.systemBackground))
                        }
                        .listStyle(PlainListStyle())
                        .refreshable {
                            // Location-aware pull-to-refresh
                            if let country = viewModel.countryCode {
                                await viewModel.fetchNewsWithFallback(for: country)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Location")
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    LocationView()
}
