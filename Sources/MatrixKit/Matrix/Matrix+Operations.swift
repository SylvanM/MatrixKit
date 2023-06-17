//
//  Matrix+Operations.swift
//  
//
//  Created by Sylvan Martin on 6/15/22.
//

import Foundation
import Accelerate
import simd

public extension Matrix {
    
    // MARK: Advanced Operations
    
    /**
     * Raises a square matrix `self` to an integer power `p`
     *
     * - Precondition: `self.isSquare && p >= 0`
     *
     * - Returns: `self` raised to `p`
     */
    func pow(_ p: Int) -> Matrix {
        // TODO: Make this WAYYY better, this is a very temporary solution
        if p == 0 {
            return Matrix.identity(forDim: self.rowCount)
        }
        
        return self * self.pow(p - 1)
    }
    
    /**
     * Returns `true` if this matrix has the same dimensions as another matrix
     */
    @inlinable
    func hasSameDimensions(as other: Matrix) -> Bool {
        self.rowCount == other.rowCount && self.colCount == other.colCount
    }
    
    /**
     * Computes the element-wise Hadamard product
     *
     * - Parameter other: Another matrix (vector) to compute the hadamard product with this one
     *
     * - Precondition: `self.rowCount == other.rowCount && self.colCount == other.colCount`
     *
     * - Returns: A new matrix (vector) whos elements are the element wise products of the elements of `self` and `other`.
     */
    func hadamard(with other: Matrix) -> Matrix {
        assert(hasSameDimensions(as: other), "Cannot compute Hadamard with matrices of different dimensions")
        
        var product = Matrix(rows: self.rowCount, cols: self.colCount)
        
        for i in 0..<flatmap.count {
            product[i] = flatmap[i] * other[i]
        }
        
        return product
    }
    
    /**
     * Computes the dot product of two vector-like matrices, regardless of whether they are column-wise or not.
     */
    func dotProduct(with other: Matrix) -> Element {
        assert(self.rowCount == 1 || self.colCount == 1, "Must be a row or column vector")
        assert(other.rowCount == 1 || other.colCount == 1, "Must be a row or column vector")
        assert(self.flatmap.count == other.flatmap.count, "Must be vectors of same length")
        
        var dotProduct = Element.zero
        
        for i in 0..<flatmap.count {
            dotProduct += self.flatmap[i] * other.flatmap[i]
        }
        
        return dotProduct
    }
    
    // MARK: - Row Operations and Guassian Elimination
    
    /**
     * Applies a row operation on this matrix
     *
     * - Precondition: The affected indices in `rowOperation` are not out of bounds for this matrix
     *
     * - Parameter rowOperation: `ElementaryOperation` to perform as a row operation
     */
    mutating func apply(rowOperation: ElementaryOperation) {
        
        switch rowOperation {
            case .scale(let row, let scalar):
                assert(row < rowCount, "Row index out of bounds")
                scale(row: row, by: scalar)
            case .swap(let rowA, let rowB):
                assert(rowA < rowCount && rowB < rowCount, "Row index out of bounds")
                swap(row: rowA, with: rowB)
            case .add(let scalar, let row, let toRow):
                assert(row < rowCount, "Row index out of bounds")
                add(row: row, scaledBy: scalar, toRow: toRow)
        }
    }
    
    mutating func scale(row: Int, by scalar: Element) {
        for c in 0..<colCount {
            self[row, c] *= scalar
        }
    }
    
    mutating func swap(row rowA: Int, with rowB: Int) {
        for c in 0..<colCount {
            let temp = self[rowA, c]
            self[rowA, c] = self[rowB, c]
            self[rowB, c] = temp
        }
    }
    
    mutating func add(row: Int, scaledBy scalar: Element, toRow dest: Int) {
        for c in 0..<colCount {
            self[dest, c] += self[row, c] * scalar
        }
    }
    
    /**
     * Applies a column operation on this matrix
     *
     * - Precondition: The affected indices in `columnOperation` are not out of bounds for this matrix
     *
     * - Parameter columnOperation: `ElementaryOperation` to perform as a column operation
     */
    mutating func apply(columnOperation: ElementaryOperation) {
        switch columnOperation {
        case .scale(let col, let scalar):
            assert(col < colCount, "Column index out of bounds")
            scale(col: col, by: scalar)
        case .swap(let colA, let colB):
            assert(colA < colCount && colB < colCount, "Column index out of bounds")
            swap(col: colA, with: colB)
        case .add(let scalar, let col, let toCol):
            assert(col < colCount, "Column index out of bounds")
            add(col: col, scaledBy: scalar, toCol: toCol)
        }
    }
    
    mutating func scale(col: Int, by scalar: Element) {
        for r in 0..<rowCount {
            self[r, col] *= scalar
        }
    }
    
    mutating func swap(col colA: Int, with colB: Int) {
        for r in 0..<rowCount {
            let temp = self[r, colA]
            self[r, colA] = self[r, colB]
            self[r, colB] = temp
        }
    }
    
    mutating func add(col: Int, scaledBy scalar: Element, toCol dest: Int) {
        for r in 0..<rowCount {
            self[r, dest] += self[r, col] * scalar
        }
    }
    
    /**
     * Returns the result of applying a row operation on this matrix
     *
     * - Precondition: The affected indices in `rowOperation` are not out of bounds for this matrix
     *
     * - Parameter rowOperation: `ElementaryOperation` to perform as a row operation
     *
     * - Returns: The result of applying `rowOperation` to `self`
     */
    func applying(rowOperation: ElementaryOperation) -> Matrix {
        var new = self
        new.apply(rowOperation: rowOperation)
        return new
    }
    
    /**
     * Returns the result of applying a column operation on this matrix
     *
     * - Precondition: The affected indices in `colOperation` are not out of bounds for this matrix
     *
     * - Parameter colOperation: `ElementaryOperation` to perform as a col operation
     *
     * - Returns: The result of applying `colOperation` to `self`
     */
    func applying(columnOperation: ElementaryOperation) -> Matrix {
        var new = self
        new.apply(columnOperation: columnOperation)
        return new
    }
    
    // MARK: - Misc Operations
    
    /**
     * Sums accross the columns of this matrix to produce a column vector, whos elements are the sum of each row.
     */
    func rowSum() -> Matrix {
        var sum = Matrix(rows: rowCount, cols: 1)
        
        for r in 0..<rowCount {
            for c in 0..<colCount {
                sum[r, 0] += self[r, c]
            }
        }
        
        return sum
    }
    
}
