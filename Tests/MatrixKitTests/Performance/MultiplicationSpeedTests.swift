//
//  MultiplicationSpeedTests.swift
//  
//
//  Created by Sylvan Martin on 12/13/22.
//

import XCTest
@testable import MatrixKit

final class MultiplicationSpeedTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testNaiveSpeed() {
        for k in 0..<32 {
            let n = Int(pow(2, Double(k)))
            
            let a = Matrix.random(rows: n, cols: n)
            let b = Matrix.random(rows: n, cols: n)
            
            _ = a.rightMultiply(onto: b)
            print(k)
        }
    }
    
    func testStrassenSpeed() {
        for k in 0..<32 {
            let n = Int(pow(2, Double(k)))
            
            let a = Matrix.random(rows: n, cols: n)
            let b = Matrix.random(rows: n, cols: n)
            
            let strassen = Matrix.strassen(lhs: a, rhs: b, minimumSize: 64)
            print(k)
        }
    }

}
