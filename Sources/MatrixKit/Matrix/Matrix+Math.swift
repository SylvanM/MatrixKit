//
//  Matrix+Math.swift
//  
//
//  Created by Sylvan Martin on 6/15/22.
//

import Foundation
import simd
import Accelerate

public extension Matrix {
    
    // MARK: - Comparisons
    
    func equals(_ other: Matrix) -> Bool {
        self.colCount == other.colCount && self.flatmap == other.flatmap
    }
    
    /**
     * Returns `true` if `other` can be obtained by applying row operations to `self`
     */
    func isRowEquivalent(to other: Matrix) -> Bool {
        self.rank == other.rank
    }
    
    // MARK: - Matrix Math
    
    /**
     * Computes the determinant of a matrix
     *
     * - Precondition: `isSquare` and `colCount >= 1`
     */
    var determinant: Element {
        
        // if at any point this is a matrix that can be converted to a SIMD type, USE THAT!
        
        switch colCount {
        case 4:
            
            return simd_double4x4(
                simd_double4(flatmap[0], flatmap[4], flatmap[8], flatmap[12]),
                simd_double4(flatmap[1], flatmap[5], flatmap[9], flatmap[13]),
                simd_double4(flatmap[2], flatmap[6], flatmap[10], flatmap[14]),
                simd_double4(flatmap[3], flatmap[7], flatmap[11], flatmap[15])
            ).determinant
            
        case 3:
            
            return simd_double3x3(
                simd_double3(flatmap[0], flatmap[3], flatmap[6]),
                simd_double3(flatmap[1], flatmap[4], flatmap[7]),
                simd_double3(flatmap[2], flatmap[5], flatmap[8])
            ).determinant

        case 2:
            
            return simd_double2x2(
                simd_double2(flatmap[0], flatmap[2]),
                simd_double2(flatmap[1], flatmap[3])
            ).determinant
            
        case 1: return flatmap[0]
            
        default: // the recursive case!
            // Idea: Maybe search and see if there's a particular row/column that has a lot of zeros, and do co-factor expansion along that?
            var sum: Element = 0
            
            for i in 0..<colCount {
                var scalar = self[0, i]
                let submatrix = omitting(row: 0).omitting(col: i)
                let det = submatrix.determinant
                
                if i % 2 == 0 {
                    scalar = -scalar
                }
                
                sum += scalar * det
            }
            
            return sum
        }
            
    }
    
    var rowEchelon: Matrix {
        #warning("Unimplemented - rowEchelon")
        return self
    }
    
    var reducedRowEchelon: Matrix {
        #warning("Unimplemented - reducedRowEchelon")
        return self
    }
    
    var rank: Int {
        #warning("Unimplemented - rank")
        return 1
    }
    
    // MARK: Matrix Operations
    
    
    
    /**
     * Applies a row operation on this matrix
     */
    #warning("lazy implementation")
    mutating func apply(rowOperation: ElementaryOperation) {
        
        switch rowOperation {
        case .scale(let row, let scalar_c):
            
            for i in (colCount * row)..<((colCount + 1) * row) {
                flatmap[i] *= scalar_c
            }
            
        case .swap(let rowA, let rowB):
            
            let tempRow = self[rowA]
            self[rowA] = self[rowB]
            self[rowB] = tempRow

        case .add(let scalar, let index, let toIndex):
            
            for i in 0..<colCount {
                self[toIndex][i] += scalar * self[index][i]
            }
            
        }
    }
    
    mutating func apply(columnOperation: ElementaryOperation) {
        
        switch columnOperation {
            
        case .scale(let col, let scalar):
            
            for i in 0..<rowCount {
                flatmap[i * colCount + col] *= scalar
            }
            
        case .swap(let colA, let colB):
            
            let tempCol = self[col: colA]
            self[col: colA] = self[col: colB]
            self[col: colB] = tempCol
            
        case .add(let scalar, let index, let toIndex):
            
            for i in 0..<rowCount {
                self[col: toIndex][i] += scalar * self[col: index][i]
            }
            
        }
        
    }
    
    func applying(rowOperation: ElementaryOperation) -> Matrix {
        var new = self
        new.apply(rowOperation: rowOperation)
        return new
    }
    
    func applying(columnOperation: ElementaryOperation) -> Matrix {
        var new = self
        new.apply(columnOperation: columnOperation)
        return new
    }
    
    mutating func scale(by scalar: Double) {
//        var scalar_p = scalar
//        vDSP_vsmulD(bufferPointer.baseAddress!, 1, &scalar_p, bufferPointer.baseAddress!, 1, vDSP_Length(flatmap.count))
        
        for i in 0..<flatmap.count {
            flatmap[i] *= scalar
        }
    }
    
    func scaled(by scalar: Double) -> Matrix {
        var new = self
        new.scale(by: scalar)
        return new
    }
    
    mutating func add(_ other: Matrix) {
        for i in 0..<flatmap.count {
            flatmap[i] += other.flatmap[i]
        }
    }
    
    mutating func subtract(_ other: Matrix) {
        for i in 0..<flatmap.count {
            flatmap[i] -= other.flatmap[i]
        }
    }
    
    /**
     * Subtracts the values of another matrix from this matrix, out of place
     *
     * - Precondition: `self.colCount == other.colCount && self.rowCount == other.rowCount`
     */
    func difference(subtracting other: Matrix) -> Matrix {
        if #available(macOS 10.15, *) {
            let diff = vDSP.subtract(self.flatmap, other.flatmap)
            return Matrix(flatmap: diff, cols: colCount)
        } else {
            let sum = zip(self.flatmap, other.flatmap).map { (x, y) in
                x - y
            }
            return Matrix(flatmap: sum, cols: self.colCount)
        }
    }
    
    /**
     * Adds the values of another matrix to this matrix, out of place.
     *
     * - Precondition: `self.colCount == other.colCount && self.rowCount == other.rowCount`
     */
    func sum(adding other: Matrix) -> Matrix {
        if #available(macOS 10.15, *) {
            let sum = vDSP.add(self.flatmap, other.flatmap)
            return Matrix(flatmap: sum, cols: self.colCount)
        } else {
            let sum = zip(self.flatmap, other.flatmap).map { (x, y) in
                x + y
            }
            return Matrix(flatmap: sum, cols: self.colCount)
        }
    }
    
    func leftMultiply(by lhs: Matrix) -> Matrix {
        
        // this is LUDICROUSLY slow and is ONLY temporary
        
        var product = Matrix(rows: lhs.rowCount, cols: self.colCount)
        
        for i in 0..<product.rowCount {
            for j in 0..<product.colCount {
                
                var sum: Double = 0
                
                for k in 0..<lhs.colCount {
                    sum += lhs[i, k] * self[k, i]
                }
                
                product[i, j] = sum
                
            }
        }
        
        return product
    }
    
    func rightMultiply(onto rhs: Matrix) -> Matrix {
        rhs.leftMultiply(by: self)
    }
    
}
