//
//  Matrix+Operators.swift
//  
//
//  Created by Sylvan Martin on 6/15/22.
//

import Foundation

precedencegroup ExponentiationPrecedence {
  associativity: right
  higherThan: MultiplicationPrecedence
}

infix operator ~ : ComparisonPrecedence

public extension Matrix {
    
    // MARK: Comparison Operators
    
    static func == (lhs: Matrix, rhs: Matrix) -> Bool {
        lhs.equals(rhs)
    }
    
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

public extension Matrix where Element: Field {
    
    static func ~ (lhs: Matrix, rhs: Matrix) -> Bool {
        lhs.isRowEquivalent(to: rhs)
    }
    
}

fileprivate extension Matrix {
    
    // MARK: - Comparisons
    
    /**
     * Returns `true` if this matrix is equivalent to another matrix.
     */
    func equals(_ other: Matrix) -> Bool {
        self.colCount == other.colCount && self.flatmap == other.flatmap
    }
    
    // MARK: Matrix Operations
    
    /**
     * Scales every element of this matrix by a scalar, in place.
     *
     * - Parameter scalar: `Element` by which to scale every element of this matrix.
     */
    mutating func scale(by scalar: Element) {
        for i in 0..<flatmap.count {
            flatmap[i] *= scalar
        }
    }
    
    /**
     * The result of scaling this matrix by a scalar, out of place.
     *
     * - Parameter scalar: `Double` by which to scale every element of this matrix
     * - Returns: The result of scaling this matrix by a scalar.
     */
    func scaled(by scalar: Element) -> Matrix {
        var out = self
        out.scale(by: scalar)
        return out
    }
    
    /**
     * Adds every element of another matrix to the corresponding element of this matrix, in place.
     *
     * - Precondition: `self.rowCount == other.rowCount && self.colCount == other.colCount`
     * - Parameter other: `Matrix` to add.
     */
    mutating func add(_ other: Matrix) {
        assert(hasSameDimensions(as: other), "Cannot add matrices of different dimensions")
        
        for i in 0..<flatmap.count {
            flatmap[i] += other.flatmap[i]
        }
    }
    
    /**
     * Subtracts every element of another matrix to the corresponding element of this matrix, in place.
     *
     * - Precondition: `self.rowCount == other.rowCount && self.colCount == other.colCount`
     * - Parameter other: `Matrix` to subtract.
     */
    mutating func subtract(_ other: Matrix) {
        assert(hasSameDimensions(as: other), "Cannot subtract matrices of different dimensions")
        
        for i in 0..<flatmap.count {
            flatmap[i] -= other.flatmap[i]
        }
    }
    
    /**
     * Subtracts the values of another matrix from this matrix, out of place
     *
     * - Precondition: `self.colCount == other.colCount && self.rowCount == other.rowCount`
     * - Parameter other: `Matrix` to subtract.
     * - Returns: The difference of this matrix and `other`.
     */
    func difference(subtracting other: Matrix) -> Matrix {
        assert(hasSameDimensions(as: other), "Cannot subtract matrices of different dimensions")
        
        var out = self
        out.subtract(other)
        return out
    }
    
    /**
     * Adds the values of another matrix to this matrix, out of place.
     *
     * - Precondition: `self.colCount == other.colCount && self.rowCount == other.rowCount`
     * - Parameter other: `Matrix` to add
     * - Returns: The sum of `self` and `other`.
     */
    func sum(adding other: Matrix) -> Matrix {
        assert(hasSameDimensions(as: other), "Cannot add matrices of different dimensions")
        
        var out = self
        out.add(other)
        return out
    }
    
    /**
     * Multiplies this matrix by another matrix on the left.
     *
     * This performs the matrix multiplication `lhs * self`.
     *
     * - Precondition: `lhs.colCount == self.rowCount`
     *
     * - Parameter lhs: `Matrix` by which to multiply
     * - Returns: The matrix product `lhs * self`
     */
    func leftMultiply(by lhs: Matrix) -> Matrix {
        assert(lhs.colCount == self.rowCount, "Invalid dimensions for matrix multiplcation")
        
        var product = Matrix(rows: lhs.rowCount, cols: self.colCount)
        
        for r in 0..<product.rowCount {
            for c in 0..<product.colCount {
                product[r, c] = lhs[row: r].dotProduct(with: self[col: c])
            }
        }
        
        return product
    }
    
}

fileprivate extension Matrix where Element: Field {
    
    /**
     * Returns `true` if `other` can be obtained by applying row operations to `self`
     */
    func isRowEquivalent(to other: Matrix) -> Bool {
        self.rank == other.rank && (self.colCount, self.rowCount) == (other.colCount, other.colCount)
    }
    
}
