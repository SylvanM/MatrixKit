//
//  Matrix+Operators.swift
//  
//
//  Created by Sylvan Martin on 6/15/22.
//

import Foundation

infix operator ~ : ComparisonPrecedence

public extension Matrix {
    
    // MARK: Comparison Operators
    
    static func == (lhs: Matrix, rhs: Matrix) -> Bool {
        lhs.equals(rhs)
    }
    
    static func ~ (lhs: Matrix, rhs: Matrix) -> Bool {
        lhs.isRowEquivalent(to: rhs)
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
