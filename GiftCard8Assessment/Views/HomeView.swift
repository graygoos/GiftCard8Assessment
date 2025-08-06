//
//  HomeView.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
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
                    
                } else {
                    List(viewModel.articles) { article in
                        NavigationLink(destination: NewsDetailView(article: article)) {
                            NewsRowView(article: article)
                        }
                        .listRowBackground(Color(.systemBackground))
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await viewModel.fetchNews()
                    }
                }
            }
            .navigationTitle("Top Headlines")
            .background(Color(.systemGroupedBackground))
            .task { await viewModel.fetchNews() }
        }
    }
}

#Preview {
    HomeView()
}