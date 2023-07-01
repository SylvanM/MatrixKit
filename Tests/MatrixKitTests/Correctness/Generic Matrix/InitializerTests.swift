//
//  InitializerTests.swift
//  
//
//  Created by Sylvan Martin on 6/1/23.
//

import Foundation
import MatrixKit
import XCTest

class InitializerTests<Element: TestableFieldElement>: XCTest, MKTestSuite {    
    override func run() {
        print("Running InitializerTests with Element = \(Element.self)")
        testBasicInit()
        testArrayInit()
        testDimInit()
    }
    
    // MARK: Initializer Tests
    
    func testBasicInit() {
        let a = Matrix<Element>()
        XCTAssert(a[0, 0] == .zero)
        XCTAssert(a.colCount == a.rowCount && a.colCount == 1)
    }
    
    func testArrayInit() {
        for _ in 1...10 {
            let cols = Int.random(in: 1...100)
            let rows = Int.random(in: 1...100)
            
            var array = [[Element]](repeating: [Element](repeating: .zero, count: cols), count: rows)
            for r in 0..<rows {
                for c in 0..<cols {
                    array[r][c] = Bool.random() ? .one : .zero
                }
            }
            
            let a = Matrix(array)
            
            for r in 0..<a.rowCount {
                for c in 0..<a.colCount {
                    XCTAssert(a[r, c] == array[r][c])
                }
            }
        }
    }
    
    func testDimInit() {
        for _ in 1...10 {
            let cols = Int.random(in: 1...100)
            let rows = Int.random(in: 1...100)
            
            let a = Matrix<Element>(rows: rows, cols: cols)
            
            for r in 0..<a.rowCount {
                for c in 0..<a.colCount {
                    XCTAssert(a[r, c] == .zero)
                }
            }
        }
        
        let a = [Element](repeating: .zero, count: 10)
        print(a)
    }
    
}
