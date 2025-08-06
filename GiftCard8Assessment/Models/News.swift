//
//  News.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import Foundation

// News model for articles
struct News: Identifiable, Codable {
    let id: String // Use url as unique id
    let title: String
    let summary: String
    let url: String
    let imageUrl: String?
    let source: String
    let publishedAt: Date
    let country: String? = nil // Not provided by GNews
    
    enum CodingKeys: String, CodingKey {
        case title
        case summary = "description"
        case url
        case imageUrl = "image"
        case source
        case publishedAt
    }
    
    enum SourceKeys: String, CodingKey {
        case name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.summary = try container.decodeIfPresent(String.self, forKey: .summary) ?? ""
        self.url = try container.decode(String.self, forKey: .url)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.publishedAt = try container.decode(Date.self, forKey: .publishedAt)
        // Decode nested source.name
        let sourceContainer = try container.nestedContainer(keyedBy: SourceKeys.self, forKey: .source)
        self.source = try sourceContainer.decode(String.self, forKey: .name)
        self.id = self.url // Use url as unique id
    }
}

// MARK: - Sample Data for Previews
extension News {
    static let sampleArticle = News(
        title: "Breaking: Major Technology Breakthrough Announced",
        summary: "Scientists have made a significant discovery that could revolutionize the way we think about renewable energy and sustainable technology.",
        url: "https://example.com/article",
        imageUrl: "https://picsum.photos/300/200",
        source: "Tech News Daily",
        publishedAt: Date()
    )
    
    static let sampleArticleNoImage = News(
        title: "Local Community Celebrates Annual Festival",
        summary: "Thousands gather for the traditional celebration featuring local food, music, and cultural performances.",
        url: "https://example.com/article2",
        imageUrl: nil,
        source: "Local Herald",
        publishedAt: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date()
    )
    
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