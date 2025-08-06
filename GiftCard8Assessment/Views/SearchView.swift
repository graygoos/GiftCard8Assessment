//
//  SearchView.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
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
                        
                        if !searchText.isEmpty {
                            Button("Search") {
                                performSearch()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                    .padding(.horizontal)
                    
                    if let countryCode = viewModel.countryCode {
                        HStack {
                            Text("Local results prioritized for \(countryCode.uppercased())")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))
                
                // Content
                Group {
                    if searchText.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("Search News")
                                .font(.headline)
                            Text("Enter keywords to search for news articles")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                        
                    } else if viewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Searching...")
                                .font(.headline)
                            Text("Finding articles matching '\(searchText)'")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                        
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            Text("Search failed")
                                .font(.headline)
                            Text(error)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            
                            Button("Try Again") {
                                performSearch()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                        
                    } else if viewModel.articles.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No results found")
                                .font(.headline)
                            Text("No articles found for '\(searchText)'")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Button("Try different keywords") {
                                searchText = ""
                                isSearchFocused = true
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                        
                    } else {
                        VStack(spacing: 0) {
                            HStack {
                                Text("\(viewModel.articles.count) results for '\(searchText)'")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(.systemGroupedBackground))
                            
                            List(viewModel.articles) { article in
                                NavigationLink(destination: NewsDetailView(article: article)) {
                                    NewsRowView(article: article)
                                }
                                .listRowBackground(Color(.systemBackground))
                            }
                            .listStyle(PlainListStyle())
                            .refreshable {
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
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isSearchFocused = false
        viewModel.query = searchText
        Task { await viewModel.searchNews() }
    }
}

#Preview {
    SearchView()
}