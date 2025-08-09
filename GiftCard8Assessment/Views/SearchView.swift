//
//  SearchView.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI

/// A comprehensive search view for finding news articles with location-aware prioritization.
///
/// This view provides a full-featured search experience that combines intuitive
/// user interface design with sophisticated search capabilities. It prioritizes
/// local content when available while providing access to global news coverage.
///
/// ## Key Features
/// - Real-time search with submit-on-enter functionality
/// - Location-aware result prioritization
/// - Dynamic search button that appears when typing
/// - Comprehensive state management (empty, loading, error, results)
/// - Result count display with query highlighting
/// - Pull-to-refresh support for search results
/// - Accessibility support with proper focus management
/// - Responsive design with proper visual hierarchy
///
/// ## Search Experience
/// 1. **Empty State**: Welcoming interface encouraging search
/// 2. **Active Search**: Dynamic UI with search button and location context
/// 3. **Loading State**: Clear progress indication during search
/// 4. **Results Display**: Clean list with result count and query context
/// 5. **Error Handling**: User-friendly error messages with retry options
/// 6. **No Results**: Helpful messaging with suggestions for refinement
///
/// ## Location Integration
/// - Automatic device region detection for context
/// - Local results prioritized in search results
/// - Clear indication of location-based prioritization
struct SearchView: View {
    /// View model managing search state and business logic
    @StateObject private var viewModel = SearchViewModel()
    
    /// Local search text state for immediate UI updates
    @State private var searchText = ""
    
    /// Focus state for managing search field keyboard and focus behavior
    @FocusState private var isSearchFocused: Bool
    
    /// The main body of the search view with search bar and conditional content
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar section with location context
                VStack(spacing: 8) {
                    // Main search input with dynamic search button
                    HStack(spacing: 12) {
                        // Search text field with magnifying glass icon
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.gray)
                            TextField("Search headlines...", text: $searchText)
                                .focused($isSearchFocused)
                                .onSubmit {
                                    performSearch()
                                }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        // Dynamic search button (appears when typing)
                        if !searchText.isEmpty {
                            Button("Search") {
                                performSearch()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Location context indicator
                    if let countryCode = viewModel.countryCode {
                        HStack {
                            Text("Local results prioritized for \(countryCode.uppercased())")
                                .font(.caption)
                                .foregroundStyle(.blue)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))
                
                // Main content area with conditional states
                Group {
                    // Empty state: Welcome message encouraging search
                    if searchText.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.largeTitle)
                                .foregroundStyle(.gray)
                            Text("Search News")
                                .font(.headline)
                            Text("Enter keywords to search for news articles")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                        
                    // Loading state: Show progress with search context
                    } else if viewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Searching...")
                                .font(.headline)
                            Text("Finding articles matching '\(searchText)'")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                        
                    // Error state: Show search-specific error with retry
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundStyle(.orange)
                            Text("Search failed")
                                .font(.headline)
                            Text(error)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                            
                            Button("Try Again") {
                                performSearch()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                        
                    // No results state: Encourage query refinement
                    } else if viewModel.articles.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.largeTitle)
                                .foregroundStyle(.gray)
                            Text("No results found")
                                .font(.headline)
                            Text("No articles found for '\(searchText)'")
                                .font(.body)
                                .foregroundStyle(.secondary)
                            
                            Button("Try different keywords") {
                                searchText = ""
                                isSearchFocused = true
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                        
                    // Results state: Show search results with count and refresh
                    } else {
                        VStack(spacing: 0) {
                            // Results header with count and query context
                            HStack {
                                Text("\(viewModel.articles.count) results for '\(searchText)'")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(.systemGroupedBackground))
                            
                            // Search results list
                            List(viewModel.articles) { article in
                                NavigationLink(destination: NewsDetailView(article: article)) {
                                    NewsRowView(article: article)
                                }
                                .listRowBackground(Color(.systemBackground))
                            }
                            .listStyle(PlainListStyle())
                            .refreshable {
                                // Pull-to-refresh for search results
                                await viewModel.searchNews()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    /// Performs a search operation with proper validation and state management.
    ///
    /// This method handles the search initiation process:
    /// 1. Validates that the search query is not empty or whitespace-only
    /// 2. Dismisses the keyboard by removing focus from the search field
    /// 3. Updates the view model's query property
    /// 4. Initiates the asynchronous search operation
    ///
    /// The method ensures a clean user experience by managing focus states
    /// and preventing empty searches from being executed.
    private func performSearch() {
        // Validate search query (ignore whitespace-only queries)
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Dismiss keyboard and remove focus from search field
        isSearchFocused = false
        
        // Update view model and initiate search
        viewModel.query = searchText
        Task { await viewModel.searchNews() }
    }
}

#Preview {
    SearchView()
}
