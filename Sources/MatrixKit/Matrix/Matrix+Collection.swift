//
//  Matrix+Collection.swift
//  
//
//  Created by Sylvan Martin on 7/14/22.
//

import Foundation
import Accelerate

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
            var cols = [Element](repeating: .zero, count: rowCount)
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
    
    /**
     * Accesses the item in the flatmap at position  `position`
     */
    public subscript(position: Int) -> Element {
        get { flatmap[position] }
        set { flatmap[position] = newValue }
    }
    
    /**
     * Accesses a submatrix of this matrix by value
     */
    public subscript(rows rows: Range<Int>, cols cols: Range<Int>) -> Matrix {
        get {
            assert(rows.allSatisfy { $0 < rowCount }, "Row slice index out of bounds")
            assert(cols.allSatisfy { $0 < colCount }, "Column slice index out of bounds")
            
            var submatrix = Matrix(rows: rows.count, cols: cols.count)
            
            for r in rows {
                for c in cols {
                    submatrix[r - rows.lowerBound, c - cols.lowerBound] = self[r, c]
                }
            }
            
            return submatrix
            
        }
        set {
            assert(rows.allSatisfy { $0 < rowCount }, "Row slice index out of bounds")
            assert(cols.allSatisfy { $0 < colCount }, "Column slice index out of bounds")
            
            assert(rows.count == newValue.rowCount, "Dimensions of assigned matrix must be equal")
            assert(cols.count == newValue.colCount, "Dimensions of assigned matrix must be equal")
            
            for r in rows {
                for c in cols {
                    self[r, c] = newValue[r - rows.lowerBound, c - cols.lowerBound]
                }
            }
        }
    }
    
    /**
     * Accesses a sub-matrix of this matrix by value
     */
    public subscript(rows: Range<Int>, cols: Range<Int>) -> Matrix {
        get { self[rows: rows, cols: cols] }
        set { self[rows: rows, cols: cols] = newValue }
    }
    
    /**
     * Accesses a row of this matrix
     */
    public subscript(row row: Int) -> Matrix {
        self[rows: row..<(row + 1), cols: 0..<colCount]
    }
    
    /**
     * Accesses a column of this matrix
     */
    public subscript(col col: Int) -> Matrix {
        self[rows: 0..<rowCount, cols: col..<(col + 1)]
    }
    
    // MARK: Collection Utility
    
    public func allSatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        try flatmap.allSatisfy(predicate)
    }
    
    /**
     * Calls a closure for each element of the matrix, in order from left to right, top to bottom,
     */
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try flatmap.forEach(body)
    }
    
}
