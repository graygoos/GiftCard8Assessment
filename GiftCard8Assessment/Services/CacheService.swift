//
//  CacheService.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import Foundation

/// A singleton service for caching news articles to improve performance and reduce API calls.
///
/// This service implements an in-memory cache with automatic expiration to balance
/// performance with data freshness. It helps reduce network requests and provides
/// faster loading times for recently accessed content.
///
/// ## Key Features
/// - Singleton pattern for app-wide cache consistency
/// - Automatic cache expiration (5 minutes default)
/// - Memory management with configurable size limits
/// - Thread-safe operations using NSCache
/// - Key-based storage for different content types
///
/// ## Usage
/// ```swift
/// let cache = CacheService.shared
/// 
/// // Store articles
/// cache.cacheNews(articles, for: "global_news")
/// 
/// // Retrieve articles
/// if let cached = cache.getCachedNews(for: "global_news") {
///     // Use cached data
/// }
/// ```
class CacheService {
    /// Shared singleton instance of the cache service
    static let shared = CacheService()
    
    /// Internal NSCache for storing cached news data
    private let cache = NSCache<NSString, CachedNews>()
    
    /// Cache expiration time in seconds (5 minutes)
    private let cacheExpiration: TimeInterval = 300
    
    /// Private initializer to enforce singleton pattern and configure cache settings
    private init() {
        // Limit cache to 50 entries to manage memory usage
        cache.countLimit = 50
    }
    
    /// Retrieves cached news articles for the specified key if they haven't expired.
    ///
    /// This method checks both the existence of cached data and its freshness.
    /// Expired cache entries are automatically removed to prevent stale data usage.
    ///
    /// - Parameter key: Unique identifier for the cached content (e.g., "global_news", "search_tech")
    /// - Returns: Array of cached `News` objects if valid cache exists, nil otherwise
    func getCachedNews(for key: String) -> [News]? {
        // Attempt to retrieve cached data
        guard let cachedNews = cache.object(forKey: NSString(string: key)) else {
            return nil
        }
        
        // Check if cache has expired
        if Date().timeIntervalSince(cachedNews.timestamp) > cacheExpiration {
            // Remove expired cache entry
            cache.removeObject(forKey: NSString(string: key))
            return nil
        }
        
        return cachedNews.articles
    }
    
    /// Stores news articles in the cache with the current timestamp.
    ///
    /// This method creates a new cache entry with the provided articles and
    /// associates it with the specified key for later retrieval.
    ///
    /// - Parameters:
    ///   - articles: Array of `News` objects to cache
    ///   - key: Unique identifier for this cache entry
    func cacheNews(_ articles: [News], for key: String) {
        let cachedNews = CachedNews(articles: articles, timestamp: Date())
        cache.setObject(cachedNews, forKey: NSString(string: key))
    }
    
    /// Removes all cached entries from memory.
    ///
    /// This method is useful for clearing stale data or managing memory usage.
    /// It completely empties the cache, forcing fresh API requests for all subsequent data needs.
    func clearCache() {
        cache.removeAllObjects()
    }
}

/// Private wrapper class for storing news articles with timestamp information.
///
/// This class encapsulates cached news data along with the time it was stored,
/// enabling automatic expiration checking. It's designed to work with NSCache
/// which requires reference types (classes) rather than value types (structs).
private class CachedNews {
    /// The cached news articles
    let articles: [News]
    
    /// Timestamp when the articles were cached
    let timestamp: Date
    
    /// Initializes a new cached news entry with articles and timestamp.
    ///
    /// - Parameters:
    ///   - articles: Array of news articles to cache
    ///   - timestamp: Time when the articles were cached
    init(articles: [News], timestamp: Date) {
        self.articles = articles
        self.timestamp = timestamp
    }
}