//
//  NewsRowView.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI

struct NewsRowView: View {
    let article: News
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail image
            if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
                CachedAsyncImage(url: url, contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(3)
                    .accessibilityLabel("Headline: \(article.title)")
                    .accessibilityAddTraits(.isHeader)
                
                Text(article.summary)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Summary: \(article.summary)")
                
                HStack {
                    Text(article.source)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .accessibilityLabel("Source: \(article.source)")
                    
                    Spacer()
                    
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