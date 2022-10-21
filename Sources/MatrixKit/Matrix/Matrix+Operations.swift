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
        self.rank == other.rank && (self.colCount, self.rowCount) == (other.colCount, other.colCount)
    }
    
    /**
     * Returns `true` if this matrix has the same dimensions as another matrix
     */
    @inlinable
    func hasSameDimensions(as other: Matrix) -> Bool {
        self.rowCount == other.rowCount && self.colCount == other.colCount
    }
    
    // MARK: Matrix Operations
    
    /**
     * Scales every element of this matrix by a scalar, in place.
     *
     * - Parameter scalar: `Double` by which to scale every element of this matrix.
     */
    mutating func scale(by scalar: Double) {
        var scalar_p = scalar
        
        var copy = flatmap
        
        withBaseAddress { basePtr in
            vDSP_vsmulD(basePtr, 1, &scalar_p, &copy, 1, UInt(flatmap.count))
        }
        
        self.flatmap = copy
        
    }
    
    /**
     * The result of scaling this matrix by a scalar, out of place.
     *
     * - Parameter scalar: `Double` by which to scale every element of this matrix
     * - Returns: The result of scaling this matrix by a scalar.
     */
    func scaled(by scalar: Double) -> Matrix {
        var out = self
        var scalar_p = scalar
        
        out.withMutableBaseAddress { outMutableBaseAddress in
            withBaseAddress { baseAddress in
                vDSP_vsmulD(baseAddress, 1, &scalar_p, outMutableBaseAddress, 1, UInt(flatmap.count))
            }
            
        }
        
        return out
    }
    
    /**
     * Adds every element of another matrix to the corresponding element of this matrix, in place.
     *
     * - Precondition: `self.rowCount == other.rowCount && self.colCount == other.colCount`
     * - Parameter other: `Matrix` to add.
     */
    mutating func add(_ other: Matrix) {
        assert(hasSameDimensions(as: other), "Cannot add matrices of different dimensions")
        
        var copy = flatmap
        
        other.withBaseAddress { otherPtr in
            withBaseAddress { basePtr in
                vDSP_vaddD(basePtr, 1, otherPtr, 1, &copy, 1, UInt(flatmap.count))
            }
        }
        
        flatmap = copy
    }
    
    /**
     * Subtracts every element of another matrix to the corresponding element of this matrix, in place.
     *
     * - Precondition: `self.rowCount == other.rowCount && self.colCount == other.colCount`
     * - Parameter other: `Matrix` to subtract.
     */
    mutating func subtract(_ other: Matrix) {
        assert(hasSameDimensions(as: other), "Cannot subtract matrices of different dimensions")
        
        var copy = flatmap
        
        other.withBaseAddress { otherPtr in
            withBaseAddress { basePtr in
                vDSP_vsubD(basePtr, 1, otherPtr, 1, &copy, 1, UInt(flatmap.count))
            }
        }
        
        flatmap = copy
    }
    
    /**
     * Subtracts the values of another matrix from this matrix, out of place
     *
     * - Precondition: `self.colCount == other.colCount && self.rowCount == other.rowCount`
     * - Parameter other: `Matrix` to subtract.
     * - Returns: The difference of this matrix and `other`.
     */
    func difference(subtracting other: Matrix) -> Matrix {
        assert(hasSameDimensions(as: other), "Cannot subtract matrices of different dimensions")
        
        var out = self
        
        out.withMutableBaseAddress { outMutableBaseAddress in
            other.withBaseAddress { otherBaseAddress in
                withBaseAddress { baseAddress in
                    vDSP_vsubD(otherBaseAddress, 1, baseAddress, 1, outMutableBaseAddress, 1, UInt(flatmap.count))
                }
            }
        }
        
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
        assert(hasSameDimensions(as: other), "Cannot add matrices of different dimensions")
        var out = self
        
        out.withMutableBaseAddress { outMutableBaseAddress in
            other.withBaseAddress { otherBaseAddress in
                withBaseAddress { baseAddress in
                    vDSP_vaddD(baseAddress, 1, otherBaseAddress, 1, outMutableBaseAddress, 1, UInt(flatmap.count))
                }
            }
        }
        
        return out
    }
    
    /**
     * Computes the distance squared between two matrices as if their flat maps were vectors
     *
     * - Precondition: `self.rowCount == other.rowCount && self.colCount == other.colCount`
     * - Parameter other: A matrix to compute the distance squared from
     * - Returns: A nonnegative number representing how far off these matrices are from each other, squared
     */
    func distanceSquared(from other: Matrix) -> Element {
        assert(hasSameDimensions(as: other), "Cannot find distance between matrices of different dimensions")
        var ds: Double = 0
        
        other.withBaseAddress { otherBaseAddress in
            withBaseAddress { baseAddress in
                vDSP_distancesqD(baseAddress, 1, otherBaseAddress, 1, &ds, UInt(count))
            }
        }
        
        return ds
    }
    
    /**
     * Computes the distance between two matrices as if their flat maps were vectors
     *
     * - Precondition: `self.rowCount == other.rowCount && self.colCount == other.colCount`
     * - Parameter other: A matrix to compute the distance from
     * - Returns: A nonnegative number representing how far off these matrices are from each other
     */
    func distance(from other: Matrix) -> Element {
        sqrt(distanceSquared(from: other))
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
        assert(lhs.colCount == self.rowCount, "Invalid dimensions for matrix multiplcation")
        
        var product = Matrix(rows: lhs.rowCount, cols: self.colCount)
        
        withBaseAddress { basePtr in
            lhs.withBaseAddress { lhsPtr in
                product.withMutableBaseAddress { productPtr in
                    vDSP_mmulD(
                        lhsPtr,     1,
                        basePtr,    1,
                        productPtr, 1,
                        UInt(lhs.rowCount), UInt(self.colCount), UInt(lhs.colCount)
                    )
                }
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
        assert(self.colCount == rhs.rowCount, "Invalid dimensions for matrix multiplcation")
        
        var product = Matrix(rows: self.rowCount, cols: rhs.colCount)
        
        withBaseAddress { basePtr in
            rhs.withBaseAddress { rhsPtr in
                product.withMutableBaseAddress { productPtr in
                    vDSP_mmulD(
                        basePtr,     1,
                        rhsPtr,      1,
                        productPtr,  1,
                        UInt(self.rowCount), UInt(rhs.colCount), UInt(self.colCount)
                    )
                }
            }
        }
        
        return product
    }
    
    /**
     * Computes the magnitude squared of this matrix. That is, the sum of the squares of all elements of the matrix
     */
    internal func computeMagnitudeSquared() -> Double {
        withBaseAddress { baseAddress in
            // TODO: Right now this can only take a 32 bit integer as the size, so eventally might have to
            // split the computation up for larger vectors.
            cblas_dnrm2(Int32(count), baseAddress, 1)
        }
    }
    
    /**
     * Computes the magnitude of this matrix
     */
    internal func computeMagnitude() -> Double {
        sqrt(computeMagnitudeSquared())
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
        product.withMutableBaseAddress { productBaseAddress in
            withBaseAddress { baseAddress in
                other.withBaseAddress { otherBaseAddress in
                    vDSP_vmulD(baseAddress, 1, otherBaseAddress, 1, productBaseAddress, 1, UInt(count))
                }
            }
        }
        return product
    }
    
    /**
     * Scales every this matrix by the multiplicative inverse of `self.magnitude`, so that the new magnitude is 1.
     */
    mutating func normalize() {
        if magnitude.isZero { return }
        scale(by: 1 / magnitude)
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
    
    fileprivate mutating func scale(row: Int, by scalar: Element) {
        var copy = flatmap
        var scalar_p = scalar
        
        copy.withUnsafeMutableBufferPointer { bufferPtr in
            
            let basePtr = bufferPtr.baseAddress!.advanced(by: row * colCount)
            
            vDSP_vsmulD(
                basePtr, 1, &scalar_p,
                basePtr, 1, UInt(colCount)
            )
        }
        
        self.flatmap = copy
    }
    
    fileprivate mutating func swap(row rowA: Int, with rowB: Int) {
        var copy = self
        copy.withMutableBaseAddress { mutablePtr in
            let rowAPtr = mutablePtr.advanced(by: rowA * colCount)
            let rowBPtr = mutablePtr.advanced(by: rowB * colCount)
            
            vDSP_vswapD(rowAPtr, 1, rowBPtr, 1, UInt(colCount))
        }
        self.flatmap = copy.flatmap
    }
    
    fileprivate mutating func add(row: Int, scaledBy scalar: Element, toRow dest: Int) {
        var copy = self
        copy.withMutableBaseAddress { mutablePtr in
            let rowPtr   = mutablePtr.advanced(by: row * colCount)
            let toRowPtr = mutablePtr.advanced(by: dest * colCount)
            var scalar_p = scalar
            
            vDSP_vsmaD(rowPtr, 1, &scalar_p, toRowPtr, 1, toRowPtr, 1, UInt(colCount))
        }
        self.flatmap = copy.flatmap
    }
    
    /**
     * Applies a column operation on this matrix
     *
     * - Precondition: The affected indices in `columnOperation` are not out of bounds for this matrix
     *
     * - Parameter columnOperation: `ElementaryOperation` to perform as a column operation
     */
    mutating func apply(columnOperation: ElementaryOperation) {
        var copy = self
        copy.withMutableBaseAddress { basePtr in
            switch columnOperation {
                case .scale(let col, var scalar):
                    assert(col < colCount, "Column index out of bounds")
                    scale(col: col, by: &scalar, basePtr: basePtr)
                case .swap(let colA, let colB):
                    assert(colA < colCount && colB < colCount, "Column index out of bounds")
                    swap(col: colA, with: colB, basePtr: basePtr)
                case .add(var scalar, let col, let toCol):
                    assert(col < colCount, "Column index out of bounds")
                    add(col: col, scaledBy: &scalar, toCol: toCol, basePtr: basePtr)
            }
        }
        self.flatmap = copy.flatmap
    }
    
    fileprivate func scale(col: Int, by scalar: inout Element, basePtr: UnsafeMutablePointer<Double>) {
        let colPtr = basePtr.advanced(by: col * rowCount)
        vDSP_vsmulD(colPtr, colCount, &scalar, colPtr, 1, UInt(rowCount))
    }
    
    fileprivate func swap(col colA: Int, with colB: Int, basePtr: UnsafeMutablePointer<Double>) {
        let colAPtr = basePtr.advanced(by: colA * rowCount)
        let colBPtr = basePtr.advanced(by: colB * rowCount)
        vDSP_vswapD(colAPtr, colCount, colBPtr, colCount, UInt(rowCount))
    }
    
    fileprivate func add(col: Int, scaledBy scalar: inout Element, toCol dest: Int, basePtr: UnsafeMutablePointer<Double>) {
        let colPtr   = basePtr.advanced(by: col * rowCount)
        let toColPtr = basePtr.advanced(by: dest * rowCount)
        vDSP_vsmaD(colPtr, colCount, &scalar, toColPtr, colCount, toColPtr, colCount, UInt(rowCount))
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
    
    /**
     * Sums accross the columns of this matrix to produce a column vector, whos elements are the sum of each row.
     */
    func rowSum() -> Matrix {
        var sum = Matrix(rows: rowCount, cols: 1)
        
        sum.withMutableBaseAddress { sumAddr in
            withBaseAddress { baseAddr in
                for c in 0..<colCount {
                    let startAddr = baseAddr.advanced(by: c)
                    vDSP_vaddD(
                        startAddr,
                        colCount,
                        sumAddr, 1,
                        sumAddr, 1,
                        UInt(rowCount)
                    )
                }
            }
        }
        
        return sum
    }
    
}
