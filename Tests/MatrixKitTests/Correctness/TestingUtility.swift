//
//  Fields.swift
//
//  A bunch of example fields to use to test matrix computation correctness
//
//  Created by Sylvan Martin on 6/1/23.
//

import Foundation
import MatrixKit



// We want to be able to generate elements from this field for testing!
protocol TestableFieldElement: FieldElement {
    
    static func random() -> Self
    
}

// We want to be able to generate a random matrix for testing
extension Matrix where Element: TestableFieldElement {
    
    static func random(rows: Int, cols: Int) -> Matrix {
        Matrix(rows: rows, cols: cols) { _, _ in
            Element.random()
        }
    }
    
}


/**
 * The trivial field where 0 = 1
 */
struct TrivialField: TestableFieldElement {
    
    static let one = TrivialField()
    static let zero = TrivialField()
    
    var inverse: TrivialField {
        TrivialField()
    }
    
    var description: String {
        "0"
    }
    
    static func + (lhs: TrivialField, rhs: TrivialField) -> TrivialField {
        TrivialField()
    }
    
    static prefix func - (rhs: TrivialField) -> TrivialField {
        TrivialField()
    }
    
    static func * (lhs: TrivialField, rhs: TrivialField) -> TrivialField {
        TrivialField()
    }
    
    static func random() -> TrivialField {
        TrivialField()
    }
    
}

/**
 * The field of the integers mod 5
 */
struct ZM5: TestableFieldElement, ExpressibleByIntegerLiteral {
    
    typealias IntegerLiteralType = Int
    
    static let zero = ZM5(value: 0)
    static let one = ZM5(value: 1)
    
    /**
     * - Invariant: `value` is between `0` and `4`, inclusive
     */
    var value: Int
    
    var inverse: ZM5 {
        switch value {
        case 1:
            return ZM5(value: 1)
        case 2:
            return ZM5(value: 3)
        case 3:
            return ZM5(value: 2)
        case 4:
            return ZM5(value: 4)
        default:
            fatalError("Cannot invert 0! (or invalid input)")
        }
    }
    
    var description: String {
        String(value)
    }
    
    init(value: Int) {
        self.value = value % 5
    }
    
    init(integerLiteral value: Int) {
        self.value = value % 5
    }
    
    static func * (lhs: ZM5, rhs: ZM5) -> ZM5 {
        ZM5(value: (lhs.value * rhs.value) % 5)
    }
    
    static prefix func - (rhs: ZM5) -> ZM5 {
        ZM5(value: (5 - rhs.value) % 5)
    }
    
    static func + (lhs: ZM5, rhs: ZM5) -> ZM5 {
        ZM5(value: (lhs.value + rhs.value) % 5)
    }
    
    static func random() -> ZM5 {
        ZM5(value: Int.random(in: 0...4))
    }
    
}

/**
 * A field type which is a facade for a `Double` to test regular `Double` operations but forcing `Matrix` to use the generic implementations
 *
 * This also overrides `equals` to account for precision error in matrix multiplication when testing. Basically, we only care abourt precision to like 5 decimal places.
 * Again, this is only for testing!!!! not anything erlse please!
 */
struct SillyDouble: TestableFieldElement, ExpressibleByFloatLiteral {
    
    typealias FloatLiteralType = Double
    
    static let zero = SillyDouble(value: 0)
    static let one = SillyDouble(value: 1)
    
    var value: Double
    
    var inverse: SillyDouble {
        SillyDouble(value: 1 / value)
    }
    
    var description: String {
        value.description
    }
    
    init(value: Double) {
        self.value = value
    }
    
    init(floatLiteral value: Double) {
        self.value = value
    }
    
    static func * (lhs: SillyDouble, rhs: SillyDouble) -> SillyDouble {
        SillyDouble(value: lhs.value * rhs.value)
    }
    
    static prefix func - (rhs: SillyDouble) -> SillyDouble {
        SillyDouble(value: -(rhs.value))
    }
    
    static func + (lhs: SillyDouble, rhs: SillyDouble) -> SillyDouble {
        SillyDouble(value: lhs.value + rhs.value)
    }
    
    static func random() -> SillyDouble {
        SillyDouble(value: Double.random(in: -10...10))
    }
    
    static func == (lhs: SillyDouble, rhs: SillyDouble) -> Bool {
        (lhs - rhs).value.magnitude < 0.00001
    }
    
}
