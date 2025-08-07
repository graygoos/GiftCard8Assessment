//
//  News.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import Foundation

/// A model representing a news article with all necessary information for display and interaction.
///
/// This struct conforms to `Identifiable` for SwiftUI list rendering and `Codable` for JSON
/// serialization/deserialization from the GNews API. The model handles the complex nested
/// JSON structure from the API and provides a clean interface for the app.
///
/// ## Key Features
/// - Automatic URL-based unique identification
/// - Custom JSON decoding for nested source information
/// - Optional image URL handling
/// - Date parsing with ISO8601 format
/// - Sample data for SwiftUI previews
///
/// ## Usage
/// ```swift
/// let article = News(from: decoder) // From API response
/// let sample = News.sampleArticle   // For previews
/// ```
struct News: Identifiable, Codable {
    /// Unique identifier for the article, derived from the URL
    let id: String
    
    /// The headline/title of the news article
    let title: String
    
    /// Brief summary or description of the article content
    let summary: String
    
    /// Full URL to the original article
    let url: String
    
    /// Optional URL to the article's featured image
    let imageUrl: String?
    
    /// Name of the news source/publication
    let source: String
    
    /// Publication date and time of the article
    let publishedAt: Date
    
    /// Country code (not provided by GNews API, kept for potential future use)
    let country: String? = nil
    
    /// Coding keys for mapping JSON properties to Swift properties
    enum CodingKeys: String, CodingKey {
        case title
        case summary = "description"  // Maps "description" from JSON to "summary"
        case url
        case imageUrl = "image"       // Maps "image" from JSON to "imageUrl"
        case source
        case publishedAt
    }
    
    /// Nested coding keys for extracting source name from nested JSON structure
    enum SourceKeys: String, CodingKey {
        case name
    }
    
    /// Custom initializer for decoding from JSON with nested source structure.
    ///
    /// This initializer handles the complex JSON structure from the GNews API where
    /// the source information is nested within a "source" object containing a "name" field.
    ///
    /// - Parameter decoder: The decoder containing the JSON data
    /// - Throws: DecodingError if required fields are missing or malformed
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode basic properties
        self.title = try container.decode(String.self, forKey: .title)
        self.summary = try container.decodeIfPresent(String.self, forKey: .summary) ?? ""
        self.url = try container.decode(String.self, forKey: .url)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.publishedAt = try container.decode(Date.self, forKey: .publishedAt)
        
        // Decode nested source.name structure
        let sourceContainer = try container.nestedContainer(keyedBy: SourceKeys.self, forKey: .source)
        self.source = try sourceContainer.decode(String.self, forKey: .name)
        
        // Use URL as unique identifier
        self.id = self.url
    }
}

// MARK: - Sample Data for Previews

/// Extension providing sample data for SwiftUI previews and testing.
///
/// This extension includes pre-configured News instances that can be used
/// in SwiftUI previews, unit tests, and during development.
extension News {
    /// Sample article with image for preview purposes.
    ///
    /// Represents a typical news article with all fields populated,
    /// including a placeholder image URL for testing image loading.
    static let sampleArticle = News(
        title: "Breaking: Major Technology Breakthrough Announced",
        summary: "Scientists have made a significant discovery that could revolutionize the way we think about renewable energy and sustainable technology.",
        url: "https://example.com/article",
        imageUrl: "https://picsum.photos/300/200",
        source: "Tech News Daily",
        publishedAt: Date()
    )
    
    /// Sample article without image for testing fallback scenarios.
    ///
    /// Useful for testing how the UI handles articles that don't have
    /// associated images, ensuring proper fallback behavior.
    static let sampleArticleNoImage = News(
        title: "Local Community Celebrates Annual Festival",
        summary: "Thousands gather for the traditional celebration featuring local food, music, and cultural performances.",
        url: "https://example.com/article2",
        imageUrl: nil,
        source: "Local Herald",
        publishedAt: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date()
    )
    
    /// Private initializer for creating sample instances.
    ///
    /// This initializer bypasses the JSON decoding process and allows
    /// direct creation of News instances for testing and preview purposes.
    ///
    /// - Parameters:
    ///   - title: The article headline
    ///   - summary: Brief description of the article
    ///   - url: URL to the full article
    ///   - imageUrl: Optional image URL
    ///   - source: Name of the news source
    ///   - publishedAt: Publication date
    private init(title: String, summary: String, url: String, imageUrl: String?, source: String, publishedAt: Date) {
        self.id = url
        self.title = title
        self.summary = summary
        self.url = url
        self.imageUrl = imageUrl
        self.source = source
        self.publishedAt = publishedAt
    }
}