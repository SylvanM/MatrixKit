//
//  FieldElement.swift
//
//
//  Created by Sylvan Martin on 5/12/23.
//

import Foundation

/**
 * This describes the axioms of a ring
 */
public protocol Ring: Equatable, CustomStringConvertible, AdditiveArithmetic {
    
    // MARK: Properties
    
    /**
     * An additive identity element
     */
    static var zero: Self { get }
    
    /**
     * A multiplicative identity element
     */
    static var one: Self { get }
    
    // MARK: Ring Operations
    
    /// Additive Inverse
    static prefix func - (rhs: Self) -> Self
    
    /// Ring addition
    static func + (lhs: Self, rhs: Self) -> Self
    
    /// Ring subtraction
    static func - (lhs: Self, rhs: Self) -> Self
    
    /// Ring multiplication
    static func * (lhs: Self, rhs: Self) -> Self
    
    /**
     * Exponentiation, or repeated multiplication
     *
     * - Returns: `self` multiplied with itself `power` times.
     */
    func pow(_ power: Int) -> Self
    
    // MARK: Mutable Operations
    
    static func += (lhs: inout Self, rhs: Self)
    
    static func -= (lhs: inout Self, rhs: Self)
    
    static func *= (lhs: inout Self, rhs: Self)
    
}

public extension Ring {
    
    // MARK: Implied Definitions
    
    static func - (lhs: Self, rhs: Self) -> Self {
        lhs + (-rhs)
    }
    
    func pow(_ power: Int) -> Self {
        var out = Self.one
        
        for _ in 0..<power {
            out *= self
        }
        
        return out
    }
    
    // MARK: Mutating Definitions
    
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
     
    static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
    
    static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
    
}

/**
 * This describes the requirements for any element of a field, usable for the entries of a matrix
 */
public protocol Field: Ring {
    
    // MARK: - Field Operations
    
    /// The unique value such that `self.inverse * self == one`
    var inverse: Self { get }
    
    /// Field division
    static func / (lhs: Self, rhs: Self) -> Self
    
    // MARK: Mutable operations
    
    static func /= (lhs: inout Self, rhs: Self)
    
}

/**
 * Some default implementations
 */
public extension Field {
    
    // MARK: Implied Definitions
    
    static func / (lhs: Self, rhs: Self) -> Self {
        return lhs * (rhs.inverse)
    }
    
    // MARK: Mutating Definitions
    
    static func /= (lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }
    
}

// MARK: - Built-in Conforming Types

extension Float: Field {
    public static var one: Float { 1 }
    public var inverse: Float { 1 / self }
}

extension Double: Field {
    public static var one: Double { 1 }
    public var inverse: Double { 1 / self }
}

extension Int: Ring {
    public static var one: Int { 1 }
}
