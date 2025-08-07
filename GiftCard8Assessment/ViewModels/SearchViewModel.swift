import Foundation

/// View model for the Search tab that manages news search functionality.
///
/// This view model provides comprehensive search capabilities with location-aware
/// result prioritization. It combines local filtering with global search to
/// deliver the most relevant results to users based on their location.
///
/// ## Key Features
/// - Location-prioritized search results
/// - Automatic device region detection
/// - Comprehensive caching for search queries
/// - Duplicate result filtering
/// - Main actor isolation for UI thread safety
/// - Observable properties for reactive UI updates
///
/// ## Search Strategy
/// 1. **Local Filtering**: Searches local headlines for query matches
/// 2. **Global Search**: Performs API search across all available content
/// 3. **Result Combination**: Merges results with local content prioritized
/// 4. **Deduplication**: Removes duplicate articles using unique identifiers
///
/// ## Usage
/// ```swift
/// @StateObject private var viewModel = SearchViewModel()
/// 
/// viewModel.query = "technology"
/// await viewModel.searchNews()
/// ```
@MainActor
class SearchViewModel: ObservableObject {
    /// Array of search result articles for display
    @Published var articles: [News] = []
    
    /// Loading state indicator for progress views
    @Published var isLoading: Bool = false
    
    /// Error message for display when search fails
    @Published var errorMessage: String? = nil
    
    /// Current search query string
    @Published var query: String = ""
    
    /// Country code for location-aware search prioritization
    @Published var countryCode: String? = nil
    
    /// Initializes the search view model with device region detection.
    ///
    /// The initialization uses device region settings rather than requesting
    /// location permissions, providing a privacy-friendly approach to
    /// location-aware search while still offering relevant local content prioritization.
    init() {
        // Use device region setting for country code (no location permission required)
        // This provides location context without privacy concerns
        self.countryCode = Locale.current.region?.identifier.lowercased()
    }
    
    /// Performs a comprehensive search with location-aware result prioritization.
    ///
    /// This method implements a sophisticated search strategy that combines
    /// local content filtering with global search capabilities to provide
    /// the most relevant results. Local content is prioritized when available,
    /// and duplicate results are automatically filtered out.
    ///
    /// ## Search Process
    /// 1. **Validation**: Ensures query is not empty
    /// 2. **Cache Check**: Returns cached results if available and fresh
    /// 3. **Local Filtering**: Searches local headlines for query matches
    /// 4. **Global Search**: Performs API search across all content
    /// 5. **Result Merging**: Combines results with local content first
    /// 6. **Deduplication**: Removes duplicate articles by ID
    /// 7. **Caching**: Stores results for future requests
    func searchNews() async {
        // Validate search query
        guard !query.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Check cache first for improved performance
        let cacheKey = "search_\(query)_\(countryCode ?? "global")"
        if let cachedNews = CacheService.shared.getCachedNews(for: cacheKey) {
            self.articles = cachedNews
            self.isLoading = false
            return
        }
        
        do {
            var combined: [News] = []
            
            if let country = countryCode {
                // Location-aware search: prioritize local content
                
                // 1. Get local headlines and filter for query matches
                let locationResults = try await NewsAPIService.shared.fetchNewsByCountry(country)
                let filteredLocationResults = locationResults.filter { article in
                    article.title.localizedCaseInsensitiveContains(query) ||
                    article.summary.localizedCaseInsensitiveContains(query)
                }
                
                // 2. Get global search results
                let globalResults = try await NewsAPIService.shared.searchNews(query: query)
                
                // 3. Combine with local results first, then remove duplicates
                combined = (filteredLocationResults + globalResults).uniqued(by: { $0.id })
            } else {
                // Fallback to global search only
                combined = try await NewsAPIService.shared.searchNews(query: query)
            }
            
            self.articles = combined
            self.isLoading = false
            
            // Cache the results for future requests
            CacheService.shared.cacheNews(combined, for: cacheKey)
        } catch {
            // Handle search errors gracefully
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}

 