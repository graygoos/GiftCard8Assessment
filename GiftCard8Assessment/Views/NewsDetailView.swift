//
//  NewsDetailView.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI

/// A detailed view for displaying individual news articles with full content and web integration.
///
/// This comprehensive view provides users with a complete article reading experience,
/// including hero images, full article content, metadata, and the ability to read
/// the full article in an integrated web view. It follows iOS design guidelines
/// and implements proper accessibility support throughout.
///
/// ## Key Features
/// - Hero image display with fallback handling
/// - Complete article metadata (source, publication date)
/// - Full article summary with proper typography
/// - Integrated web view for reading complete articles
/// - Loading states for web content
/// - External Safari integration option
/// - Comprehensive accessibility support
/// - Proper navigation and toolbar management
///
/// ## Web Integration
/// - Modal sheet presentation for web content
/// - Loading state management with visual feedback
/// - Error handling for invalid URLs
/// - Safari fallback option for external browsing
/// - Proper cleanup when dismissing web view
///
/// ## Accessibility
/// - Semantic labels for all content elements
/// - Proper heading hierarchy and traits
/// - Combined accessibility elements where appropriate
/// - Screen reader friendly content organization
struct NewsDetailView: View {
    /// The news article to display in detail
    let article: News
    
    /// State controlling the presentation of the web view modal
    @State private var showingWebView = false
    
    /// State tracking web view loading progress for UI feedback
    @State private var isWebViewLoading = false
    
    /// The main body of the news detail view with scrollable content
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero image section with fallback handling
                if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
                    CachedAsyncImage(url: url, contentMode: .fill)
                        .frame(maxHeight: 250)
                        .clipped()
                }
                
                // Article content section
                VStack(alignment: .leading, spacing: 16) {
                    // Article headline with accessibility support
                    Text(article.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .accessibilityLabel("Headline: \(article.title)")
                    
                    // Article metadata (source and publication date)
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
                    
                    // Article summary with proper typography
                    Text(article.summary)
                        .font(.body)
                        .lineSpacing(4)
                        .accessibilityLabel("Summary: \(article.summary)")
                    
                    // Call-to-action button for reading full article
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
            // Modal web view for reading full article
            NavigationStack {
                ZStack {
                    // Base background color
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    
                    // Web view or error state
                    if let url = URL(string: article.url) {
                        WebView(url: url, isLoading: $isWebViewLoading)
                            .opacity(isWebViewLoading ? 0 : 1)
                            .animation(.easeInOut(duration: 0.3), value: isWebViewLoading)
                    } else {
                        // Error state for invalid URLs
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
                    
                    // Loading overlay with progress indicator
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
                    // Safari integration button
                    ToolbarItem(placement: .navigationBarLeading) {
                        if let url = URL(string: article.url) {
                            Button("Open in Safari") {
                                UIApplication.shared.open(url)
                            }
                            .font(.caption)
                        }
                    }
                    
                    // Done button to dismiss modal
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingWebView = false
                            isWebViewLoading = false // Reset loading state when closing
                        }
                    }
                }
                .onAppear {
                    // Initialize loading state when modal appears
                    isWebViewLoading = true
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    NavigationStack {
        NewsDetailView(article: News.sampleArticle)
    }
}
