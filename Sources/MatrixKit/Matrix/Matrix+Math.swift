//
//  Matrix+Math.swift
//  
//
//  Created by Sylvan Martin on 6/15/22.
//

import Foundation
import simd
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
    
    // MARK: - Matrix Math
    
    /**
     * Computes the determinant of a matrix
     *
     * - Precondition: `isSquare` and `colCount >= 1`
     */
    var determinant: Element {
        
        // if at any point this is a matrix that can be converted to a SIMD type, USE THAT!
        
        switch colCount {
        case 4:
            
            return simd_double4x4(
                simd_double4(flatmap[0], flatmap[4], flatmap[8], flatmap[12]),
                simd_double4(flatmap[1], flatmap[5], flatmap[9], flatmap[13]),
                simd_double4(flatmap[2], flatmap[6], flatmap[10], flatmap[14]),
                simd_double4(flatmap[3], flatmap[7], flatmap[11], flatmap[15])
            ).determinant
            
        case 3:
            
            return simd_double3x3(
                simd_double3(flatmap[0], flatmap[3], flatmap[6]),
                simd_double3(flatmap[1], flatmap[4], flatmap[7]),
                simd_double3(flatmap[2], flatmap[5], flatmap[8])
            ).determinant

        case 2:
            
            return simd_double2x2(
                simd_double2(flatmap[0], flatmap[2]),
                simd_double2(flatmap[1], flatmap[3])
            ).determinant
            
        case 1: return flatmap[0]
            
        default: // the recursive case!
            
            // Idea: Maybe search and see if there's a particular row/column that has a lot of zeros, and do co-factor expansion along that?
            var sum: Element = 0
            
            for i in 0..<colCount {
                var scalar = self[0, i]
                let submatrix = omitting(row: 0).omitting(col: i)
                let det = submatrix.determinant
                
                if i % 2 == 1 {
                    scalar = -scalar
                }
                
                sum += scalar * det
            }
            
            return sum
        }
            
    }
    
    /**
     * This matrix in row echelon form.
     *
     * Different authors use different meanings of "row echelon form" versus "*reduced* row echelon form", so for clarity,
     * I am using the same definitions as are used here: https://en.wikipedia.org/wiki/Row_echelon_form
     */
    var rowEchelonForm: Matrix {
        // TODO: Maybe add a check to see if this is already in row echelon form?
        
        var ref = self
        Matrix.rowEchelon(on: &ref)
        return ref
    }
    
    #warning("There is a horrendous amount of code duplication here, and frankly it embarasses me. This will do for now.")
    
    /**
     * `true` if this matrix is in row echelon form.
     *
     * Different authors use different meanings of "row echelon form" versus "*reduced* row echelon form", so for clarity,
     * I am using the same definitions as are used here: https://en.wikipedia.org/wiki/Row_echelon_form
     *
     * Here's an interesting problem. Inside this function, the rank is easily computed with little additional computation.
     * How can I not waste computation time when reading the `rank` property if a matrix is already in row echelon form?
     *
     * I can think of some really messy ways to do it, but I really want to avoid adding a  `didSet` listener on `flatmap`
     * to see if the matrix is updated and the rank needs to be re-calculated.
     */
    var isRowEchelonForm: Bool {
        var col = 0
        var pivotRow = col
        
        while col < colCount && pivotRow < rowCount {
            
            // make sure this is a valid pivot by assuring that all elements below it are zero
            
            for i in pivotRow..<rowCount {
                if !self[i, col].isZero { return false }
            }
            
            if self[pivotRow, col] == 0 {
                col += 1
                continue
            }
            
            // we found a valid pivot, now begin looking for the next pivot down and to the right
            
            col += 1
            pivotRow += 1
            
        }
        
        return true
    }
    
    /**
     * This matrix in reduced row echelon form.
     *
     * Different authors use different meanings of "row echelon form" versus "*reduced* row echelon form", so for clarity,
     * I am using the same definitions as are used here: https://en.wikipedia.org/wiki/Row_echelon_form#Reduced_row_echelon_form
     */
    var reducedRowEchelonForm: Matrix {
        // TODO: Maybe add a check to see if this is already in reduced row echelon form?
        
        var rref = self
        Matrix.reducedRowEchelon(on: &rref)
        return rref
    }
    
    /**
     * `true` if this matrix is in *reduced* row echelon form.
     *
     * Different authors use different meanings of "row echelon form" versus "*reduced* row echelon form", so for clarity,
     * I am using the same definitions as are used here: https://en.wikipedia.org/wiki/Row_echelon_form#Reduced_row_echelon_form
     */
    var isReducedRowEchelonForm: Bool {
        guard isRowEchelonForm else { return false }
        
        // go through each pivot
        
        var col = 0
        var pivotRow = col // where we're looking for the pivot to use
        
        while col < colCount && pivotRow < rowCount {
            
            if self[pivotRow, col] == 0 {
                col += 1
                continue
            }
            
            let pivotValue = self[pivotRow, col]
            
            if pivotValue != 1 {
                return false
            }
            
            for row in 0..<rowCount {
                if row == pivotRow {
                    continue
                } else {
                    if self[row, col] != 0 {
                        return false
                    }
                }
            }
            
            col += 1
            pivotRow += 1
            
        }
        
        return true
    }
    
    /**
     * The rank of this matrix
     */
    var rank: Int {
        let ref = rowEchelonForm
        
        var col = 0
        var pivotRow = col
        var pivots = 0
        
        while col < ref.colCount && pivotRow < ref.rowCount {
            
            if ref[pivotRow, col] == 0 {
                col += 1
                continue
            }
            
            // we found a valid pivot, now begin looking for the next pivot down and to the right
            pivots += 1
            
            col += 1
            pivotRow += 1
        }
        
        return pivots
    }
    
    /**
     * The matrix `A` such that `A * self` is the identity matrix of this matrix.
     *
     * Requires `self.isSquare`.
     */
    var inverse: Matrix {
        var rref = self
        var inv = Matrix.identity(forDim: rowCount)
        Matrix.reducedRowEchelon(on: &rref, withRecipient: &inv)
        return inv
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
    #warning("lazy implementation")
    mutating func apply(rowOperation: ElementaryOperation) {
        
        switch rowOperation {
        case .scale(let row, let scalar_c):
            
            for i in (colCount * row)..<(colCount * (row + 1)) {
                flatmap[i] *= scalar_c
            }
            
        case .swap(let rowA, let rowB):
            
            let tempRow = self[rowA]
            self[rowA] = self[rowB]
            self[rowB] = tempRow

        case .add(let scalar, let index, let toIndex):
            
            for i in 0..<colCount {
                self[toIndex][i] += scalar * self[index][i]
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
                self[col: col][i] *= scalar
            }
            
        case .swap(let colA, let colB):
            
            let tempCol = self[col: colA]
            self[col: colA] = self[col: colB]
            self[col: colB] = tempCol
            
        case .add(let scalar, let index, let toIndex):
            
            for i in 0..<rowCount {
                self[col: toIndex][i] += scalar * self[col: index][i]
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

public extension Matrix {
    
    // MARK: Internal Guassian Elimination
    
    /**
     * Performs row reduction to echelon form, but **not** necessarily *reduced* row echelon form,
     * and if this is also being used to compute an inverse, the sequence of row operations perfomed on this matrix
     * are also performed on a given matrix as a recipient.
     *
     * - Parameter matrix: The matrix on which to perform row reduction
     * - Parameter recipient: An optional pointer to the matrix on which to perform the same operations performed on `matrix`, by default `nil`.
     */
    static func rowEchelon(on matrix: inout Matrix, withRecipient recipient: UnsafeMutablePointer<Matrix>? = nil) {
        
        
        
    }
    
    /**
     * Reduces a matrix to reduced row echelon form with guassian elimination,
     * and if this is also being used to compute an inverse, the sequence of row operations perfomed on this matrix
     * are also performed on a given matrix as a recipient.
     *
     * - Parameter matrix: The matrix on which to perform row reduction
     * - Parameter recipient: An optional pointer to the matrix on which to perform the same operations performed on `matrix`, by default `nil`.
     */
    static func reducedRowEchelon(on matrix: inout Matrix, withRecipient recipient: UnsafeMutablePointer<Matrix>? = nil) {
        
        rowEchelon(on: &matrix, withRecipient: recipient)
        
        var col = 0
        var pivotRow = col // where we're looking for the pivot to use
        
        while col < matrix.colCount && pivotRow < matrix.rowCount {
            
            if matrix[pivotRow, col] == 0 {
                col += 1
                continue
            }
            
            // we found a pivot, now use it to ANNIAHLATE the other entries in its column, after normalizing this row.
            
            let pivotValue = matrix[pivotRow, col]
            let normalizeOp = ElementaryOperation.scale(index: pivotRow, by: 1 / pivotValue)
            
            matrix.apply(rowOperation: normalizeOp)
            recipient?.pointee.apply(rowOperation: normalizeOp)
            
            for row in 0..<matrix.rowCount {
                
                if row == pivotRow { continue }
                let entry = matrix[row, col]
                if entry == 0 { continue }
                
                let elimOp = ElementaryOperation.add(scalar: -entry, index: pivotRow, toIndex: row)
                
                matrix.apply(rowOperation: elimOp)
                recipient?.pointee.apply(rowOperation: elimOp)
                
            }
            
            col += 1
            pivotRow += 1
            
        }
        
    }
    
}

private extension Matrix {
    
    /**
     * This just provides a way of more efficiently computing the rank, if 
     */
    
}
