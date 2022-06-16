//
//  MatrixInterface.swift
//  
//
//  Created by Sylvan Martin on 6/15/22.
//

import Foundation

/**
 * The ideal interface for what a client should see when using `MatrixKit`. This is an internal type,
 * as I am only using it to plan out what operations should be seen. In the end, this file will be deleted.
 *
 * Because this is only internal, there will not be formal documentation other than what will just help me.
 */
internal protocol MatrixInterface: CustomStringConvertible, ExpressibleByArrayLiteral, Equatable {
    
    // MARK: - Properties
    
    var colCount: Int { get }
    
    var rowCount: Int { get }
    
    /**
     * Total number of elements in matrix
     */
    var count: Int { get }
    
    // MARK: - Subscripts
    
    /**
     * Accesses a specific row of this matrix
     */
    subscript(row row: Int) -> [Matrix.Element] { get set }
    
    /**
     * Accesses a specific column of this matrix
     */
    subscript(col col: Int) -> [Matrix.Element] { get set }
    
    /**
     * Accesses a specific column of this matrix
     */
    subscript(col: Int) -> [Matrix.Element] { get set }
    
    /**
     * Accesses the element in the `row`th row and `col`th column
     */
    subscript(row: Int, col: Int) -> Matrix.Element { get set }
    
    // MARK: - Initializers
    
    init(_ array: [[Matrix.Element]])
    
    init(rows: Int, cols: Int)
    
    init(flatmap: [Matrix.Element], cols: Int)
    
    // MARK: - Computed properties
    
    var determinant: Double { get }
    
    var rank: Int { get }
    
    var rowEchelon: Matrix { get }
    
    var reducedRowEchelon: Matrix { get }
    
    var rows: [[Matrix.Element]] { get }
    
    var columns: [[Matrix.Element]] { get }
    
    // MARK: - Utility
    
    mutating func applyToAll(_ closure: (inout Matrix.Element) -> ())
    
    func applyingToAll(_ closure: (Matrix.Element) -> Matrix.Element) -> Matrix
    
    func omitting(col: Int) -> Matrix
    
    func omitting(row: Int) -> Matrix
    
    // MARK: - Matrix Math
    
    func isRowEquivalent(to: Matrix) -> Bool
    
    mutating func apply(rowOperation: Matrix.ElementaryOperation)
    
    mutating func apply(columnOperation: Matrix.ElementaryOperation)
    
    func applying(rowOperation: Matrix.ElementaryOperation) -> Matrix
    
    func applying(columnOperation: Matrix.ElementaryOperation) -> Matrix
    
    mutating func scale(by: Double)
    
    func scaled(by: Double) -> Matrix
    
    mutating func add(_: Matrix)
    
    func sum(adding: Matrix) -> Matrix
    
    func leftMultiply(by: Matrix) -> Matrix
    
    func rightMultiply(onto: Matrix) -> Matrix
    
}
