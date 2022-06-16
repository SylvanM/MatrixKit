//
//  File.swift
//  
//
//  Created by Sylvan Martin on 6/15/22.
//

import Foundation

/**
 * A matrix
 */
public struct Matrix: MatrixInterface {
    
    // MARK: - Typealiases
    
    /**
     * The element of this matrix, equivalent to `Double`.
     */
    public typealias Element = Double
    
    public typealias ArrayLiteralElement = [Element]
    
    // MARK: - Properties
    
    /**
     * A flattened, one dimensional representation of this matrix, row-wise.
     */
    internal var flatmap: [Element]
    
    /**
     * The buffer pointer to the flat map of elements
     */
    internal lazy var bufferPointer = flatmap.withUnsafeMutableBufferPointer { $0 }
    
    /**
     * The amount of columns in this matrix
     */
    public let colCount: Int
    
    /**
     * The amount of rows in this matrix
     */
    public let rowCount: Int
    
    // MARK: Computed Properties
    
    public var description: String {
        makeStringDescription()
    }
    
    public var count: Int {
        flatmap.count
    }
    
    /**
     * This matrix in rowwise array form
     */
    public var rows: [[Element]] {
        let rowPattern = [[Element]](repeating: [Element](repeating: 0, count: rowCount), count: colCount)
        return flatmap.overlay(onto: rowPattern)
    }
    
    /**
     * This matrix in column-wise array form
     */
    public var columns: [[Element]] {
        var colArray = [[Element]](repeating: [Element](repeating: 0, count: colCount), count: rowCount)
        
        for i in 0..<colCount {
            colArray[i] = self[col: i]
        }
        
        return colArray
    }
    
    // MARK: - Subscripts
    
    /**
     * Accesses the row at `row`
     */
    public subscript(row: Int) -> [Element] {
        get { self[row: row] }
        set { self[row: row] = newValue }
    }
    
    /**
     * Accesses the row at `row`
     */
    public subscript(row row: Int) -> [Element] {
        get { Array(flatmap[(row * colCount)..<(colCount * (row + 1))]) }
        set { flatmap[row..<(colCount * (row + 1))] = ArraySlice(newValue) }
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
                cols[i] = flatmap[i * rowCount + col]
            }
            return cols
        }
        set {
            for i in 0..<rowCount {
                flatmap[i * rowCount + col] = newValue[i]
            }
        }
    }
    
    // MARK: Enumerations
    
    public enum ElementaryOperation {
        case scale(Int, Double)
        case swap(Int, Int)
        case add(scalar: Double, index: Int, toIndex: Int)
    }
    
}
