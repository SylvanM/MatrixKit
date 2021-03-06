//
//  Matrix+RowUtility.swift
//  
//
//  Created by Sylvan Martin on 6/18/22.
//

import Foundation

internal extension Matrix {
    
    static func rowEchelon(on matrix: inout Matrix, withRecipient recipient: UnsafeMutablePointer<Matrix>? = nil, pivotsRef: UnsafeMutablePointer<[Int]>? = nil) {
        if let pivotsRef = pivotsRef {
            rowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: pivotsRef)
        } else {
            var pivots = [Int](repeating: 0, count: matrix.colCount)
            rowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: &pivots)
        }
        
    }
    
    static func reducedRowEchelon(on matrix: inout Matrix, withRecipient recipient: UnsafeMutablePointer<Matrix>? = nil) {
        var pivots = [Int](repeating: 0, count: matrix.colCount)
        rowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: &pivots)
        reducedRowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: &pivots)
    }
    
}

fileprivate extension Matrix {
    
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
    static func rowEchelonRec(on matrix: inout Matrix, withRecipient recipient: UnsafeMutablePointer<Matrix>? = nil, pivotsRef: UnsafeMutablePointer<[Int]>, startingCol: Int = 0, pivotRow: Int = 0) {
        
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
        
        if matrix[pivotRow, startingCol] == 0 {
            
            // find the first nonzero entry of this row, and move that to be the pivot.
            for row in (pivotRow + 1)..<matrix.rowCount {
                if matrix[row, startingCol] != 0 {
                    // we found a new pivot possibility! swap it to be the pivot.
                    let swapOp = ElementaryOperation.swap(pivotRow, row)
                    matrix.apply(rowOperation: swapOp)
                    recipient?.pointee.apply(rowOperation: swapOp)
                    
                    // now, just do row reduction after we've swapped.
                    rowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: pivotsRef, startingCol: startingCol, pivotRow: pivotRow)
                    return
                }
            }
            
            // there are only zeros from here down, so this entry is not a pivot.
            pivotsRef.pointee[startingCol] = -1
            rowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: pivotsRef, startingCol: startingCol + 1, pivotRow: pivotRow)
            return
        }
        
        let pivotEntry = matrix[pivotRow, startingCol]
        
        // at this point, we have a pivot in the right location, so let's eliminate entries below the pivot.
        for row in (pivotRow + 1)..<matrix.rowCount {
            let entry = matrix[row, startingCol]
            if entry == 0 { continue }
            let scalar = -entry / pivotEntry
            
            let elimOp = ElementaryOperation.add(scalar: scalar, index: pivotRow, toIndex: row)
            matrix.apply(rowOperation: elimOp)
            recipient?.pointee.apply(rowOperation: elimOp)
        }
        
        rowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: pivotsRef, startingCol: startingCol + 1, pivotRow: pivotRow + 1)
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
    static func reducedRowEchelonRec(on matrix: inout Matrix, withRecipient recipient: UnsafeMutablePointer<Matrix>? = nil, pivotsRef: UnsafeMutablePointer<[Int]>, startingCol: Int = 0) {
        if startingCol == matrix.colCount {
            return // we're done
        }
        
        
        
        let pivotRow = pivotsRef.pointee[startingCol]
        
        if pivotRow == -1 {
            // skip this column
            reducedRowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: pivotsRef, startingCol: startingCol + 1)
            return
        }
        
        // normalize this row relative to pivot
        let pivotEntry = matrix[pivotRow, startingCol]
        
        let scalar = 1 / pivotEntry
        
        let normOp = ElementaryOperation.scale(index: pivotRow, by: scalar)

        matrix.apply(rowOperation: normOp)
        recipient?.pointee.apply(rowOperation: normOp)
        
        // eliminate other entries in this column
        for row in 0..<pivotRow {

            let entry = matrix[row, startingCol]

            if entry == 0 { continue }

            let scalar = -entry
            let elimOp = ElementaryOperation.add(scalar: scalar, index: pivotRow, toIndex: row)

            matrix.apply(rowOperation: elimOp)
            recipient?.pointee.apply(rowOperation: elimOp)
        }
        
        // now do the same on the rest of the matrix!
        reducedRowEchelonRec(on: &matrix, withRecipient: recipient, pivotsRef: pivotsRef, startingCol: startingCol + 1)
    }
    
}
