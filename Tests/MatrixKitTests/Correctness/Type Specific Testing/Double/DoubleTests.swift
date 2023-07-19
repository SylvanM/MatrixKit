//
//  DoubleTests.swift
//  
//
//  Created by Sylvan Martin on 7/5/23.
//

import XCTest
import MatrixKit

final class DoubleTests: XCTestCase {

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
    
    func testLUDecomp() throws {
        let matrix: Matrix<Double> = [
            [2, 4, -1, 5, -2],
            [-4, -5, 3, -8, 1],
            [2, -5, -4, 1, 8],
            [6, 0, 7, -3, 1]
        ]
        
        let (_, perm, _, _) = matrix.luDecomposition
        
        let swapped = perm * matrix
        
        let (_, newPerm, lowerNoSwap, refNoSwap) = swapped.luDecomposition
        
        XCTAssertEqual(newPerm * swapped, lowerNoSwap * refNoSwap)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
