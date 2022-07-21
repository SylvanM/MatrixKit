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
    
    // MARK: - Subscripts
    
    /**
     * Accesses the row at `row`
     */
    public subscript(row row: Int) -> [Element] {
        get { Array(self[rowSlice: row]) }
        set { self[rowSlice: row] = ArraySlice(newValue) }
    }
    
    /**
     * Accesses the row at `row` as an `ArraySlice`
     */
    public subscript(rowSlice row: Int) -> ArraySlice<Element> {
        get { flatmap[(row * colCount)..<(colCount * (row + 1))] }
        set { flatmap[(colCount * row)..<(colCount * (row + 1))] = newValue }
    }
    
    /**
     * Accesses the entry at row `row` and column `col`
     */
    public subscript(row: Int, col: Int) -> Element {
        get { self.flatmap[row * colCount + col] }
        set { self.flatmap[row * colCount + col] = newValue }
    }
    
    /**
     * Accesses the column at `col`
     */
    public subscript(col col: Int) -> [Element] {
        get {
            var cols = [Element](repeating: 0, count: rowCount)
            for i in 0..<rowCount {
                cols[i] = self[i, col]
            }
            return cols
        }
        set {
            for i in 0..<rowCount {
                self[i, col] = newValue[i]
            }
        }
    }
    
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
