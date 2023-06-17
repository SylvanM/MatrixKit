//
//  Double+Math.swift
//  
//
//  Created by Sylvan Martin on 5/12/23.
//

import Foundation
import simd

public extension Matrix where Element == Double {
    
    var determinant: Double {
        Matrix<Double>.computeDeterminant(self)
    }
    
}

fileprivate extension Matrix where Element == Double {
    
    static func computeDeterminant(_ matrix: Matrix) -> Element {
        print("Using DOUBLE det")
        // if at any point this is a matrix that can be converted to a SIMD type, USE THAT!
        
        switch matrix.colCount {
        case 4:
            
            return simd_double4x4(
                simd_double4(matrix.flatmap[0], matrix.flatmap[4], matrix.flatmap[8],   matrix.flatmap[12]),
                simd_double4(matrix.flatmap[1], matrix.flatmap[5], matrix.flatmap[9],   matrix.flatmap[13]),
                simd_double4(matrix.flatmap[2], matrix.flatmap[6], matrix.flatmap[10],  matrix.flatmap[14]),
                simd_double4(matrix.flatmap[3], matrix.flatmap[7], matrix.flatmap[11],  matrix.flatmap[15])
            ).determinant
            
        case 3:
            
            return simd_double3x3(
                simd_double3(matrix.flatmap[0], matrix.flatmap[3], matrix.flatmap[6]),
                simd_double3(matrix.flatmap[1], matrix.flatmap[4], matrix.flatmap[7]),
                simd_double3(matrix.flatmap[2], matrix.flatmap[5], matrix.flatmap[8])
            ).determinant

        case 2:
            
            return simd_double2x2(
                simd_double2(matrix.flatmap[0], matrix.flatmap[2]),
                simd_double2(matrix.flatmap[1], matrix.flatmap[3])
            ).determinant
            
        case 1: return matrix.flatmap[0]
            
        default: // the recursive case!
            
            // Idea: Maybe search and see if there's a particular row/column that has a lot of zeros, and do co-factor expansion along that?
            var sum: Element = 0
            
            for i in 0..<matrix.colCount {
                var scalar = matrix[0, i]
                let submatrix = matrix.omitting(row: 0).omitting(col: i)
                let det = computeDeterminant(submatrix)
                
                if i % 2 == 1 {
                    scalar = -scalar
                }
                
                sum += scalar * det
            }
            
            return sum
        }
    }
    
}

