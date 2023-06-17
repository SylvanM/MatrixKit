//
//  MathPropertiesTest.swift
//  
//
//  Created by Sylvan Martin on 6/3/23.
//

import Foundation
import MatrixKit
import XCTest

class MathPropertiesTest<Element: TestableFieldElement>: XCTest, MKTestSuite {
    
    override func run() {
        testKernel()
        testLinearOperation()
    }
    
    // MARK: Math Tests
    
    func testLinearOperation() {
        // If a matrix A truly is a linear operation, then we expect, for any a, b, V, U
        for _ in 1...10 {
            let A = Matrix<Element>.random(rows: .random(in: 1...100), cols: .random(in: 1...100))
            let a = Element.random()
            let b = Element.random()
            let V = Matrix<Element>.random(rows: A.colCount, cols: 1)
            let U = Matrix<Element>.random(rows: A.colCount, cols: 1)
            
            XCTAssertEqual(
                A * ( (a * V) + (b * U) ),
                (a * (A * V)) + (b * (A * U))
            )
        }
    }
    
    func testKernel() {
        
        // generate a matrix, generate its kernel, and make sure everything goes to zero.
        
        for _ in 1...10 {
            let matrix = Matrix<Element>.random(rows: Int.random(in: 1...100), cols: Int.random(in: 1...100))
            let kernel = matrix.kernel
            XCTAssert((matrix * kernel).isZero)
        }
        
    }
    
}
