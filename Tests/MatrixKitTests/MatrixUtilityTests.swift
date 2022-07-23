//
//  MatrixUtilityTests.swift
//  
//
//  Created by Sylvan Martin on 7/14/22.
//

import XCTest
import MatrixKit

class MatrixUtilityTests: XCTestCase {

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

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testDeprecationLabels() throws {
        
    }
    
    func testSubmatrixSubscript() throws {
        
        var b2: Matrix = [
            [0, 0, 0, 1, 2],
            [3, 0, 0, 1, 2],
            [0, 0, 2, 1, 0]
        ]
        
        let c2: Matrix = [
            [9, 2],
            [5, 2],
            [1, 1]
        ]
        
        b2[0..<3, 1..<3] = c2
        
        XCTAssertEqual(b2, [
            [0, 9, 2, 1, 2],
            [3, 5, 2, 1, 2],
            [0, 1, 1, 1, 0]
        ])
        
        XCTAssertEqual(b2[1..<2, 2..<4], [[2, 1]])
    }
    
    func testConcatenating() throws {
        let a: Matrix = [
            [0, 1],
            [2, 3],
            [4, 5]
        ]
        
        let b1: Matrix = [
            [-1],
            [-2],
            [-3]
        ]
        
        let b2: Matrix = [
            [0, 0, 0, 1, 2],
            [3, 0, 0, 1, 2],
            [0, 0, 2, 1, 0]
        ]
        
        let c1: Matrix = [
            [-1, 0]
        ]
        
        let c2: Matrix = [
            [9, 2],
            [5, 2],
            [1, 1]
        ]
        
        XCTAssertEqual(a.sideConcatenating(b1), [
            [0, 1, -1],
            [2, 3, -2],
            [4, 5, -3]
        ])
        
        XCTAssertEqual(a.sideConcatenating(b2), [
            [0, 1, 0, 0, 0, 1, 2],
            [2, 3, 3, 0, 0, 1, 2],
            [4, 5, 0, 0, 2, 1, 0]
        ])
        
        XCTAssertEqual(a.bottomConcatenating(c1), [
            [0, 1],
            [2, 3],
            [4, 5],
            [-1, 0]
        ])
        
        XCTAssertEqual(a.bottomConcatenating(c2), [
            [0, 1],
            [2, 3],
            [4, 5],
            [9, 2],
            [5, 2],
            [1, 1]
        ])
        
    }

}
