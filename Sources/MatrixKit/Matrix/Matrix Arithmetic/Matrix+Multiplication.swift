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
    
}
