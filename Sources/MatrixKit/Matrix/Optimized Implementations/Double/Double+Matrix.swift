//
//  Double+Matrix.swift
//
//  A collection of implementations and methods for matrices with entries that are Doubles
//
//  Created by Sylvan Martin on 5/12/23.
//

import Foundation
import Accelerate

/**
 * A matrix with double-legth floating point entries
 */
public typealias DMatrix = Matrix<Double>

public extension Matrix where Element == Double {
    
    /**
     * The magnitude of this matrix
     */
    var magnitude: Double {
        computeMagnitude()
    }
    
    /**
     * Computes the matnitude squared of this matrix
     */
    var magnitudeSquared: Double {
        computeMagnitudeSquared()
    }
    
    /**
     * A scale of this matrix with a magnitude of 1
     */
    var normalized: Matrix {
        var norm = self
        norm.normalize()
        return norm
    }
    
    // MARK: Misc Operations
    
    var transpose: Matrix {
        if isVector { return Matrix(flatmap) }
        
        var trans = Matrix(rows: colCount, cols: rowCount)
        
        withBaseAddress { baseAddress in
            trans.withMutableBaseAddress { resultAddress in
                vDSP_mtransD(baseAddress, 1, resultAddress, 1, UInt(colCount), UInt(rowCount))
            }
        }
        
        return trans
    }
    
    // MARK: Methods
    
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
     * Scales every this matrix by the multiplicative inverse of `self.magnitude`, so that the new magnitude is 1.
     */
    mutating func normalize() {
        if magnitude.isZero { return }
        self *= 1 / magnitude
    }
    
}

fileprivate extension Matrix where Element == Double {
    
    /**
     * Computes the magnitude of this matrix
     */
    func computeMagnitude() -> Double {
        sqrt(computeMagnitudeSquared())
    }
    
    /**
     * Computes the magnitude squared of this matrix. That is, the sum of the squares of all elements of the matrix
     */
    func computeMagnitudeSquared() -> Double {
        withBaseAddress { baseAddress in
            // TODO: Right now this can only take a 32 bit integer as the size, so eventally might have to
            // split the computation up for larger vectors.
            cblas_dnrm2(Int32(count), baseAddress, 1)
        }
    }
    
}
