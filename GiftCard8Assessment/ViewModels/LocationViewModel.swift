import Foundation
import Combine

@MainActor
class LocationViewModel: ObservableObject {
    @Published var articles: [News] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var countryCode: String? = nil
    @Published var topic: String = "general"
    @Published var locationStatus: String = "Detecting location..."
    
    private var cancellables = Set<AnyCancellable>()
    private let locationManager = LocationManager()
    
    init() {
        setupLocationObserver()
        // Try device region as fallback immediately
        if let code = Locale.current.region?.identifier.lowercased() {
            self.countryCode = code
            self.locationStatus = "Using device region: \(code.uppercased())"
            // Load news immediately with device region
            Task {
                await fetchNewsWithFallback(for: code)
            }
        }
        
        // Start location detection for more accurate location
        requestLocationBasedNews()
    }
    
    private func setupLocationObserver() {
        // Observe location manager updates
        locationManager.$countryCode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countryCode in
                if let countryCode = countryCode {
                    self?.countryCode = countryCode
                    self?.locationStatus = "Location detected: \(countryCode.uppercased())"
                    Task {
                        await self?.fetchNewsWithFallback(for: countryCode)
                    }
                }
            }
            .store(in: &cancellables)
        
        locationManager.$locationError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if error != nil {
                    // Fall back to device region
                    if let code = Locale.current.region?.identifier.lowercased() {
                        self?.countryCode = code
                        self?.locationStatus = "Using device region: \(code.uppercased())"
                        Task {
                            await self?.fetchNewsWithFallback(for: code)
                        }
                    } else {
                        self?.errorMessage = "Could not determine location or device region."
                        self?.locationStatus = "Location unavailable"
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func requestLocationBasedNews() {
        // Start location detection
        locationManager.requestLocationPermission()
        
        // If we already have a country code, fetch news
        if let countryCode = countryCode {
            Task {
                await fetchNewsWithFallback(for: countryCode)
            }
        } else {
            // Set loading state while waiting for location
            isLoading = true
            locationStatus = "Detecting location..."
        }
    }
    
    func fetchNewsWithFallback(for country: String) async {
        isLoading = true
        errorMessage = nil
        
        // Check cache first
        let cacheKey = "location_\(country)"
        if let cachedNews = CacheService.shared.getCachedNews(for: cacheKey) {
            self.articles = cachedNews
            self.isLoading = false
            print("[DEBUG] Using cached news for \(country)")
            return
        }
        
        // Try multiple approaches to get location-based news
        let strategies: [(topic: String?, description: String)] = [
            (nil, "general headlines"),
            ("general", "general news"),
            ("world", "world news"),
            ("breaking-news", "breaking news"),
            ("nation", "national news")
        ]
        
        for strategy in strategies {
            do {
                let news = try await NewsAPIService.shared.fetchNewsByCountry(country, topic: strategy.topic)
                if !news.isEmpty {
                    self.articles = news
                    self.topic = strategy.topic ?? "headlines"
                    self.isLoading = false
                    
                    // Cache the results
                    CacheService.shared.cacheNews(news, for: cacheKey)
                    
                    print("[DEBUG] Found \(news.count) articles for \(country) with \(strategy.description)")
                    return
                }
            } catch {
                print("[DEBUG] Error fetching \(strategy.description) for \(country): \(error)")
                continue
            }
        }
        
        // Final fallback: try global news if country-specific fails
        do {
            let globalNews = try await NewsAPIService.shared.fetchGlobalNews()
            if !globalNews.isEmpty {
                self.articles = Array(globalNews.prefix(10)) // Limit to 10 articles
                self.topic = "global"
                self.locationStatus = "Showing global news (local news unavailable)"
                self.isLoading = false
                
                // Cache the results
                CacheService.shared.cacheNews(self.articles, for: cacheKey)
                
                print("[DEBUG] Using global news as fallback")
                return
            }
        } catch {
            print("[DEBUG] Error fetching global news as fallback: \(error)")
        }
        
        // If all attempts fail, show error
        self.errorMessage = "Unable to load news at this time. Please check your internet connection and try again."
        self.isLoading = false
    }
    
    @MainActor
    func fetchNews(for country: String, topic: String = "general") async {
        isLoading = true
        errorMessage = nil
        do {
            let news = try await NewsAPIService.shared.fetchNewsByCountry(country, topic: topic)
            self.articles = news
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
} 
