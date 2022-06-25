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
        var scalar_p = scalar
        vDSP_vsmulD(baseAddress, 1, &scalar_p, baseAddress, 1, UInt(flatmap.count))
    }
    
    /**
     * The result of scaling this matrix by a scalar, out of place.
     *
     * - Parameter scalar: `Double` by which to scale every element of this matrix
     * - Returns: The result of scaling this matrix by a scalar.
     */
    func scaled(by scalar: Double) -> Matrix {
        let out = self
        var scalar_p = scalar
        vDSP_vsmulD(baseAddress, 1, &scalar_p, out.baseAddress, 1, UInt(flatmap.count))
        return out
    }
    
    /**
     * Adds every element of another matrix to the corresponding element of this matrix, in place.
     *
     * - Precondition: `self.rowCount == other.rowCount && self.colCount == other.colCount`
     * - Parameter other: `Matrix` to add.
     */
    mutating func add(_ other: Matrix) {
        vDSP_vaddD(baseAddress, 1, other.baseAddress, 1, baseAddress, 1, UInt(flatmap.count))
    }
    
    /**
     * Subtracts every element of another matrix to the corresponding element of this matrix, in place.
     *
     * - Precondition: `self.rowCount == other.rowCount && self.colCount == other.colCount`
     * - Parameter other: `Matrix` to subtract.
     */
    mutating func subtract(_ other: Matrix) {
        vDSP_vsubD(baseAddress, 1, other.baseAddress, 1, baseAddress, 1, UInt(flatmap.count))
    }
    
    /**
     * Subtracts the values of another matrix from this matrix, out of place
     *
     * - Precondition: `self.colCount == other.colCount && self.rowCount == other.rowCount`
     * - Parameter other: `Matrix` to subtract.
     * - Returns: The difference of this matrix and `other`.
     */
    func difference(subtracting other: Matrix) -> Matrix {
        let out = self
        vDSP_vsubD(baseAddress, 1, other.baseAddress, 1, out.baseAddress, 1, UInt(flatmap.count))
        return out
    }
    
    /**
     * Adds the values of another matrix to this matrix, out of place.
     *
     * - Precondition: `self.colCount == other.colCount && self.rowCount == other.rowCount`
     * - Parameter other: `Matrix` to add
     * - Returns: The sum of `self` and `other`.
     */
    func sum(adding other: Matrix) -> Matrix {
        let out = self
        vDSP_vaddD(baseAddress, 1, other.baseAddress, 1, out.baseAddress, 1, UInt(flatmap.count))
        return out
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
        let product = Matrix(rows: lhs.rowCount, cols: self.colCount)
        
        vDSP_mmulD(
            lhs.baseAddress,      1,
            self.baseAddress,     1,
            product.baseAddress,  1,
            UInt(lhs.rowCount), UInt(self.colCount), UInt(lhs.colCount)
        )
        
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
        let product = Matrix(rows: self.rowCount, cols: rhs.colCount)
        
        vDSP_mmulD(
            self.baseAddress,     1,
            rhs.baseAddress,      1,
            product.baseAddress,  1,
            UInt(self.rowCount), UInt(rhs.colCount), UInt(self.colCount)
        )
        
        return product
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
        case .scale(let row, var scalar):
            
            let rowPtr = baseAddress.advanced(by: row * colCount)
            
            vDSP_vsmulD(rowPtr, 1, &scalar, rowPtr, 1, UInt(colCount))
            
        case .swap(let rowA, let rowB):
            
            let rowAPtr = baseAddress.advanced(by: rowA * colCount)
            let rowBPtr = baseAddress.advanced(by: rowB * colCount)
            
            vDSP_vswapD(rowAPtr, 1, rowBPtr, 1, UInt(colCount))

        case .add(var scalar, let row, let toRow):
            
            let rowPtr   = baseAddress.advanced(by: row * colCount)
            let toRowPtr = baseAddress.advanced(by: toRow * colCount)
            
            vDSP_vsmaD(rowPtr, 1, &scalar, toRowPtr, 1, toRowPtr, 1, UInt(colCount))
            
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
        case .scale(let col, var scalar):
            
            let colPtr = baseAddress.advanced(by: col * rowCount)
            
            vDSP_vsmulD(colPtr, colCount, &scalar, colPtr, 1, UInt(rowCount))
            
        case .swap(let colA, let colB):
            
            let colAPtr = baseAddress.advanced(by: colA * rowCount)
            let colBPtr = baseAddress.advanced(by: colB * rowCount)
            
            vDSP_vswapD(colAPtr, colCount, colBPtr, colCount, UInt(rowCount))

        case .add(var scalar, let col, let toCol):
            
            let colPtr   = baseAddress.advanced(by: col * rowCount)
            let toColPtr = baseAddress.advanced(by: toCol * rowCount)
            
            vDSP_vsmaD(colPtr, colCount, &scalar, toColPtr, colCount, toColPtr, colCount, UInt(rowCount))
            
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
