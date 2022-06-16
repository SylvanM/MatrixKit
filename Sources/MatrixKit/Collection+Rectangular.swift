//
//  Collection+Rectangular.swift
//  
//
//  Created by Sylvan Martin on 6/15/22.
//

import Foundation

public extension Collection where Self.Iterator.Element: RandomAccessCollection {
    
    /**
     * Checks if `self` is rectangular.
     *
     * Formally, there exists an unique `L` such that for all `i` in `0..<array.count`, `array[i].count = L`.
     *
     * In other words, all entries in this array are of the same length.
     */
    var isRectangular: Bool {
        guard !self.isEmpty                                         else { return false } // make sure the array of rows isn't empty
        guard  self.allSatisfy( { !$0.isEmpty } )                   else { return false } // make sure every row in the array isn't empty
        guard  self.allSatisfy( { $0.count == self.first!.count } ) else { return false } // make sure this is a rectangular matrix where all are the same length
        
        return true
    }
    
}
