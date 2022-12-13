//
//  Matrix+Multiplication.swift
//
//  A collection of other matrix multiplication algorithms to use
//  
//
//  Created by Sylvan Martin on 12/12/22.
//

import Foundation
import Accelerate

extension Matrix {
    
    // MARK: Standard Matrix Multiplication
    
    func defaultLeftMultiply(by lhs: Matrix) -> Matrix {
        assert(lhs.colCount == self.rowCount, "Invalid dimensions for matrix multiplcation")
        
        var product = Matrix(rows: lhs.rowCount, cols: self.colCount)
        
        withBaseAddress { basePtr in
            lhs.withBaseAddress { lhsPtr in
                product.withMutableBaseAddress { productPtr in
                    vDSP_mmulD(
                        lhsPtr,     1,
                        basePtr,    1,
                        productPtr, 1,
                        UInt(lhs.rowCount), UInt(self.colCount), UInt(lhs.colCount)
                    )
                }
            }
        }
        
        return product
    }
    
    func defaultRightMultiply(onto rhs: Matrix) -> Matrix {
        assert(self.colCount == rhs.rowCount, "Invalid dimensions for matrix multiplcation")
        
        var product = Matrix(rows: self.rowCount, cols: rhs.colCount)
        
        withBaseAddress { basePtr in
            rhs.withBaseAddress { rhsPtr in
                product.withMutableBaseAddress { productPtr in
                    vDSP_mmulD(
                        basePtr,     1,
                        rhsPtr,      1,
                        productPtr,  1,
                        UInt(self.rowCount), UInt(rhs.colCount), UInt(self.colCount)
                    )
                }
            }
        }
        
        return product
    }
    
    // MARK: More Fun Algorithms
    
    /**
     * Performs the Strassen algorithm on two square matrices whos sizes are a power of two
     *
     * - Parameter lhs: A square matrix
     * - Parameter rhs: A square matrix of the same size
     *
     * - Parameter minimumSize: The matrix size at which we should just use the standard algorithm, as it may be faster
     *
     * - Precondition: `lhs.isSquare && rhs.isSquare && lhs.colCount == rhs.colCount` and `lhs.colCount` is a power of 2.
     *
     * - Returns: The product `lhs * rhs`
     */
    static func strassen(lhs: Matrix, rhs: Matrix, minimumSize: Int) -> Matrix {
        let n = lhs.colCount
        
        if n <= minimumSize {
            return lhs.defaultRightMultiply(onto: rhs)
        }
        
        let a11 = lhs[0..<(n / 2), 0..<(n / 2)]
        let a12 = lhs[0..<(n / 2), (n / 2)..<n]
        let a21 = lhs[(n / 2)..<n, 0..<(n / 2)]
        let a22 = lhs[(n / 2)..<n, (n / 2)..<n]
        
        let b11 = rhs[0..<(n / 2), 0..<(n / 2)]
        let b12 = rhs[0..<(n / 2), (n / 2)..<n]
        let b21 = rhs[(n / 2)..<n, 0..<(n / 2)]
        let b22 = rhs[(n / 2)..<n, (n / 2)..<n]
        
        let m1 = strassen(lhs: a11 + a22,   rhs: b11 + b22, minimumSize: minimumSize)
        let m2 = strassen(lhs: a21 + a22,   rhs: b11,       minimumSize: minimumSize)
        let m3 = strassen(lhs: a11,         rhs: b12 - b22, minimumSize: minimumSize)
        let m4 = strassen(lhs: a22,         rhs: b21 - b11, minimumSize: minimumSize)
        let m5 = strassen(lhs: a11 + a12,   rhs: b22,       minimumSize: minimumSize)
        let m6 = strassen(lhs: a21 - a11,   rhs: b11 + b12, minimumSize: minimumSize)
        let m7 = strassen(lhs: a12 - a22,   rhs: b21 + b22, minimumSize: minimumSize)
        
        var product = Matrix(rows: n, cols: n)
        
        product[0..<(n / 2), 0..<(n / 2)] = m1 + m4 - m5 + m7
        product[0..<(n / 2), (n / 2)..<n] = m3 + m5
        product[(n / 2)..<n, 0..<(n / 2)] = m2 + m4
        product[(n / 2)..<n, (n / 2)..<n] = m1 - m2 + m3 + m6
        
        return product
        
    }
    
}
