//
//  Matrix+RowUtility.swift
//  
//
//  Created by Sylvan Martin on 6/18/22.
//

import Foundation

public extension Matrix where Element: Field {
    
    /**
     * Computes the determinant of a matrix
     *
     * - Precondition: `isSquare` and `colCount >= 1`
     */
    var determinant: Element {
        Matrix<Element>.computeDeterminant(self)
    }
    
    /**
     * This matrix in row echelon form.
     *
     * Different authors use different meanings of "row echelon form" versus "*reduced* row echelon form", so for clarity,
     * I am using the same definitions as are used here: https://en.wikipedia.org/wiki/Row_echelon_form
     */
    var rowEchelonForm: Matrix {
        // TODO: Speed check this to see if this is really worth checking

        if isRowEchelonForm {
            return self
        }
        
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
     * The matrix `A` such that `A * self` is the identity matrix of this matrix.
     *
     * Requires `self.isSquare`.
     */
    var inverse: Matrix {
        computeInverse()
    }
    
    /**
     * The rank of this matrix
     */
    var rank: Int {
        computeRank()
    }
    
    /**
     * A matrix whose columns form the basis of the kernel of `self`
     */
    var kernel: Matrix {
        computeKernel()
    }
    
    /**
     * Computes the LU decomposition of this matrix
     *
     * - Returns: A permutation matrix, an upper triangular matrix `upper` and a lower triangle matrix `lower` such that `permutation * self == lower * upper`
     */
    var luDecomposition: (swapCount: Int, permutation: Matrix, lower: Matrix, upper: Matrix) {
//        var upper = self
//        var lower = Matrix.identity(forDim: self.rowCount)
//        var swaps = Matrix.identity(forDim: self.rowCount)
//
//        var swapCount = 0
//
//        Matrix._LUrowEchelonRec(on: &upper, swaps: &swaps, swapCount: &swapCount, lower: &lower)
//
//        return (swaps, lower, upper)
        Matrix._LUrowEchelon(on: self)
    }
    
}

fileprivate extension Matrix where Element: Field {
    
    // MARK: Row Reduction Algorithm
    
    static func reducedRowEchelon(on matrix: inout Matrix, withRecipient recipient: UnsafeMutablePointer<Matrix>? = nil) {
        var pivots = [Int](repeating: 0, count: matrix.colCount)
        reducedRowEchelon(on: &matrix, withRecipient: recipient, pivotsRef: &pivots)
    }
    
    static func reducedRowEchelon(on matrix: inout Matrix, withRecipient recipient: UnsafeMutablePointer<Matrix>? = nil, pivotsRef: UnsafeMutablePointer<[Int]>) {
        rowEchelon(on: &matrix, withRecipient: recipient, pivotsRef: pivotsRef)
        _reducedRowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: pivotsRef)
    }
    
    static func rowEchelon(on matrix: inout Matrix, withRecipient recipient: UnsafeMutablePointer<Matrix>? = nil, pivotsRef: UnsafeMutablePointer<[Int]>? = nil) {
        if let pivotsRef = pivotsRef {
            _rowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: pivotsRef)
        } else {
            var pivots = [Int](repeating: 0, count: matrix.colCount)
            _rowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: &pivots)
        }
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
                if self[row, startingCol] != .zero {
                    return false
                }
            }
        }
        
        if pivotEntry == .zero {
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
                    guard self[row, startingCol] == .zero else { return false }
                }
            }
            
            return isReducedRowEchelonForm(startingRow: startingRow, startingCol: startingCol + 1, pivotsRef: &pivotLocations)
            
        }
        
        // make sure this pivot entry is 1!
        guard self[thisPivotLocation, startingCol] == .one else { return false }
        
        // make sure everything above this entry is zero.
        if thisPivotLocation > 0 {
            for row in 0..<thisPivotLocation {
                guard self[row, startingCol] == .zero else { return false }
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
    
    static func computeDeterminant(_ matrix: Matrix) -> Element {
        assert(matrix.isSquare, "Can only compute determinant of a square matrix.")
        var upper = matrix
        var lower = Matrix.identity(forDim: matrix.colCount)
        var swaps = Matrix.identity(forDim: matrix.colCount)
        var swapCount = 0
        Matrix._LUrowEchelonRec(on: &upper, swaps: &swaps, swapCount: &swapCount, lower: &lower)
        var determinant = (swapCount % 2 == 0) ? Element.one : -Element.one
        
        for i in 0..<matrix.colCount {
            determinant *= upper[i, i]
            determinant *= lower[i, i]
        }
        
        return determinant
    }
    
    func computeInverse() -> Matrix {
        var rref = self
        var inv = Matrix.identity(forDim: rowCount)
        Matrix.reducedRowEchelon(on: &rref, withRecipient: &inv)
        return inv
    }
    
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

fileprivate extension Matrix where Element: Field {
    
    /**
     * Performs row reduction to echelon form, but **not** necessarily *reduced* row echelon form, This should *only* be called from `rowEchelon`
     * and if this is also being used to compute an inverse, the sequence of row operations perfomed on this matrix
     * are also performed on a given matrix as a recipient.
     *
     * - Parameter matrix: The matrix on which to perform row reduction
     * - Parameter recipient: An optional pointer to the matrix on which to perform the same operations performed on `matrix`, by default `nil`.
     * - Parameter startingCol: The column at which to start, so that this can be recursive.
     * - Parameter pivotRow: The row in `startingCol` to treat as the pivot row.
     */
    static func _rowEchelonRec(on matrix: inout Matrix, withRecipient recipient: UnsafeMutablePointer<Matrix>? = nil, pivotsRef: UnsafeMutablePointer<[Int]>, startingCol: Int = 0, pivotRow: Int = 0) {
        
        if pivotRow == matrix.rowCount || startingCol == matrix.colCount {
            if startingCol != matrix.colCount {
                // -1 out remaining pivots
                for c in startingCol..<matrix.colCount {
                    pivotsRef.pointee[c] = -1
                }
            }
        
            return
        }
        
        pivotsRef.pointee[startingCol] = pivotRow
        
        if matrix[pivotRow, startingCol] == .zero {
            
            // find the first nonzero entry of this row, and move that to be the pivot.
            for row in (pivotRow + 1)..<matrix.rowCount {
                if matrix[row, startingCol] != .zero {
                    // we found a new pivot possibility! swap it to be the pivot.
                    let swapOp = ElementaryOperation.swap(pivotRow, row)
                    matrix.apply(rowOperation: swapOp)
                    recipient?.pointee.apply(rowOperation: swapOp)
                    
                    // now, just do row reduction after we've swapped.
                    _rowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: pivotsRef, startingCol: startingCol, pivotRow: pivotRow)
                    return
                }
            }
            
            // there are only zeros from here down, so this entry is not a pivot.
            pivotsRef.pointee[startingCol] = -1
            _rowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: pivotsRef, startingCol: startingCol + 1, pivotRow: pivotRow)
            return
        }
        
        let pivotEntry = matrix[pivotRow, startingCol]
        
        // at this point, we have a pivot in the right location, so let's eliminate entries below the pivot.
        for row in (pivotRow + 1)..<matrix.rowCount {
            let entry = matrix[row, startingCol]
            if entry == .zero { continue }
            let scalar = -entry / pivotEntry
            
            let elimOp = ElementaryOperation.add(scalar: scalar, index: pivotRow, toIndex: row)
            matrix.apply(rowOperation: elimOp)
            recipient?.pointee.apply(rowOperation: elimOp)
        }
        
        _rowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: pivotsRef, startingCol: startingCol + 1, pivotRow: pivotRow + 1)
    }
    
    static func _LUrowEchelon(on matrix: Matrix) -> (swapCount: Int, permutation: Matrix, lower: Matrix, upper: Matrix) {
        var lower = Matrix.zero(rows: matrix.rowCount, cols: matrix.rowCount) // Matrix.identity(forDim: matrix.rowCount)
        var upper = matrix
        var permutation = Matrix.identity(forDim: matrix.rowCount)
        var swapCount = 0
        
        _LUrowEchelonRec(on: &upper, swaps: &permutation, swapCount: &swapCount, lower: &lower)
        
        return (swapCount, permutation, lower, upper)
    }
    
    /**
     * Performs row reduction to echelon form, while keeping track of swaps and what coefficients are used to annihilate rows, for the purposes of LU decomposition.
     *
     * - Parameter matrix: The matrix on which to perform row reduction
     * - Parameter startingCol: The column at which to start, so that this can be recursive.
     * - Parameter pivotRow: The row in `startingCol` to treat as the pivot row.
     * - Parameter swaps: Starting as the identity matrix, this keeps track of all swapping operations applied.
     * - Parameter swapCount: The number of swaps that occurred
     * - Parameter lower: Starting as the identity matrix, this keeps track of all coefficients used to zero out rows.
     * - Parameter colTracker: This keeps track of which column should be altered in `lower`
     */
    static func _LUrowEchelonRec(on matrix: inout Matrix, startingCol: Int = 0, pivotRow: Int = 0, swaps: inout Matrix, swapCount: inout Int, lower: inout Matrix, colTracker: Int = 0) {
    
        if pivotRow == matrix.rowCount || startingCol == matrix.colCount {
            return
        }
        
        if matrix[pivotRow, startingCol] == .zero {
            
            // find the first nonzero entry of this row, and move that to be the pivot.
            for row in (pivotRow + 1)..<matrix.rowCount {
                if matrix[row, startingCol] != .zero {
                    // we found a new pivot possibility! swap it to be the pivot.
                    let swapOp = ElementaryOperation.swap(pivotRow, row)
                    matrix.apply(rowOperation: swapOp)
                    swaps.apply(rowOperation: swapOp)
                    lower.apply(rowOperation: swapOp)
                    
                    // now, just do row reduction after we've swapped.
                    _LUrowEchelonRec(on: &matrix, startingCol: startingCol, pivotRow: pivotRow, swaps: &swaps, swapCount: &swapCount, lower: &lower, colTracker: colTracker)
                    return
                }
            }
            
            // there are only zeros from here down, so this entry is not a pivot.
            _LUrowEchelonRec(on: &matrix, startingCol: startingCol + 1, pivotRow: pivotRow, swaps: &swaps, swapCount: &swapCount, lower: &lower, colTracker: colTracker)
            return
        }
        
        let pivotEntry = matrix[pivotRow, startingCol]
        
        lower[rows: pivotRow..<lower.rowCount, cols: colTracker...colTracker] = pivotEntry.inverse * matrix[rows: pivotRow..<lower.rowCount, cols: startingCol...startingCol]
        
        for row in (pivotRow + 1)..<matrix.rowCount {
            let entry = matrix[row, startingCol]
            if entry == .zero { continue }
            let scalar = -entry / pivotEntry
            
            let elimOp = ElementaryOperation.add(scalar: scalar, index: pivotRow, toIndex: row)
            matrix.apply(rowOperation: elimOp)
        }
        
        _LUrowEchelonRec(on: &matrix, startingCol: startingCol + 1, pivotRow: pivotRow + 1, swaps: &swaps, swapCount: &swapCount, lower: &lower, colTracker: colTracker + 1)
    }
    
    /**
     * Reduces a matrix to reduced row echelon form with guassian elimination, recursively. This is *only* to be called from `reducedRowEchelon`
     * and if this is also being used to compute an inverse, the sequence of row operations perfomed on this matrix
     * are also performed on a given matrix as a recipient.
     *
     * - Precondition: `matrix.isRowEchelon`
     *
     * - Parameter matrix: The matrix on which to perform row reduction
     * - Parameter recipient: An optional pointer to the matrix on which to perform the same operations performed on `matrix`, by default `nil`.
     * - Parameter pivots: A map of where the pivots are. This should be `nil` on the first call.
     */
    static func _reducedRowEchelonRec(on matrix: inout Matrix, withRecipient recipient: UnsafeMutablePointer<Matrix>? = nil, pivotsRef: UnsafeMutablePointer<[Int]>, startingCol: Int = 0) {
        if startingCol == matrix.colCount {
            return // we're done
        }
        
        let pivotRow = pivotsRef.pointee[startingCol]
        
        if pivotRow == -1 {
            // skip this column
            _reducedRowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: pivotsRef, startingCol: startingCol + 1)
            return
        }
        
        // normalize this row relative to pivot
        let pivotEntry = matrix[pivotRow, startingCol]
        
        let scalar = pivotEntry.inverse
        
        let normOp = ElementaryOperation.scale(index: pivotRow, by: scalar)

        matrix.apply(rowOperation: normOp)
        recipient?.pointee.apply(rowOperation: normOp)
        
        // eliminate other entries in this column
        for row in 0..<pivotRow {

            let entry = matrix[row, startingCol]

            if entry == .zero { continue }

            let scalar = -entry
            let elimOp = ElementaryOperation.add(scalar: scalar, index: pivotRow, toIndex: row)

            matrix.apply(rowOperation: elimOp)
            recipient?.pointee.apply(rowOperation: elimOp)
        }
        
        // now do the same on the rest of the matrix!
        _reducedRowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: pivotsRef, startingCol: startingCol + 1)
    }
    
}
