//
//  NewsRowView.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI

/// A reusable row view component for displaying news articles in lists.
///
/// This view provides a consistent, accessible, and visually appealing way to
/// display news articles across different sections of the app. It handles
/// image loading with fallbacks, proper text hierarchy, and comprehensive
/// accessibility support.
///
/// ## Key Features
/// - Thumbnail image with graceful fallback for missing images
/// - Proper text hierarchy with headline, summary, and metadata
/// - Responsive layout that adapts to content length
/// - Comprehensive accessibility support with semantic labels
/// - Consistent visual design following iOS guidelines
/// - Relative date formatting for publication times
/// - Source attribution with visual distinction
///
/// ## Layout Structure
/// - **Left**: Thumbnail image (80x80) with fallback placeholder
/// - **Right**: Content stack with headline, summary, and metadata row
/// - **Bottom**: Source and publication date in metadata row
///
/// ## Accessibility
/// - Semantic labels for all content elements
/// - Header trait for article headlines
/// - Combined accessibility elements for metadata
/// - Screen reader friendly content organization
///
/// ## Usage
/// ```swift
/// List(articles) { article in
///     NavigationLink(destination: NewsDetailView(article: article)) {
///         NewsRowView(article: article)
///     }
/// }
/// ```
struct NewsRowView: View {
    /// The news article to display in this row
    let article: News
    
    /// The main body of the news row with image and content layout
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail image section with fallback
            if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
                // Display article image using cached async image loading
                CachedAsyncImage(url: url, contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
            } else {
                // Fallback placeholder for articles without images
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            // Article content section
            VStack(alignment: .leading, spacing: 6) {
                // Article headline with accessibility header trait
                Text(article.title)
                    .font(.headline)
                    .lineLimit(3)
                    .accessibilityLabel("Headline: \(article.title)")
                    .accessibilityAddTraits(.isHeader)
                
                // Article summary with line limit for consistent layout
                Text(article.summary)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Summary: \(article.summary)")
                
                // Metadata row with source and publication date
                HStack {
                    // News source with visual distinction
                    Text(article.source)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .accessibilityLabel("Source: \(article.source)")
                    
                    Spacer()
                    
                    // Relative publication date for better user context
                    Text(article.publishedAt.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .accessibilityLabel("Published: \(article.publishedAt.formatted(.relative(presentation: .named)))")
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    List {
        NewsRowView(article: News.sampleArticle)
        NewsRowView(article: News.sampleArticleNoImage)
    }
}