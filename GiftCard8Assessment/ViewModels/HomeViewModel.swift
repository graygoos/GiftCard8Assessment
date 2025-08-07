import Foundation

/// View model for the Home tab that manages global news headlines.
///
/// This view model follows the MVVM pattern and handles the business logic
/// for displaying global news content. It manages loading states, error handling,
/// and integrates with both the news API service and caching system.
///
/// ## Key Features
/// - Async/await support for modern Swift concurrency
/// - Automatic caching integration for improved performance
/// - Comprehensive error handling with user-friendly messages
/// - Observable properties for reactive UI updates
/// - Main actor isolation for UI thread safety
///
/// ## Usage
/// ```swift
/// @StateObject private var viewModel = HomeViewModel()
/// 
/// // In view body
/// if viewModel.isLoading {
///     ProgressView()
/// } else {
///     List(viewModel.articles) { article in
///         NewsRowView(article: article)
///     }
/// }
/// ```
@MainActor
class HomeViewModel: ObservableObject {
    /// Array of global news articles for display in the UI
    @Published var articles: [News] = []
    
    /// Loading state indicator for showing progress views
    @Published var isLoading: Bool = false
    
    /// Error message for display when news fetching fails
    @Published var errorMessage: String? = nil
    
    /// Fetches global news headlines with caching support.
    ///
    /// This method implements a cache-first strategy to improve performance:
    /// 1. Checks for valid cached data first
    /// 2. Returns cached data immediately if available
    /// 3. Falls back to API request if cache is empty or expired
    /// 4. Caches successful API responses for future use
    ///
    /// The method properly manages loading states and error conditions,
    /// ensuring the UI can respond appropriately to all scenarios.
    func fetchNews() async {
        isLoading = true
        errorMessage = nil
        
        // Check cache first for improved performance
        let cacheKey = "global_news"
        if let cachedNews = CacheService.shared.getCachedNews(for: cacheKey) {
            self.articles = cachedNews
            self.isLoading = false
            return
        }
        
        do {
            // Fetch fresh data from API
            let news = try await NewsAPIService.shared.fetchGlobalNews()
            self.articles = news
            self.isLoading = false
            
            // Cache the results for future requests
            CacheService.shared.cacheNews(news, for: cacheKey)
        } catch {
            // Handle API errors gracefully
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
} 