//
//  DoingMyHomework.swift
//  
//
//  Created by Sylvan Martin on 9/12/22.
//

import XCTest
import MatrixKit

class DoingMyHomework: XCTestCase {

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
        
        let S: Matrix = [
            [4, 0],
            [-1, 5],
            [2, 6],
            [3, -1]
        ]
        
        let T: Matrix = [
            [1, -1, 2, -7],
            [4, 0, 6, 5],
            [-1, -2, 8, -3]
        ]
        
        let ToS = T * S
        
        print(ToS)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
