import Foundation

/// A service class responsible for fetching news articles from the GNews API.
///
/// This singleton service provides methods for fetching different types of news content:
/// - Global headlines from around the world
/// - Country-specific news with optional topic filtering
/// - Search functionality across all available articles
///
/// ## Key Features
/// - Singleton pattern for consistent API usage
/// - Async/await support for modern Swift concurrency
/// - Proper error handling and URL validation
/// - Support for country-specific and topic-based filtering
/// - Search functionality with query encoding
///
/// ## Usage
/// ```swift
/// let service = NewsAPIService.shared
/// let articles = try await service.fetchGlobalNews()
/// let localNews = try await service.fetchNewsByCountry("us")
/// let searchResults = try await service.searchNews(query: "technology")
/// ```
class NewsAPIService {
    /// Shared singleton instance of the news API service
    static let shared = NewsAPIService()
    
    /// API key for authenticating with the GNews service
    private let apiKey = Secrets.newsAPIKey
    
    /// Base URL for all GNews API endpoints
    private let baseURL = "https://gnews.io/api/v4"
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    /// Fetches global news headlines from around the world.
    ///
    /// This method retrieves the latest top headlines without any geographic filtering,
    /// providing a broad overview of current global news events.
    ///
    /// - Returns: An array of `News` objects representing current global headlines
    /// - Throws: `URLError` if the request fails or returns invalid data
    func fetchGlobalNews() async throws -> [News] {
        let urlString = "\(baseURL)/top-headlines?token=\(apiKey)&lang=en"
        return try await fetchNews(from: urlString)
    }
    
    /// Fetches news headlines for a specific country with optional topic filtering.
    ///
    /// This method retrieves location-specific news content, allowing for targeted
    /// news consumption based on the user's geographic location or interest.
    ///
    /// - Parameters:
    ///   - country: ISO country code (e.g., "us", "uk", "ca")
    ///   - topic: Optional topic filter (e.g., "general", "business", "technology")
    /// - Returns: An array of `News` objects for the specified country and topic
    /// - Throws: `URLError` if the request fails or returns invalid data
    func fetchNewsByCountry(_ country: String, topic: String? = nil) async throws -> [News] {
        var urlString = "\(baseURL)/top-headlines?token=\(apiKey)&lang=en&country=\(country)&max=10"
        if let topic = topic {
            urlString += "&topic=\(topic)"
        }
        print("[DEBUG] Location API URL: \(urlString)")
        return try await fetchNews(from: urlString)
    }
    
    /// Searches for news articles matching the specified query.
    ///
    /// This method performs a full-text search across available news articles,
    /// with optional country-based filtering for more relevant results.
    ///
    /// - Parameters:
    ///   - query: Search terms to look for in article titles and content
    ///   - country: Optional ISO country code to limit search scope
    /// - Returns: An array of `News` objects matching the search criteria
    /// - Throws: `URLError` if the request fails or returns invalid data
    func searchNews(query: String, country: String? = nil) async throws -> [News] {
        var urlString = "\(baseURL)/search?token=\(apiKey)&lang=en&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        if let country = country {
            urlString += "&country=\(country)"
        }
        return try await fetchNews(from: urlString)
    }
    
    /// Generic method for fetching and parsing news data from any GNews API endpoint.
    ///
    /// This private method handles the common networking logic shared across all
    /// public API methods, including URL validation, HTTP request execution,
    /// response validation, and JSON parsing.
    ///
    /// - Parameter urlString: Complete URL string for the API request
    /// - Returns: An array of parsed `News` objects
    /// - Throws: `URLError` for networking issues or `DecodingError` for parsing failures
    private func fetchNews(from urlString: String) async throws -> [News] {
        // Validate URL format
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // Execute HTTP request
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Validate HTTP response status
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Configure JSON decoder for ISO8601 date format
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Parse API response and extract articles
        let apiResponse = try decoder.decode(GNewsAPIResponse.self, from: data)
        return apiResponse.articles
    }
}

/// Response model for decoding the complete GNews API response structure.
///
/// The GNews API returns responses in a specific format with metadata about
/// the total number of articles and an array of article objects. This struct
/// provides a clean way to decode and access this information.
///
/// ## JSON Structure
/// ```json
/// {
///   "totalArticles": 42,
///   "articles": [...]
/// }
/// ```
struct GNewsAPIResponse: Codable {
    /// Total number of articles available for the request (may exceed returned count)
    let totalArticles: Int
    
    /// Array of news articles returned by the API
    let articles: [News]
} 
