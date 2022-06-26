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
public struct Matrix: CustomStringConvertible, ExpressibleByArrayLiteral, Equatable {
    
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
     * The mutable buffer pointer to the flat map of elements
     */
    internal var immutableBufferPointer: UnsafeBufferPointer<Double> {
        flatmap.withUnsafeBufferPointer { $0 }
    }
    
    /**
     * The pointer to the base address of the flatmap array
     */
    internal var immutableBaseAddress: UnsafePointer<Double> {
        immutableBufferPointer.baseAddress!
    }
    
    /**
     * The immutable buffer pointer to the flat map of elements
     */
    internal var mutableBufferPointer: UnsafeMutableBufferPointer<Double> {
        UnsafeMutableBufferPointer(mutating: immutableBufferPointer)
    }
    
    /**
     * The mutable buffer pointer to the base address of the flatmap array
     */
    internal var mutableBaseAddress: UnsafeMutablePointer<Double> {
        UnsafeMutablePointer(mutating: immutableBaseAddress)
    }
    
    // MARK: Public Properties
    
    /**
     * The amount of columns in this matrix
     */
    public let colCount: Int
    
    /**
     * The amount of rows in this matrix
     */
    public let rowCount: Int
    
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
     * Creates a matrix filled of specified dimensions filled with zeros
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
     * Creates a matrix from an array of rows
     */
    public init(rowArray rows: [[Element]]) {
        self.init(rows)
    }
    
    /**
     * Creates a matrix from another matrix
     */
    public init(_ other: Matrix) {
        self.flatmap = other.flatmap
        self.rowCount = other.rowCount
        self.colCount = other.colCount
    }
    
    /**
     * Creates a matrix with one row of elements
     */
    public init(_ row: [Element]) {
        self.flatmap = row
        self.rowCount = 1
        self.colCount = row.count
    }
    
    /**
     * Creates a matrix with one column from a vector
     */
    public init(vector: [Element]) {
        self.flatmap = vector
        self.rowCount = vector.count
        self.colCount = 1
    }
    
    /**
     * Creates a matrix from an array of columns
     */
    public init(colArray cols: [[Element]]) {
        var m = Matrix(rows: cols.first!.count, cols: cols.count)
        for c in 0..<m.colCount {
            for r in 0..<m.rowCount {
                m[r, c] = cols[c][r]
            }
        }
        self.init(m)
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
    
    public static func identity(forDim dim: Int) -> Matrix {
        var iden = Matrix(rows: dim, cols: dim)
        for i in 0..<dim {
            iden[i, i] = 1
        }
        return iden
    }
    
    // MARK: Computed Properties
    
    /**
     * Whether or not this is a square matrix
     */
    public var isSquare: Bool {
        rowCount == colCount
    }
    
    public var description: String {
        makePrettyString()
    }
    
    /**
     * The LaTeX code that will display this matrix
     */
    public var latexString: String {
        makeLatexString()
    }
    
    /**
     * A raw string representing the matrix, delimited only by spaces and newlines
     */
    public var rawString: String {
        makeRawString()
    }
    
    /**
     * The total number of entries in this matrix
     */
    public var count: Int {
        flatmap.count
    }
    
    /**
     * This matrix in rowwise array form
     */
    public var rows: [[Element]] {
        let rowPattern = [[Element]](repeating: [Element](repeating: 0, count: colCount), count: rowCount)
        return flatmap.overlay(onto: rowPattern)
    }
    
    /**
     * This matrix in column-wise array form
     */
    public var columns: [[Element]] {
        var colArray = [[Element]](repeating: [Element](repeating: 0, count: rowCount), count: colCount)
        
        for i in 0..<colCount {
            colArray[i] = self[col: i]
        }
        
        return colArray
    }
    
    // MARK: - Subscripts
    
    /**
     * Accesses the row at `row`
     *
     * This is equivalent to `self[row: row]`
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
        set { flatmap[(colCount * row)..<(colCount * (row + 1))] = ArraySlice(newValue) }
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
    
    // MARK: Enumerations
    
    /**
     * A row or column operation to be applied to a matrix.
     */
    public enum ElementaryOperation {
        
        /**
         * The operation of scaling a row or column (given by its index) by a constant scalar
         */
        case scale(index: Int, by: Double)
        
        /**
         * The operation of switching two rows (or columns), given by their indices
         */
        case swap(Int, Int)
        
        /**
         * The operation of adding the row (column) at index `index` to the row (column) at index `toIndex`, after
         * first being scaled by `scalar`.
         *
         * For example, the row operation `.add(scalar: 5, index: 2, toIndex 1)`, when applied
         * to the matrix:
         * ```
         * ┌ 0.0  2.0  3.0  5.0 ┐
         * │ 1.0  1.0  6.0  7.0 │
         * └ 0.0  0.0  0.0  2.0 ┘
         * ```
         * should yield the matrix
         * ```
         * ┌ 0.0  2.0  3.0  5.0  ┐
         * │ 1.0  1.0  6.0  17.0 │
         * └ 0.0  0.0  0.0  2.0  ┘
         * ```
         */
        case add(scalar: Double, index: Int, toIndex: Int)
        
    }
    
}
