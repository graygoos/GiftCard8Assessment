import Foundation
import CoreLocation
import Combine

/// A service class that manages location permissions and provides country code information.
///
/// This class handles the complex process of requesting location permissions,
/// obtaining the user's current location, and converting it to a country code
/// for location-based news filtering. It follows iOS best practices for location
/// handling and provides appropriate fallbacks when location access is denied.
///
/// ## Key Features
/// - Automatic permission request handling
/// - Country code extraction from location data
/// - Error handling for denied permissions
/// - Observable properties for SwiftUI integration
/// - Appropriate accuracy settings for news purposes
///
/// ## Usage
/// ```swift
/// let locationManager = LocationManager()
/// 
/// // Observe country code changes
/// locationManager.$countryCode
///     .sink { countryCode in
///         // Handle country code updates
///     }
/// ```
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    /// Core Location manager instance for handling location requests
    private let locationManager = CLLocationManager()
    
    /// Published country code (lowercase ISO format) for reactive UI updates
    @Published var countryCode: String? = nil
    
    /// Published error state for handling location-related failures
    @Published var locationError: Error? = nil
    
    /// Initializes the location manager with appropriate settings and starts permission request.
    override init() {
        super.init()
        locationManager.delegate = self
        // Use approximate accuracy since we only need country-level information
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        requestLocationPermission()
    }
    
    /// Requests location permission and initiates location detection based on current authorization status.
    ///
    /// This method handles different authorization states appropriately:
    /// - Requests permission if not yet determined
    /// - Starts location detection if already authorized
    /// - Sets error state if permission is denied (triggers fallback behavior)
    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            // First time - request permission
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission granted - get location
            locationManager.requestLocation()
        case .denied, .restricted:
            // Permission denied - set error to trigger fallback to device region
            DispatchQueue.main.async {
                self.locationError = CLError(.denied)
            }
        @unknown default:
            break
        }
    }
    
    /// Handles changes in location authorization status.
    ///
    /// This delegate method is called whenever the user changes location permissions
    /// in Settings or responds to the initial permission request.
    ///
    /// - Parameter manager: The location manager reporting the authorization change
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission granted - start location detection
            manager.requestLocation()
        case .denied, .restricted:
            // Permission denied - trigger fallback behavior
            DispatchQueue.main.async {
                self.locationError = CLError(.denied)
            }
        default:
            break
        }
    }
    
    /// Processes successful location updates and extracts country information.
    ///
    /// This delegate method receives location data and performs reverse geocoding
    /// to convert coordinates into a country code. The country code is then
    /// published for use by location-aware features.
    ///
    /// - Parameters:
    ///   - manager: The location manager providing the update
    ///   - locations: Array of location objects (we use the most recent)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        // Perform reverse geocoding to get country information
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                // Geocoding failed - set error state
                DispatchQueue.main.async {
                    self?.locationError = error
                }
                return
            }
            
            // Extract country code from placemark data
            if let country = placemarks?.first?.isoCountryCode {
                DispatchQueue.main.async {
                    // Convert to lowercase for API consistency
                    self?.countryCode = country.lowercased()
                }
            }
        }
    }
    
    /// Handles location detection failures.
    ///
    /// This delegate method is called when location detection fails due to
    /// various reasons such as network issues, GPS unavailability, or timeout.
    /// The error is published to allow appropriate fallback behavior.
    ///
    /// - Parameters:
    ///   - manager: The location manager reporting the failure
    ///   - error: The error that occurred during location detection
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = error
        }
    }
} 