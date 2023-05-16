//
//  Double+Operations.swift
//  
//
//  Created by Sylvan Martin on 5/12/23.
//

import Foundation
import Accelerate

public extension Matrix where Element == Double {
    
    /**
     * Computes the distance squared between two matrices as if their flat maps were vectors
     *
     * - Precondition: `self.rowCount == other.rowCount && self.colCount == other.colCount`
     * - Parameter other: A matrix to compute the distance squared from
     * - Returns: A nonnegative number representing how far off these matrices are from each other, squared
     */
    func distanceSquared(from other: Matrix) -> Element {
        assert(hasSameDimensions(as: other), "Cannot find distance between matrices of different dimensions")
        var ds: Double = 0
        
        other.withBaseAddress { otherBaseAddress in
            withBaseAddress { baseAddress in
                vDSP_distancesqD(baseAddress, 1, otherBaseAddress, 1, &ds, UInt(count))
            }
        }
        
        return ds
    }
    
    /**
     * Computes the distance between two matrices as if their flat maps were vectors
     *
     * - Precondition: `self.rowCount == other.rowCount && self.colCount == other.colCount`
     * - Parameter other: A matrix to compute the distance from
     * - Returns: A nonnegative number representing how far off these matrices are from each other
     */
    func distance(from other: Matrix) -> Element {
        sqrt(distanceSquared(from: other))
    }
    
    /**
     * Computes the magnitude squared of this matrix. That is, the sum of the squares of all elements of the matrix
     */
    internal func computeMagnitudeSquared() -> Double {
        withBaseAddress { baseAddress in
            // TODO: Right now this can only take a 32 bit integer as the size, so eventally might have to
            // split the computation up for larger vectors.
            cblas_dnrm2(Int32(count), baseAddress, 1)
        }
    }
    
    /**
     * Computes the magnitude of this matrix
     */
    internal func computeMagnitude() -> Double {
        sqrt(computeMagnitudeSquared())
    }
    
    /**
     * Scales every this matrix by the multiplicative inverse of `self.magnitude`, so that the new magnitude is 1.
     */
    mutating func normalize() {
        if magnitude.isZero { return }
        scale(by: 1 / magnitude)
    }
    
    // MARK: - Matrix Operations
    
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
        
        print("Using DOUBLE mult")
        
        
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
    
    func rightMultiply(onto rhs: Matrix) -> Matrix {
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
    
    // MARK: - Misc Operations
    
    internal func computeTranspose(result: inout Matrix) {
        withBaseAddress { baseAddress in
            result.withMutableBaseAddress { resultAddress in
                vDSP_mtransD(baseAddress, 1, resultAddress, 1, UInt(colCount), UInt(rowCount))
            }
        }
    }
    
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
