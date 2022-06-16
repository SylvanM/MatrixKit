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
    
    // MARK: - Initializers

    /**
     * Creates a matrix from an array of rows
     *
     * - Parameter array: A 2D array of the elements of the matrix
     *
     * - Precondition: `array` is not empty, and `array.isRectangular`
     */
    public init(_ array: [[Element]]) {
        flatmap = Array(array.joined())
        colCount = array.first!.count
        rowCount = flatmap.count / colCount
    }

    /**
     * Creates an empty matrix with specified dimension
     */
    public init(rows: Int, cols: Int) {
        flatmap = [Element](repeating: 0, count: rows * cols)
        rowCount = rows
        colCount = cols
    }

    public init(arrayLiteral elements: [Element]...) {
        self.init(elements)
    }

    /**
     * Creates a matrix from a one dimensional array of rows, back to back.
     *
     * - Parameter flatmap: An array of the elements of the matrix, from left to right across each row.
     * - Parameter cols: The number of columns in this matrix
     *
     * - Precondition: `flatmap.count % cols == 0`
     */
    public init(flatmap: [Matrix.Element], cols: Int) {
        self.flatmap = flatmap
        self.colCount = cols
        self.rowCount = flatmap.count / cols
    }
    
    // MARK: Static Producers
    
    static func identity(forDim dim: Int) -> Matrix {
        let iden = Matrix(rows: dim, cols: dim)
        for i in 0..<dim {
            iden[i, i]
        }
        return iden
    }
    
    // MARK: - Properties
    
    /**
     * A flattened, one dimensional representation of this matrix, row-wise.
     */
    internal var flatmap: [Element]
    
    /**
     * The buffer pointer to the flat map of elements
     */
    internal lazy var bufferPointer = flatmap.withUnsafeMutableBufferPointer { $0 }
    
    // MARK: Public Properties
    
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
