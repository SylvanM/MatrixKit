//
//  FieldElement.swift
//
//
//  Created by Sylvan Martin on 5/12/23.
//

import Foundation

/**
 * This describes the requirements for any element of a field, usable for the entries of a matrix
 */
public protocol FieldElement: Numeric, CustomStringConvertible {
    
    // MARK: Properties
    
    /**
     * An additive identity element
     */
    static var zero: Self { get }
    
    /**
     * A multiplicative identity element
     */
    static var one: Self { get }
    
    // MARK: - Field Operations
    
    /// Additive Inverse
    static prefix func - (rhs: Self) -> Self
    
    /// The unique value such that `self.inverse * self == one`
    var inverse: Self { get }
    
    /// Field addition
    static func + (lhs: Self, rhs: Self) -> Self
    
    /// Field subtraction
    static func - (lhs: Self, rhs: Self) -> Self
     
    /// Field multiplication
    static func * (lhs: Self, rhs: Self) -> Self
    
    /// Field division
    static func / (lhs: Self, rhs: Self) -> Self
    
    /**
     * Exponentiation, or repeated multiplication
     *
     * - Returns: `self` multiplied with itself `power` times.
     */
    func pow(_ power: Int) -> Self
    
    // MARK: Mutable operations
    
    static func += (lhs: inout Self, rhs: Self)
    
    static func -= (lhs: inout Self, rhs: Self)
    
    static func *= (lhs: inout Self, rhs: Self)
    
    static func /= (lhs: inout Self, rhs: Self)
    
}

/**
 * Some default implementations
 */
public extension FieldElement {
    
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
    
}

// Float and Double should, by default, conform to this type!

extension Float: FieldElement {
    public static var one: Float { 1 }
    public var inverse: Float { 1 / self }
}

extension Double: FieldElement {
    public static var one: Double { 1 }
    public var inverse: Double { 1 / self }
}
