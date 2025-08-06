//
//  CachedAsyncImage.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI

struct CachedAsyncImage: View {
    let url: URL?
    let contentMode: ContentMode
    
    init(url: URL?, contentMode: ContentMode = .fit) {
        self.url = url
        self.contentMode = contentMode
    }
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                // Loading state
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
                    .frame(height: 200)
                    .accessibilityLabel("Loading image")
                
            case .success(let image):
                // Success state
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .accessibilityHidden(true)
                
            case .failure(_):
                // Error state
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Image unavailable")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
                    .frame(height: 200)
                    .accessibilityLabel("Image failed to load")
                
            @unknown default:
                // Fallback
                EmptyView()
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CachedAsyncImage(url: URL(string: "https://picsum.photos/300/200"), contentMode: .fill)
            .frame(height: 200)
        
        CachedAsyncImage(url: nil, contentMode: .fill)
            .frame(height: 200)
    }
    .padding()
}