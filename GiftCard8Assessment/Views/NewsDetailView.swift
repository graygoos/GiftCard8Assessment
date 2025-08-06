//
//  NewsDetailView.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI

struct NewsDetailView: View {
    let article: News
    @State private var showingWebView = false
    @State private var isWebViewLoading = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero image
                if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
                    CachedAsyncImage(url: url, contentMode: .fill)
                        .frame(maxHeight: 250)
                        .clipped()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text(article.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .accessibilityLabel("Headline: \(article.title)")
                    
                    // Metadata
                    HStack {
                        Text(article.source)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text(article.publishedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Source: \(article.source), Published: \(article.publishedAt.formatted(date: .abbreviated, time: .shortened))")
                    
                    Divider()
                    
                    // Summary
                    Text(article.summary)
                        .font(.body)
                        .lineSpacing(4)
                        .accessibilityLabel("Summary: \(article.summary)")
                    
                    // Read full article button
                    Button(action: {
                        showingWebView = true
                    }) {
                        HStack {
                            Image(systemName: "safari")
                            Text("Read Full Article")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .accessibilityLabel("Read full article")
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showingWebView) {
            NavigationView {
                ZStack {
                    // Background color
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    
                    if let url = URL(string: article.url) {
                        WebView(url: url, isLoading: $isWebViewLoading)
                            .opacity(isWebViewLoading ? 0 : 1)
                            .animation(.easeInOut(duration: 0.3), value: isWebViewLoading)
                    } else {
                        // Handle invalid URL
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            Text("Unable to load article")
                                .font(.headline)
                            Text("The article URL is invalid")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    // Loading overlay
                    if isWebViewLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading article...")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                    }
                }
                .navigationTitle(article.source)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if let url = URL(string: article.url) {
                            Button("Open in Safari") {
                                UIApplication.shared.open(url)
                            }
                            .font(.caption)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingWebView = false
                            isWebViewLoading = false // Reset loading state when closing
                        }
                    }
                }
                .onAppear {
                    isWebViewLoading = true // Start loading when sheet appears
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    NavigationView {
        NewsDetailView(article: News.sampleArticle)
    }
}