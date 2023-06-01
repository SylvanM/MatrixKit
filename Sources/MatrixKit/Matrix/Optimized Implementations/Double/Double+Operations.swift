//
//  Double+Operations.swift
//  
//
//  Created by Sylvan Martin on 5/12/23.
//

import Foundation
import Accelerate

public extension Matrix where Element == Double {
    
    // MARK: - Matrix Operations
    
    func hadamard(with other: Matrix) -> Matrix {
        assert(hasSameDimensions(as: other), "Cannot compute Hadamard with matrices of different dimensions")
        
        var product = Matrix(rows: self.rowCount, cols: self.colCount)
        product.withMutableBaseAddress { productBaseAddress in
            withBaseAddress { baseAddress in
                other.withBaseAddress { otherBaseAddress in
                    vDSP_vmulD(baseAddress, 1, otherBaseAddress, 1, productBaseAddress, 1, UInt(count))
                }
            }
        }
        return product
    }
    
    // MARK: - Row Operations
    
    func rowSum() -> Matrix {
        var sum = Matrix(rows: rowCount, cols: 1)
        
        sum.withMutableBaseAddress { sumAddr in
            withBaseAddress { baseAddr in
                for c in 0..<colCount {
                    let startAddr = baseAddr.advanced(by: c)
                    vDSP_vaddD(
                        startAddr,
                        colCount,
                        sumAddr, 1,
                        sumAddr, 1,
                        UInt(rowCount)
                    )
                }
            }
        }
        
        return sum
    }
    
}
