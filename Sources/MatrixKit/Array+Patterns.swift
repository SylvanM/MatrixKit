//
//  Array+Patterns.swift
//  
//
//  Created by Sylvan Martin on 6/15/22.
//

import Foundation

public extension Array {
    
    /**
     * Overlays the contents of this 1D matrix with a 2D array "pattern".
     *
     * For example, `[0, 1, 2, 3].overlay([[0], [0, 0], [0]])` returns `[[0], [1, 2], [3]]`
     *
     * This code was inspired by this stackoverflow post: https://stackoverflow.com/a/59824076
     *
     * - Precondition: `self.count` is equal to the total number of elements in `array`
     */
    func overlay<T>(onto pattern: [[T]]) -> [[Element]] {
        var iter = makeIterator()
        return pattern.map { $0.compactMap { _ in iter.next() } }
    }
    
}
