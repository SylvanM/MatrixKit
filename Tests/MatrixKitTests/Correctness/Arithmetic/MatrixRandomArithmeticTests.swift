//
//  MatrixRandomArithmeticTests.swift
//  
//
//  Created by Sylvan Martin on 7/19/22.
//
//  Contains tests for basic properties of matrix arithmetic
//

import XCTest
import MatrixKit

class MatrixRandomArithmeticTests: XCTestCase {
    
    let accuracy: Double = 1e-5
    let range: ClosedRange<Double> = 0...10000000

    func testDistributiveProperty() throws {
        
        var maxError: Double = 0
        
        for _ in 1...10000 {
            
            let n = Int.random(in: 1...100)
            let m = Int.random(in: 1...100)
            let p = Int.random(in: 1...100)
            
            let a = Matrix.random(rows: n, cols: m, range: range)
            let b = Matrix.random(rows: m, cols: p, range: range)
            let c = Matrix.random(rows: m, cols: p, range: range)
            
            let e1 = a * (b + c)
            let e2 = (a * b) + (a * c)
            
            let error = e1.distanceSquared(from: e2)
            
            XCTAssertEqual(e1.rowCount, n)
            XCTAssertEqual(e1.colCount, p)
            XCTAssertLessThanOrEqual(error, accuracy)
            
            if error > maxError {
                maxError = error
            }
        }
        
        print("Maximum error: \(maxError)")
        
    }
    
    func testScalarDistProp() throws {
        
        var maxError: Double = 0

        for _ in 1...10000 {

            let n = Int.random(in: 1...100)
            let m = Int.random(in: 1...100)

            let a = Matrix.Element.random(in: range)
            let b = Matrix.random(rows: n, cols: m, range: range)
            let c = Matrix.random(rows: n, cols: m, range: range)

            let e1 = a * (b + c)
            let e2 = (a * b) + (a * c)
            
            let error = e1.distanceSquared(from: e2)

            XCTAssertLessThan(error, accuracy)
            
            if error > maxError {
                maxError = error
            }

        }
        
        print("Maximum error: \(maxError)")

    }
    
    

}
