import Foundation
import Combine

/// View model for the Location tab that manages location-based news content.
///
/// This complex view model handles the intricate process of obtaining user location,
/// fetching location-specific news, and providing appropriate fallbacks when
/// location services are unavailable. It integrates multiple services and
/// implements sophisticated error handling strategies.
///
/// ## Key Features
/// - Automatic location detection with device region fallback
/// - Multiple API strategy attempts for robust news fetching
/// - Real-time location status updates for user feedback
/// - Comprehensive caching integration
/// - Reactive programming with Combine for location updates
/// - Main actor isolation for UI thread safety
///
/// ## Location Strategy
/// 1. Attempts to get precise location via CoreLocation
/// 2. Falls back to device region settings if location denied
/// 3. Tries multiple news API strategies if country-specific news unavailable
/// 4. Uses global news as final fallback
///
/// ## Usage
/// ```swift
/// @StateObject private var viewModel = LocationViewModel()
/// 
/// // Automatically starts location detection on init
/// // Observe location status and articles for UI updates
/// ```
@MainActor
class LocationViewModel: ObservableObject {
    /// Array of location-based news articles for display
    @Published var articles: [News] = []
    
    /// Loading state indicator for progress views
    @Published var isLoading: Bool = false
    
    /// Error message for display when news fetching fails
    @Published var errorMessage: String? = nil
    
    /// Current country code (lowercase ISO format) for API requests
    @Published var countryCode: String? = nil
    
    /// Current news topic being displayed
    @Published var topic: String = "general"
    
    /// Human-readable location status for user feedback
    @Published var locationStatus: String = "Detecting location..."
    
    /// Set of Combine cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Location manager instance for handling location services
    private let locationManager = LocationManager()
    
    /// Initializes the location view model with immediate fallback and location detection.
    ///
    /// The initialization strategy provides immediate content while attempting
    /// to get more accurate location data:
    /// 1. Sets up reactive location observers
    /// 2. Uses device region as immediate fallback
    /// 3. Starts loading news with device region
    /// 4. Initiates precise location detection in parallel
    init() {
        setupLocationObserver()
        
        // Provide immediate fallback using device region settings
        if let code = Locale.current.region?.identifier.lowercased() {
            self.countryCode = code
            self.locationStatus = "Using device region: \(code.uppercased())"
            
            // Load news immediately with device region for faster UX
            Task {
                await fetchNewsWithFallback(for: code)
            }
        }
        
        // Start location detection for more accurate location data
        requestLocationBasedNews()
    }
    
    /// Sets up reactive observers for location manager updates.
    ///
    /// This method establishes Combine subscriptions to monitor location changes
    /// and errors, ensuring the UI stays synchronized with location state changes.
    /// It handles both successful location detection and error scenarios with
    /// appropriate fallback strategies.
    private func setupLocationObserver() {
        // Observe successful location updates
        locationManager.$countryCode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countryCode in
                if let countryCode = countryCode {
                    self?.countryCode = countryCode
                    self?.locationStatus = "Location detected: \(countryCode.uppercased())"
                    
                    // Fetch news with the more accurate location data
                    Task {
                        await self?.fetchNewsWithFallback(for: countryCode)
                    }
                }
            }
            .store(in: &cancellables)
        
        // Observe location errors and implement fallback strategy
        locationManager.$locationError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if error != nil {
                    // Attempt fallback to device region settings
                    if let code = Locale.current.region?.identifier.lowercased() {
                        self?.countryCode = code
                        self?.locationStatus = "Using device region: \(code.uppercased())"
                        Task {
                            await self?.fetchNewsWithFallback(for: code)
                        }
                    } else {
                        // Complete fallback failure
                        self?.errorMessage = "Could not determine location or device region."
                        self?.locationStatus = "Location unavailable"
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    /// Initiates location-based news fetching process.
    ///
    /// This method coordinates the location detection and news fetching process,
    /// handling both immediate content loading (if location is already available)
    /// and progressive enhancement as more accurate location data becomes available.
    func requestLocationBasedNews() {
        // Start location detection process
        locationManager.requestLocationPermission()
        
        // If we already have a country code, fetch news immediately
        if let countryCode = countryCode {
            Task {
                await fetchNewsWithFallback(for: countryCode)
            }
        } else {
            // Set loading state while waiting for location detection
            isLoading = true
            locationStatus = "Detecting location..."
        }
    }
    
    /// Fetches location-based news with comprehensive fallback strategies.
    ///
    /// This method implements a sophisticated multi-tier approach to ensure users
    /// always receive relevant content, even when location-specific news is unavailable:
    ///
    /// 1. **Cache Check**: Returns cached data if available and fresh
    /// 2. **Multiple API Strategies**: Tries different topic combinations for the country
    /// 3. **Global Fallback**: Uses worldwide news if country-specific content fails
    /// 4. **Error Handling**: Provides user-friendly error messages for complete failures
    ///
    /// - Parameter country: ISO country code for location-specific news
    func fetchNewsWithFallback(for country: String) async {
        isLoading = true
        errorMessage = nil
        
        // Check cache first for improved performance
        let cacheKey = "location_\(country)"
        if let cachedNews = CacheService.shared.getCachedNews(for: cacheKey) {
            self.articles = cachedNews
            self.isLoading = false
            print("[DEBUG] Using cached news for \(country)")
            return
        }
        
        // Define multiple API strategies to maximize success rate
        let strategies: [(topic: String?, description: String)] = [
            (nil, "general headlines"),
            ("general", "general news"),
            ("world", "world news"),
            ("breaking-news", "breaking news"),
            ("nation", "national news")
        ]
        
        // Try each strategy until we find content
        for strategy in strategies {
            do {
                let news = try await NewsAPIService.shared.fetchNewsByCountry(country, topic: strategy.topic)
                if !news.isEmpty {
                    self.articles = news
                    self.topic = strategy.topic ?? "headlines"
                    self.isLoading = false
                    
                    // Cache successful results
                    CacheService.shared.cacheNews(news, for: cacheKey)
                    
                    print("[DEBUG] Found \(news.count) articles for \(country) with \(strategy.description)")
                    return
                }
            } catch {
                print("[DEBUG] Error fetching \(strategy.description) for \(country): \(error)")
                continue
            }
        }
        
        // Final fallback: use global news if country-specific content unavailable
        do {
            let globalNews = try await NewsAPIService.shared.fetchGlobalNews()
            if !globalNews.isEmpty {
                self.articles = Array(globalNews.prefix(10)) // Limit to 10 articles for consistency
                self.topic = "global"
                self.locationStatus = "Showing global news (local news unavailable)"
                self.isLoading = false
                
                // Cache the fallback results
                CacheService.shared.cacheNews(self.articles, for: cacheKey)
                
                print("[DEBUG] Using global news as fallback")
                return
            }
        } catch {
            print("[DEBUG] Error fetching global news as fallback: \(error)")
        }
        
        // Complete failure - show user-friendly error message
        self.errorMessage = "Unable to load news at this time. Please check your internet connection and try again."
        self.isLoading = false
    }
    
    /// Fetches news for a specific country and topic without fallback strategies.
    ///
    /// This method provides a simpler, direct API call for specific use cases
    /// where fallback behavior is not desired. It's primarily used for manual
    /// refresh operations or when the caller wants to handle failures directly.
    ///
    /// - Parameters:
    ///   - country: ISO country code for the target region
    ///   - topic: News topic/category (defaults to "general")
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
