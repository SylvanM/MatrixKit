//
//  Double+Utility.swift
//  
//
//  Created by Sylvan Martin on 5/12/23.
//

import Foundation
import Accelerate

public extension Matrix where Element == Double {
    
    // MARK: Random Matrices
    
    /**
     * Creates a random matrix
     *
     * - Parameter rows: The amount of rows in the random matrix
     * - Parameter cols: The amount of columns in the random matrix
     * - Parameter range: A closed range to guarantee all elements of the matrix are in. By default, this will generate numbers between 0 and 1.
     *
     * - Returns: A new, random matrix, with all elements in `range`
     */
    static func random(rows: Int, cols: Int, range: ClosedRange<Element> = 0...1) -> Matrix {
        Matrix(rows: rows, cols: cols) { _, _ in
            Element.random(in: range)
        }
    }
    
    // MARK: Misc
    
    mutating func setToZero() {
        var new = flatmap
        
        new.withUnsafeMutableBufferPointer { buffer in
            vDSP_vclrD(buffer.baseAddress!, 1, UInt(count))
        }
        
        self.flatmap = new
    }
    
}
