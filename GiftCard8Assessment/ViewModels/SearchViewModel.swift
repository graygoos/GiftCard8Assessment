import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    @Published var articles: [News] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var query: String = ""
    @Published var countryCode: String? = nil
    
    init() {
        // Use device region setting for country code (no permission required)
        // Preferred iOS approach: Use CoreLocation for actual location, but that requires user permission.
        self.countryCode = Locale.current.region?.identifier.lowercased()
    }
    
    func searchNews() async {
        guard !query.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        // Check cache first
        let cacheKey = "search_\(query)_\(countryCode ?? "global")"
        if let cachedNews = CacheService.shared.getCachedNews(for: cacheKey) {
            self.articles = cachedNews
            self.isLoading = false
            return
        }
        
        do {
            var combined: [News] = []
            if let country = countryCode {
                // For location-prioritized results: get /top-headlines for country, then /search for global
                let locationResults = try await NewsAPIService.shared.fetchNewsByCountry(country)
                let filteredLocationResults = locationResults.filter { $0.title.localizedCaseInsensitiveContains(query) || $0.summary.localizedCaseInsensitiveContains(query) }
                let globalResults = try await NewsAPIService.shared.searchNews(query: query)
                // Location-based results first, then others (remove duplicates)
                combined = (filteredLocationResults + globalResults).uniqued(by: { $0.id })
            } else {
                combined = try await NewsAPIService.shared.searchNews(query: query)
            }
            self.articles = combined
            self.isLoading = false
            
            // Cache the results
            CacheService.shared.cacheNews(combined, for: cacheKey)
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}

 