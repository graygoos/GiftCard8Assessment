//
//  CacheService.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import Foundation

class CacheService {
    static let shared = CacheService()
    private let cache = NSCache<NSString, CachedNews>()
    private let cacheExpiration: TimeInterval = 300 // 5 minutes
    
    private init() {
        cache.countLimit = 50 // Limit cache size
    }
    
    func getCachedNews(for key: String) -> [News]? {
        guard let cachedNews = cache.object(forKey: NSString(string: key)) else {
            return nil
        }
        
        // Check if cache is expired
        if Date().timeIntervalSince(cachedNews.timestamp) > cacheExpiration {
            cache.removeObject(forKey: NSString(string: key))
            return nil
        }
        
        return cachedNews.articles
    }
    
    func cacheNews(_ articles: [News], for key: String) {
        let cachedNews = CachedNews(articles: articles, timestamp: Date())
        cache.setObject(cachedNews, forKey: NSString(string: key))
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

private class CachedNews {
    let articles: [News]
    let timestamp: Date
    
    init(articles: [News], timestamp: Date) {
        self.articles = articles
        self.timestamp = timestamp
    }
}