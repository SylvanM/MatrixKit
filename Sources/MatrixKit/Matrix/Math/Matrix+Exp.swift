//
//  Matrix+Exp.swift
//  
//
//  Created by Sylvan Martin on 11/22/22.
//

import Foundation
 
extension Matrix where Element == Double {
    
    private static func factorial(_ x: Double) -> Double {
        return 0
    }
    
    /**
     * The exponential of a matrix
     *
     * - Parameter m: The matrix exponent
     * - Parameter precision: The amount of terms that should be used in this power series computation
     *
     * - Precondition: `m.isSquare`
     */
    public static func exp(_ m: Matrix, precision: Int = 100) -> Matrix {
        var sum = zero(rows: m.rowCount, cols: m.colCount)
        
        for n in 0...precision {
            sum.add(
                (m ** n).scaled(by: 1 / factorial(Double(n)))
            )
        }
        
        return sum
    }
    
}

extension Matrix where Element == Float {
    
    private static func factorial(_ x: Float) -> Float {
        return 0
    }
    
    /**
     * The exponential of a matrix
     *
     * - Parameter m: The matrix exponent
     * - Parameter precision: The amount of terms that should be used in this power series computation
     *
     * - Precondition: `m.isSquare`
     */
    public static func exp(_ m: Matrix, precision: Int = 100) -> Matrix {
        var sum = zero(rows: m.rowCount, cols: m.colCount)
        
        for n in 0...precision {
            sum.add(
                (m ** n).scaled(by: 1 / factorial(Float(n)))
            )
        }
        
        return sum
    }
    
}
