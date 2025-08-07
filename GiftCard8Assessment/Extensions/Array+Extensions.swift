//
//  Array+Extensions.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import Foundation

/// Extension providing utility methods for Array collections.
///
/// This extension adds functionality for removing duplicate elements
/// from arrays based on custom key extraction, which is particularly
/// useful for deduplicating news articles or other complex objects.
extension Array {
    /// Returns a new array with duplicate elements removed based on a key extraction function.
    ///
    /// This method preserves the order of elements, keeping the first occurrence
    /// of each unique key and removing subsequent duplicates. It's particularly
    /// useful for deduplicating arrays of complex objects where uniqueness
    /// is determined by a specific property.
    ///
    /// ## Example Usage
    /// ```swift
    /// let articles = [article1, article2, article3, article1] // article1 appears twice
    /// let uniqueArticles = articles.uniqued(by: { $0.id })
    /// // Returns [article1, article2, article3] - first occurrence preserved
    /// ```
    ///
    /// - Parameter key: A closure that extracts a hashable key from each element
    /// - Returns: A new array containing only unique elements based on the extracted keys
    /// - Complexity: O(n) where n is the number of elements in the array
    func uniqued<T: Hashable>(by key: (Element) -> T) -> [Element] {
        var seen = Set<T>()
        return filter { element in
            // insert returns a tuple: (inserted: Bool, memberAfterInsert: T)
            // inserted is true if the element was not already in the set
            seen.insert(key(element)).inserted
        }
    }
}