//
//  Matrix+Operations.swift
//  
//
//  Created by Sylvan Martin on 6/15/22.
//

import Foundation
import Accelerate

public extension Matrix {
    
    // MARK: - Comparisons
    
    /**
     * Returns `true` if this matrix is equivalent to another matrix.
     */
    func equals(_ other: Matrix) -> Bool {
        self.colCount == other.colCount && self.flatmap == other.flatmap
    }
    
    /**
     * Returns `true` if `other` can be obtained by applying row operations to `self`
     */
    func isRowEquivalent(to other: Matrix) -> Bool {
        self.rank == other.rank
    }
    
    // MARK: Matrix Operations
    
    /**
     * Scales every element of this matrix by a scalar, in place.
     *
     * - Parameter scalar: `Double` by which to scale every element of this matrix.
     */
    mutating func scale(by scalar: Double) {
//        var scalar_p = scalar
//        vDSP_vsmulD(bufferPointer.baseAddress!, 1, &scalar_p, bufferPointer.baseAddress!, 1, vDSP_Length(flatmap.count))
        
        for i in 0..<flatmap.count {
            flatmap[i] *= scalar
        }
    }
    
    /**
     * The result of scaling this matrix by a scalar, out of place.
     *
     * - Parameter scalar: `Double` by which to scale every element of this matrix
     * - Returns: The result of scaling this matrix by a scalar.
     */
    func scaled(by scalar: Double) -> Matrix {
        var new = self
        new.scale(by: scalar)
        return new
    }
    
    /**
     * Adds every element of another matrix to the corresponding element of this matrix, in place.
     *
     * - Precondition: `self.rowCount == other.rowCount && self.colCount == other.colCount`
     * - Parameter other: `Matrix` to add.
     */
    mutating func add(_ other: Matrix) {
        for i in 0..<flatmap.count {
            flatmap[i] += other.flatmap[i]
        }
    }
    
    /**
     * Subtracts every element of another matrix to the corresponding element of this matrix, in place.
     *
     * - Precondition: `self.rowCount == other.rowCount && self.colCount == other.colCount`
     * - Parameter other: `Matrix` to subtract.
     */
    mutating func subtract(_ other: Matrix) {
        for i in 0..<flatmap.count {
            flatmap[i] -= other.flatmap[i]
        }
    }
    
    /**
     * Subtracts the values of another matrix from this matrix, out of place
     *
     * - Precondition: `self.colCount == other.colCount && self.rowCount == other.rowCount`
     * - Parameter other: `Matrix` to subtract.
     * - Returns: The difference of this matrix and `other`.
     */
    func difference(subtracting other: Matrix) -> Matrix {
        if #available(macOS 10.15, *) {
            let diff = vDSP.subtract(self.flatmap, other.flatmap)
            return Matrix(flatmap: diff, cols: colCount)
        } else {
            let sum = zip(self.flatmap, other.flatmap).map { (x, y) in
                x - y
            }
            return Matrix(flatmap: sum, cols: self.colCount)
        }
    }
    
    /**
     * Adds the values of another matrix to this matrix, out of place.
     *
     * - Precondition: `self.colCount == other.colCount && self.rowCount == other.rowCount`
     * - Parameter other: `Matrix` to add
     * - Returns: The sum of `self` and `other`.
     */
    func sum(adding other: Matrix) -> Matrix {
        if #available(macOS 10.15, *) {
            let sum = vDSP.add(self.flatmap, other.flatmap)
            return Matrix(flatmap: sum, cols: self.colCount)
        } else {
            let sum = zip(self.flatmap, other.flatmap).map { (x, y) in
                x + y
            }
            return Matrix(flatmap: sum, cols: self.colCount)
        }
    }
    
    /**
     * Multiplies this matrix by another matrix on the left.
     *
     * This performs the matrix multiplication `lhs * self`.
     *
     * - Precondition: `lhs.colCount == self.rowCount`
     *
     * - Parameter lhs: `Matrix` by which to multiply
     * - Returns: The matrix product `lhs * self`
     */
    func leftMultiply(by lhs: Matrix) -> Matrix {
        
        // this is LUDICROUSLY slow and is ONLY temporary
        
        var product = Matrix(rows: lhs.rowCount, cols: self.colCount)
        
        for i in 0..<product.rowCount {
            for j in 0..<product.colCount {
                
                var sum: Double = 0
                
                for k in 0..<lhs.colCount {
                    sum += lhs[i, k] * self[k, j]
                }
                
                product[i, j] = sum
                
            }
        }
        
        return product
    }
    
    /**
     * Multiplies this another by this matrix.
     *
     * This performs the matrix multiplication `self * rhs`.
     *
     * - Precondition: `self.colCount == rhs.rowCount`
     *
     * - Parameter rhs: `Matrix` to multiply by `self`
     * - Returns: The matrix product `self * rhs`
     */
    func rightMultiply(onto rhs: Matrix) -> Matrix {
        rhs.leftMultiply(by: self)
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
        case .scale(let row, let scalar_c):
            
            for i in 0..<colCount {
                self[row, i] *= scalar_c
            }
            
        case .swap(let rowA, let rowB):
            
            let tempRow = self[rowA]
            self[rowA] = self[rowB]
            self[rowB] = tempRow

        case .add(let scalar, let index, let toIndex):
            
            for i in 0..<colCount {
                self[toIndex, i] += scalar * self[index, i]
            }
            
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
            
            for i in 0..<rowCount {
                self[i, col] *= scalar
            }
            
        case .swap(let colA, let colB):
            
            let tempCol = self[col: colA]
            self[col: colA] = self[col: colB]
            self[col: colB] = tempCol
            
        case .add(let scalar, let index, let toIndex):
            
            for i in 0..<rowCount {
                self[i, toIndex] += scalar * self[i, index]
            }
            
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
    
}
