//
//  Matrix+Exp.swift
//  
//
//  Created by Sylvan Martin on 11/22/22.
//

import Foundation
 
extension Matrix where Element == Double {
    
    fileprivate static func factorial(_ x: Int) -> Int {
        var factorial = 1
        
        for i in 1...x {
            factorial *= i
        }
        
        return factorial
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
            sum += (m.pow(n)) * (1 / Double(factorial(n)))
        }
        
        return sum
    }
    
}

extension Matrix where Element == Float {
    
    fileprivate static func factorial(_ x: Int) -> Int {
        var factorial = 1
        
        for i in 1...x {
            factorial *= i
        }
        
        return factorial
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
            sum += (m.pow(n)) * (1 / Float(factorial(n)))
        }
        
        return sum
    }
    
}
