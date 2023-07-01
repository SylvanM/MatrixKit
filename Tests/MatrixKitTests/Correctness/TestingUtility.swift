//
//  Fields.swift
//
//  A bunch of example fields to use to test matrix computation correctness
//
//  Created by Sylvan Martin on 6/1/23.
//

import Foundation
import MatrixKit
import BigNumber

// We want to be able to generate elements from this field for testing!
protocol TestableFieldElement: Field {
    
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
 * Z mod p, where `p` is the prime `2^255 - 19`
 */
public struct ZMP: TestableFieldElement {
    
    public static let modulus: UBN = "0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed"

    public typealias RawValue = UBigNumber
    
    public static var zero: ZMP = ZMP(value: .zero)
    
    public static let one: ZMP = ZMP(value: UBN(1))
    
    public var inverse: ZMP {
        ZMP(value: value.invMod(ZMP.modulus))
    }
    
    public var description: String {
        value.description
    }
    
    // MARK: Properties
    
    public var value: UBigNumber
    
    // MARK: Initializers
    
    public init(value: UBigNumber) {
        self.value = value % ZMP.modulus
    }
    
    // MARK: Operators
    
    public static prefix func - (rhs: ZMP) -> ZMP {
        ZMP(value: modulus - rhs.value)
    }
    
    public static func * (lhs: ZMP, rhs: ZMP) -> ZMP {
        ZMP(value: (lhs.value % modulus) * (rhs.value % modulus))
    }
    
    public static func + (lhs: ZMP, rhs: ZMP) -> ZMP {
        ZMP(value: lhs.value + rhs.value)
    }
    
    public static func / (lhs: ZMP, rhs: ZMP) -> ZMP {
        lhs * rhs.inverse
    }
    
    // MARK: Utility
    
    public static func random() -> ZMP {
        ZMP(value: .random(in: 0..<modulus))
    }
    
    public static func random(in range: Range<UBigNumber>) -> ZMP {
        ZMP(value: UBigNumber.random(in: range))
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

extension Double: TestableFieldElement {
    
    static func == (lhs: Double, rhs: Double) -> Bool {
        lhs - rhs < 0.00001
    }
    
    static func random() -> Double {
        Double.random(in: -10...10)
    }
    
    
}
