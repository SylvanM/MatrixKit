//
//  OperatorTests.swift
//
//
//  Created by Sylvan Martin on 6/1/23.
//

import Foundation
import MatrixKit
import XCTest

class OperatorTests<Element: TestableFieldElement>: XCTest, MKTestSuite {
    
    override func run() {
        print("Running OperatorTests with Element = \(Element.self)")
        testAdd()
        testSub()
        testMul()
    }
    
    // MARK: Operator Tests

    func testAdd() {
        print("testing ADD")
        
        let cols = Int.random(in: 10...100)
        let rows = Int.random(in: 10...100)
        
        let A = Matrix<Element>.random(rows: rows, cols: cols)
        let B = Matrix<Element>.random(rows: rows, cols: cols)
        
        XCTAssert(A + Matrix<Element>(rows: rows, cols: cols) == A, "Adding to 0 should yield itself")
        
        // now check individual entries for element-wise comparison
        
        let C = A + B
        
        for r in 0..<rows {
            for c in 0..<cols {
                XCTAssertEqual(C[r, c], A[r, c] + B[r, c])
            }
        }
        
        XCTAssert(C.hasSameDimensions(as: A))
    }
    
    func testSub() {
        print("testing SUB")
        let cols = Int.random(in: 10...100)
        let rows = Int.random(in: 10...100)
        
        let A = Matrix<Element>.random(rows: rows, cols: cols)
        let B = Matrix<Element>.random(rows: rows, cols: cols)
        
        XCTAssert(A - Matrix<Element>(rows: rows, cols: cols) == A, "Subtracting 0 should yield itself")
        
        // now check individual entries for element-wise comparison
        
        let C = A - B
        
        for r in 0..<rows {
            for c in 0..<cols {
                XCTAssertEqual(C[r, c], A[r, c] - B[r, c])
            }
        }
        
        XCTAssert(C.hasSameDimensions(as: A))
    }
    
    func testMul() {
        print("testing MUL")
        
        let rows = Int.random(in: 5...5)
        let innerDim1 = Int.random(in: 5...5)
        let innerDim2 = Int.random(in: 5...5)
        let cols = Int.random(in: 5...5)
        
        let A = Matrix<Element>.random(rows: rows, cols: innerDim1)
        let B = Matrix<Element>.random(rows: innerDim1, cols: innerDim2)
        var C = Matrix<Element>.random(rows: innerDim2, cols: cols)
        
        XCTAssertEqual(A * Matrix.identity(forDim: A.colCount), A, "Multiplying identity test")
        XCTAssertEqual(Matrix.identity(forDim: A.rowCount) * A, A, "Multiplying identity test")
        XCTAssertEqual(B * Matrix.identity(forDim: B.colCount), B, "Multiplying identity test")
        XCTAssertEqual(Matrix.identity(forDim: B.rowCount) * B, B, "Multiplying identity test")
        
        XCTAssertEqual(A * B * C, A * (B * C))
        XCTAssertEqual(A * B * C, (A * B) * C)
        
        C = Matrix<Element>.random(rows: innerDim1, cols: innerDim2)
        
        XCTAssertEqual(A * (B + C), A * B + A * C)
        
        for i in 1...100 {
            print(i)
            let matrix = Matrix<Element>.random(rows: rows, cols: rows)
            if matrix.determinant == .zero { continue }
            XCTAssertEqual(matrix.inverse * matrix, .identity(forDim: rows))
            XCTAssertEqual(matrix * matrix.inverse, .identity(forDim: rows))
        }
        
    }

}
