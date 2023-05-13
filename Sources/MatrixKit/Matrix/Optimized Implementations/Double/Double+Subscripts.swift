//
//  Double+Collection.swift
//  
//
//  Created by Sylvan Martin on 5/12/23.
//

import Foundation
import Accelerate

extension Matrix where Element == Double {
    
    /**
     * Accesses a submatrix of this matrix by value
     */
    public subscript(rows rows: Range<Int>, cols cols: Range<Int>) -> Matrix {
        get {
            assert(rows.allSatisfy { $0 < rowCount }, "Row slice index out of bounds")
            assert(cols.allSatisfy { $0 < colCount }, "Column slice index out of bounds")
            
            
            return withBaseAddress { baseAddress in
                
                let submatrixStart = baseAddress.advanced(by: rows.startIndex * colCount + cols.startIndex)
                
                var result = Matrix(rows: rows.count, cols: cols.count)
                let resultAddress: UnsafeMutablePointer<Element> = result.withMutableBaseAddress { $0 }
                
                vDSP_mmovD(
                    submatrixStart,
                    resultAddress,
                    UInt(cols.count),
                    UInt(rows.count),
                    UInt(self.colCount),
                    UInt(result.colCount)
                )
                
                return result
            }
        }
        set {
            assert(rows.allSatisfy { $0 < rowCount }, "Row slice index out of bounds")
            assert(cols.allSatisfy { $0 < colCount }, "Column slice index out of bounds")
            
            assert(rows.count == newValue.rowCount)
            assert(cols.count == newValue.colCount)
            
            newValue.withBaseAddress { newBaseAddress in
                
                let muttableAdr = withMutableBaseAddress { $0 }
                
                let submatrixStart = muttableAdr.advanced(by: rows.startIndex * colCount + cols.startIndex)
                    
                vDSP_mmovD(
                    newBaseAddress,
                    submatrixStart,
                    UInt(cols.count),
                    UInt(rows.count),
                    UInt(newValue.colCount),
                    UInt(self.colCount)
                )
            }
        }
    }
    
}
