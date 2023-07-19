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
     * Whether or not this matrix is all zero
     */
    var isZero: Bool {
        allSatisfy { $0 == .zero }
    }
    
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
    
}

public extension Matrix where Element: Field {
    
    /**
     * Whether or not this matrix is invertible
     */
    var isInvertible: Bool {
        guard isSquare else { return false }
        return rank == rowCount
    }
    
    // MARK: - Eigenvalues
    
    /**
     * Returns `true` if the given vector is an eigenvector of this matrix
     *
     * - Precondition: `vect.isVector`
     */
    func isEigenvector(_ vect: Matrix) -> Bool {
        let out = self * vect
        
        if vect.isZero {
            return false
        }
        
        var firstNonzeroEntry = 0
        
        while vect[firstNonzeroEntry, 0] == .zero {
            firstNonzeroEntry += 1
        }
        
        let firstScalar = out[firstNonzeroEntry, 0] / vect[firstNonzeroEntry, 0]
        
        return vect * firstScalar == out
    }
    
}

/**
 * Utility functions
 */
fileprivate extension Matrix {
    
    func isUpperTriangular(startingIndex: Int = 0) -> Triangularity {
        if startingIndex >= colCount - 1 { return .upper }
        
        for r in (startingIndex + 1)..<rowCount {
            if self[r, startingIndex] != .zero {
                return .none
            }
        }
        
        return isUpperTriangular(startingIndex: startingIndex + 1)
    }
    
    func isLowerTriangular(startingIndex: Int = 0) -> Triangularity {
        if startingIndex >= colCount { return .lower }
        
        for r in 0..<startingIndex {
            if self[r, startingIndex] != .zero {
                return .none
            }
        }
        
        return isLowerTriangular(startingIndex: startingIndex + 1)
    }
    
    /**
     * This assumes the matrix is square
     */
    func getTriangularity(startingIndex: Int) -> Triangularity {
        if startingIndex == rowCount { return .diagonal }
        
        for r in 0..<startingIndex {
            if self[r, startingIndex] != .zero {
                return isUpperTriangular(startingIndex: startingIndex)
            }
        }
        
        for r in (startingIndex + 1)..<rowCount {
            if self[r, startingIndex] != .zero {
                return isLowerTriangular(startingIndex: startingIndex)
            }
        }
        
        return getTriangularity(startingIndex: startingIndex + 1)
    }
    
    func getTriangularity() -> Triangularity {
        if !isSquare { return .none }
        if colCount == 1 { return .diagonal }
        return getTriangularity(startingIndex: 0)
    }
    
}
