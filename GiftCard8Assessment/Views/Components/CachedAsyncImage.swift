//
//  CachedAsyncImage.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import SwiftUI

/// A reusable component for loading and displaying images asynchronously with caching support.
///
/// This component wraps SwiftUI's AsyncImage with enhanced error handling,
/// loading states, and consistent visual design. It provides graceful fallbacks
/// for failed image loads and maintains consistent sizing across the app.
///
/// ## Key Features
/// - Automatic image caching through AsyncImage
/// - Loading state with progress indicator
/// - Error state with fallback placeholder
/// - Configurable content modes (fit/fill)
/// - Consistent rounded corner styling
/// - Accessibility support with appropriate labels
/// - Responsive design with proper aspect ratios
///
/// ## States Handled
/// 1. **Loading**: Shows progress indicator with gray background
/// 2. **Success**: Displays the loaded image with proper aspect ratio
/// 3. **Failure**: Shows placeholder with "Image unavailable" message
/// 4. **Unknown**: Graceful fallback for unexpected states
///
/// ## Usage
/// ```swift
/// CachedAsyncImage(url: article.imageUrl, contentMode: .fill)
///     .frame(height: 200)
/// 
/// CachedAsyncImage(url: thumbnailURL, contentMode: .fit)
///     .frame(width: 80, height: 80)
/// ```
struct CachedAsyncImage: View {
    /// Optional URL for the image to load
    let url: URL?
    
    /// Content mode for image display (fit or fill)
    let contentMode: ContentMode
    
    /// Initializes the cached async image component.
    ///
    /// - Parameters:
    ///   - url: Optional URL for the image to load
    ///   - contentMode: How the image should be displayed (defaults to .fit)
    init(url: URL?, contentMode: ContentMode = .fit) {
        self.url = url
        self.contentMode = contentMode
    }
    
    /// The main body of the cached async image component with state handling
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                // Loading state: Show progress indicator with consistent styling
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
                    .frame(height: 200)
                    .accessibilityLabel("Loading image")
                
            case .success(let image):
                // Success state: Display the loaded image with proper aspect ratio
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .accessibilityHidden(true) // Image is decorative in news context
                
            case .failure(_):
                // Error state: Show user-friendly placeholder for failed loads
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
                // Fallback for unknown states (future-proofing)
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