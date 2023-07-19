//
//  Double+Overloads.swift
//  
//
//  Created by Sylvan Martin on 5/31/23.
//

import Foundation
import Accelerate

public extension Matrix where Element == Double {
    
    // MARK: Matrix Math
    
    static func + (lhs: Matrix, rhs: Matrix) -> Matrix {
        lhs.sum(adding: rhs)
    }
    
    static func += (lhs: inout Matrix, rhs: Matrix) {
        lhs.add(rhs)
    }
    
    static func - (lhs: Matrix, rhs: Matrix) -> Matrix {
        lhs.difference(subtracting: rhs)
    }
    
    static func -= (lhs: inout Matrix, rhs: Matrix) {
        lhs.subtract(rhs)
    }
    
    static func * (lhs: Element, rhs: Matrix) -> Matrix {
        rhs.scaled(by: lhs)
    }
    
    static func * (lhs: Matrix, rhs: Element) -> Matrix {
        lhs.scaled(by: rhs)
    }
    
    static func *= (lhs: inout Matrix, rhs: Element) {
        lhs.scale(by: rhs)
    }
    
    static func * (lhs: Matrix, rhs: Matrix) -> Matrix {
        rhs.leftMultiply(by: lhs)
    }
    
}

fileprivate extension Matrix where Element == Double {
    
    mutating func scale(by scalar: Element) {
        var scalar_p = scalar
        
        var copy = flatmap
        
        withBaseAddress { basePtr in
            vDSP_vsmulD(basePtr, 1, &scalar_p, &copy, 1, UInt(flatmap.count))
        }
        
        self.flatmap = copy
        
    }
    
    func scaled(by scalar: Element) -> Matrix {
        var out = self
        var scalar_p = scalar
        
        out.withMutableBaseAddress { outMutableBaseAddress in
            withBaseAddress { baseAddress in
                vDSP_vsmulD(baseAddress, 1, &scalar_p, outMutableBaseAddress, 1, UInt(flatmap.count))
            }
        }
        
        return out
    }
    
    mutating func add(_ other: Matrix) {
        assert(hasSameDimensions(as: other), "Cannot add matrices of different dimensions")
        
        var copy = flatmap
        
        other.withBaseAddress { otherPtr in
            withBaseAddress { basePtr in
                vDSP_vaddD(basePtr, 1, otherPtr, 1, &copy, 1, UInt(flatmap.count))
            }
        }
        
        flatmap = copy
    }
    
    mutating func subtract(_ other: Matrix) {
        assert(hasSameDimensions(as: other), "Cannot subtract matrices of different dimensions")
        
        var copy = flatmap
        
        other.withBaseAddress { otherPtr in
            withBaseAddress { basePtr in
                vDSP_vsubD(basePtr, 1, otherPtr, 1, &copy, 1, UInt(flatmap.count))
            }
        }
        
        flatmap = copy
    }
    
    func difference(subtracting other: Matrix) -> Matrix {
        assert(hasSameDimensions(as: other), "Cannot subtract matrices of different dimensions")
        
        var out = self
        
        out.withMutableBaseAddress { outMutableBaseAddress in
            other.withBaseAddress { otherBaseAddress in
                withBaseAddress { baseAddress in
                    vDSP_vsubD(otherBaseAddress, 1, baseAddress, 1, outMutableBaseAddress, 1, UInt(flatmap.count))
                }
            }
        }
        
        return out
    }
    
    func sum(adding other: Matrix) -> Matrix {
        assert(hasSameDimensions(as: other), "Cannot add matrices of different dimensions")
        var out = self
        
        out.withMutableBaseAddress { outMutableBaseAddress in
            other.withBaseAddress { otherBaseAddress in
                withBaseAddress { baseAddress in
                    vDSP_vaddD(baseAddress, 1, otherBaseAddress, 1, outMutableBaseAddress, 1, UInt(flatmap.count))
                }
            }
        }
        
        return out
    }
    
    func leftMultiply(by lhs: Matrix) -> Matrix {
        
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
    
}
