import Foundation

// Networking layer for fetching news articles (GNews)
class NewsAPIService {
    static let shared = NewsAPIService()
    private let apiKey = Secrets.newsAPIKey
    private let baseURL = "https://gnews.io/api/v4" // GNews base URL
    
    private init() {}
    
    // Fetch global news headlines
    func fetchGlobalNews() async throws -> [News] {
        let urlString = "\(baseURL)/top-headlines?token=\(apiKey)&lang=en"
        return try await fetchNews(from: urlString)
    }
    
    // Fetch news by country code, optionally with topic
    func fetchNewsByCountry(_ country: String, topic: String? = nil) async throws -> [News] {
        var urlString = "\(baseURL)/top-headlines?token=\(apiKey)&lang=en&country=\(country)&max=10"
        if let topic = topic {
            urlString += "&topic=\(topic)"
        }
        print("[DEBUG] Location API URL: \(urlString)")
        return try await fetchNews(from: urlString)
    }
    
    // Search news headlines (optionally by country)
    func searchNews(query: String, country: String? = nil) async throws -> [News] {
        var urlString = "\(baseURL)/search?token=\(apiKey)&lang=en&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        if let country = country {
            urlString += "&country=\(country)"
        }
        return try await fetchNews(from: urlString)
    }
    
    // Generic fetch method
    private func fetchNews(from urlString: String) async throws -> [News] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let apiResponse = try decoder.decode(GNewsAPIResponse.self, from: data)
        return apiResponse.articles
    }
}

// Response model for decoding GNews API response
struct GNewsAPIResponse: Codable {
    let totalArticles: Int
    let articles: [News]
} 
