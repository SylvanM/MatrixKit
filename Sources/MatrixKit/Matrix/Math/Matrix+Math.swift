//
//  Matrix+Math.swift
//  
//
//  Created by Sylvan Martin on 6/18/22.
//

import Foundation
import simd
import Accelerate

/**
 * Definitions of computed mathematical properties
 */
public extension Matrix {
    
    // MARK: Enums
    
    /**
     * The triangularity of a matrix
     */
    enum Triangularity {
        
        /**
         * Upper triangular form
         */
        case upper
        
        /**
         * Lower triangular form
         */
        case lower
        
        /**
         * A Diagonal matrix
         */
        case diagonal
        
        /**
         * Neither upper triangular, lower triangular, nor diagonal
         */
        case none
        
    }
    
    // MARK: - Mathematical Properties
    
    /**
     * The shape of this matrix, whether it is diagonal, lower triangular, or upper triangular
     */
    var triangularity: Triangularity {
        getTriangularity()
    }
    
    /**
     * Whether this matrix is upper triangular form
     */
    var isUpperTriangular: Bool {
        triangularity == .diagonal || triangularity == .upper
    }
    
    /**
     * Whether this matrix is lower triangular form
     */
    var isLowerTriangular: Bool {
        triangularity == .diagonal || triangularity == .lower
    }
    
    /**
     * Whether this matrix is diagonal
     */
    var isDiagonal: Bool {
        triangularity == .diagonal
    }
    
    /**
     * Computes the determinant of a matrix
     *
     * - Precondition: `isSquare` and `colCount >= 1`
     */
    var determinant: Element {
        computeDeterminant()
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
        isRowEchelonForm()
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
        isReducedRowEchelonForm()
    }
    
    /**
     * The rank of this matrix
     */
    var rank: Int {
        computeRank()
    }
    
    /**
     * Whether or not this matrix is invertible
     */
    var isInvertible: Bool {
        guard isSquare else { return false }
        return rank == rowCount
    }
    
    /**
     * The matrix `A` such that `A * self` is the identity matrix of this matrix.
     *
     * Requires `self.isSquare`.
     */
    var inverse: Matrix {
        computeInverse()
    }
    
    // MARK: - Spaces

    /**
     * A matrix whose columns form the basis of the kernel of `self`
     */
    var kernel: Matrix {
        computeKernel()
    }
    
    // MARK: Advanced Operations
    
    /**
     * Raises a square matrix `m` to an integer power `p`
     *
     * - Precondition: `m.isSquare && p >= 0`
     *
     * - Returns: `m` raised to `p`
     */
    static func pow(_ m: Matrix, _ p: Int) -> Matrix {
        // TODO: Make this WAYYY better, this is a very temporary solution
        if p == 0 {
            return Matrix.identity(forDim: m.rowCount)
        }
        
        return m * pow(m, p - 1)
    }
    
    
    // MARK: - Eigenvalues
    
    /**
     * Returns `true` if the given vector is an eigenvector of this matrix
     *
     * - Precondition: `vect.isVector`
     */
    func isEigenvector(_ vect: Matrix) -> Bool {
        let out = self * vect
        
        let firstScalar = out[0, 0] / vect[0, 0]
        
        return vect * firstScalar == out
    }
    
}

/**
 * Utility functions
 */
fileprivate extension Matrix {
    
    func isUpperTriangular(startingRow: Int = 0) -> Triangularity {
        if startingRow == rowCount - 1 { return .upper }
        
        for r in (startingRow + 1)..<rowCount {
            if self[r, startingRow] != 0 {
                return .none
            }
        }
        
        return isUpperTriangular(startingRow: startingRow + 1)
        
    }
    
    func isLowerTriangular(startingRow: Int = 0) -> Triangularity {
        if startingRow == rowCount - 1 { return .lower }
        
        for c in (startingRow + 1)..<colCount {
            if self[startingRow, c] != 0 {
                return .none
            }
        }
        
        return isLowerTriangular(startingRow: startingRow + 1)
    }
    
    /**
     * This assumes the matrix is square
     */
    func getTriangularity(startingRow: Int) -> Triangularity {
        if startingRow == rowCount - 1 { return .diagonal }
        
        for c in (startingRow + 1)..<colCount {
            if self[startingRow, c] != 0 {
                return isUpperTriangular(startingRow: startingRow)
            }
        }
        
        for r in (startingRow + 1)..<rowCount {
            if self[r, startingRow] != 0 {
                return isLowerTriangular(startingRow: startingRow)
            }
        }
        
        return getTriangularity(startingRow: startingRow + 1)
    }
    
    func getTriangularity() -> Triangularity {
        if !isSquare { return .none }
        return getTriangularity(startingRow: 0)
    }
    
    /**
     * This function also contains a reference to an array that contains the locations of the pivots so that we don't have to re-find the pivots
     * when checking if this is also reduced row echelon form.
     *
     * - Parameter pivotsRef: A pointer to an array `pivots` such that `pivots.count == self.colCount`, where `pivots[i]` is the
     * row in which the pivot in column `i` is in `rowEchelonForm`. If there is no pivot in this column, then `pivots[i] == -1`.
     *
     * - Precondition: If this function is called non-recursively, it *must* not be given any parameters other than the default parameter values.
     */
    func isRowEchelonForm(startingRow: Int = 0, startingCol: Int = 0, pivotsRef: UnsafeMutablePointer<[Int]>? = nil) -> Bool {
        
        if startingRow >= rowCount || startingCol >= colCount {
            return true
        }
        
        let pivotEntry = self[startingRow, startingCol]
        
        if startingRow != rowCount - 1 {
            for row in (startingRow + 1)..<rowCount {
                if self[row, startingCol] != 0 {
                    return false
                }
            }
        }
        
        if pivotEntry == 0 {
            // the rest of this column is all zeros, so just look at the next column over.
            
            pivotsRef?.pointee[startingRow] = -1
            
            // we've established that the rest of this column is zero, so now just check the next column.
            return isRowEchelonForm(startingRow: startingRow, startingCol: startingCol + 1, pivotsRef: pivotsRef)
        }
        
        pivotsRef?.pointee[startingRow] = startingCol
        return isRowEchelonForm(startingRow: startingRow + 1, startingCol: startingCol + 1, pivotsRef: pivotsRef)
        
    }
    
    /**
     * - Precondition: If this function is called non-recursively, it *must* not be given any parameters other than the default parameter values.
     * - Precondition: `pivotLocations` is only an empty array on this function's first call. Otherwise, it contains a list of pivot locations.
     */
    func isReducedRowEchelonForm(startingRow: Int = 0, startingCol: Int = 0, pivotsRef: UnsafeMutablePointer<[Int]>? = nil) -> Bool {
        
        // this could probably be simplified way more by just looping through pivotsRef.pointee,
        // then based off whether we see a -1 or not, check either the whole column or just below the pivot.
        // wait, am I basically already doing just that?
        
        if startingRow >= rowCount || startingCol >= colCount {
            return true
        }
        
        var pivotLocations = [Int](repeating: 0, count: colCount)
        
        if startingRow == 0 && startingCol == 0 {
            // this is our first call, so check that we are row echelon first.
            guard isRowEchelonForm(pivotsRef: &pivotLocations) else { return false }
            
        } else {
            pivotLocations = pivotsRef!.pointee
        }
        
        // at this point we are guaranteed to have a matrix in row echelon form, so now
        // just make sure it's reduced.
        
        // the location of the pivot in this row. if this is -1, just go onto the next row.
        let thisPivotLocation = pivotLocations[startingCol]
        
        if thisPivotLocation == -1 {
            // make sure everything below this entry is zero, but other than that,
            // we can move on.
            
            if startingRow < rowCount - 1 {
                for row in startingRow..<rowCount {
                    guard self[row, startingCol] == 0 else { return false }
                }
            }
            
            return isReducedRowEchelonForm(startingRow: startingRow, startingCol: startingCol + 1, pivotsRef: &pivotLocations)
            
        }
        
        // make sure this pivot entry is 1!
        guard self[thisPivotLocation, startingCol] == 1 else { return false }
        
        // make sure everything above this entry is zero.
        if thisPivotLocation > 0 {
            for row in 0..<thisPivotLocation {
                guard self[row, startingCol] == 0 else { return false }
            }
        }
        
        return isReducedRowEchelonForm(startingRow: thisPivotLocation + 1, startingCol: startingCol + 1, pivotsRef: &pivotLocations)
    }
    
    func computeRank() -> Int {
        var pivots = [Int](repeating: 0, count: colCount)
        var ref = self
        Matrix.rowEchelon(on: &ref, pivotsRef: &pivots)
        return pivots.reduce(into: 0) { partialResult, pivotLoc in
            partialResult += pivotLoc == -1 ? 0 : 1
        }
    }
    
    func computeInverse() -> Matrix {
        var rref = self
        var inv = Matrix.identity(forDim: rowCount)
        Matrix.reducedRowEchelon(on: &rref, withRecipient: &inv)
        return inv
    }
    
    func computeDeterminant() -> Element {
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
                let det = submatrix.computeDeterminant()
                
                if i % 2 == 1 {
                    scalar = -scalar
                }
                
                sum += scalar * det
            }
            
            return sum
        }
    }
    
    // MARK: Kernel Stuff
    
    /**
     * Computes the kernel of this matrix as a linear transformation
     *
     * - Returns a matrix whos columns are the basis of the kernel of `self`
     */
    func computeKernel() -> Matrix {
        
        var pivots = [Int](repeating: 0, count: colCount)
        var ref = self
        
        Matrix.rowEchelon(on: &ref, pivotsRef: &pivots)
        
        var tref = ref.transpose
        
        // doing row operations is the same as col ops on transpose
        var recipient = Matrix.identity(forDim: tref.rowCount)
        Matrix.reducedRowEchelon(on: &tref, withRecipient: &recipient)
        
        let alteredIden = recipient.transpose
        
        // compute the dimension of the kernel
        
        let rank = pivots.reduce(into: 0) { partialResult, pivotLoc in
            partialResult += pivotLoc == -1 ? 0 : 1
        }
        
        let kernelDim = colCount - rank
        
        if kernelDim == 0 {
            return Matrix.zero(rows: colCount, cols: 1)
        }
        
        return alteredIden[0..<alteredIden.rowCount, rank..<alteredIden.colCount]
        
    }
    
}
