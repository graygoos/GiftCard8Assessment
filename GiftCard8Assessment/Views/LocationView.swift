//
//  LocationView.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI

struct LocationView: View {
    @StateObject private var viewModel = LocationViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Location status header
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text(viewModel.locationStatus)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    if let _ = viewModel.countryCode, !viewModel.articles.isEmpty {
                        HStack {
                            Text("Local News • \(viewModel.topic.capitalized)")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(viewModel.articles.count) articles")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 8)
                .background(Color(.systemGroupedBackground))
                
                // Content
                Group {
                    if viewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading local news...")
                                .font(.headline)
                            Text("Finding news in your region...")
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
                            Text("Unable to load local news")
                                .font(.headline)
                            Text(error)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            
                            Button("Try Again") {
                                viewModel.requestLocationBasedNews()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                        
                    } else if viewModel.articles.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "newspaper")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No local news available")
                                .font(.headline)
                            if let country = viewModel.countryCode {
                                Text("No news found for \(country.uppercased())")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            
                            Button("Refresh") {
                                viewModel.requestLocationBasedNews()
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                        
                    } else {
                        List(viewModel.articles) { article in
                            NavigationLink(destination: NewsDetailView(article: article)) {
                                NewsRowView(article: article)
                            }
                            .listRowBackground(Color(.systemBackground))
                        }
                        .listStyle(PlainListStyle())
                        .refreshable {
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