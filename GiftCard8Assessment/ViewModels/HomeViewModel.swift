import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var articles: [News] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func fetchNews() async {
        isLoading = true
        errorMessage = nil
        
        // Check cache first
        let cacheKey = "global_news"
        if let cachedNews = CacheService.shared.getCachedNews(for: cacheKey) {
            self.articles = cachedNews
            self.isLoading = false
            return
        }
        
        do {
            let news = try await NewsAPIService.shared.fetchGlobalNews()
            self.articles = news
            self.isLoading = false
            
            // Cache the results
            CacheService.shared.cacheNews(news, for: cacheKey)
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
} 