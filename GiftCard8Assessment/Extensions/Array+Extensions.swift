//
//  Array+Extensions.swift
//  GiftCard8Assessment
//
//  Created by Femi Aliu on 06/08/2025.
//

import Foundation

extension Array {
    func uniqued<T: Hashable>(by key: (Element) -> T) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert(key($0)).inserted }
    }
}