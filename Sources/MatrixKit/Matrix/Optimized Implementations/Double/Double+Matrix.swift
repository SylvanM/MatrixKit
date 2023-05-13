//
//  Double+Matrix.swift
//
//  A collection of implementations and methods for matrices with entries that are Doubles
//
//  Created by Sylvan Martin on 5/12/23.
//

import Foundation
import Accelerate

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
    
}
