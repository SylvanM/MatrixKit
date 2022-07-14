//
//  Matrix+Collection.swift
//  
//
//  Created by Sylvan Martin on 7/14/22.
//

import Foundation

extension Matrix: Collection {
    
    // MARK: Iterating
    
    public func makeIterator() -> IndexingIterator<[Element]> {
        flatmap.makeIterator()
    }
    
    // MARK: Indexing
    
    public typealias Index = Int
    
    public var startIndex: Int {
        flatmap.startIndex
    }
    
    public var endIndex: Int {
        flatmap.endIndex
    }
    
    public func index(after i: Int) -> Int {
        flatmap.index(after: i)
    }
    
    // MARK: Subscripts
    
    public subscript(position: Int) -> Double {
        get {
            flatmap[position]
        }
        set {
            flatmap[position] = newValue
        }
    }
    
    // MARK: Collection Utility
    
    public func allSatisfy(_ predicate: (Double) throws -> Bool) rethrows -> Bool {
        try flatmap.allSatisfy(predicate)
    }
    
    /**
     * Calls a closure for each element of the matrix, in order from left to right, top to bottom,
     */
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try flatmap.forEach(body)
    }
    
}
