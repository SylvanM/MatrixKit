//
//  TrivialFieldTesting.swift
//  
//
//  Created by Sylvan Martin on 5/31/23.
//

/*
 * The purpose of these tests is to make sure that the field-specific overrides are being used for
 * EVERY public Matrix method, subscript, and operator
 */

import XCTest
import MatrixKit

/**
 * The most basic field, where 0 = 1.
 */
struct TrivialField: FieldElement {
    
    // MARK: Properties
    
    static let zero = TrivialField()
    
    static let one = TrivialField()
    
    var inverse: TrivialField {
        TrivialField()
    }
    
    var description: String {
        "0"
    }
    
    // MARK: Operations
    
    static func * (lhs: TrivialField, rhs: TrivialField) -> TrivialField {
        TrivialField()
    }
    
    static prefix func - (rhs: TrivialField) -> TrivialField {
        rhs
    }
    
    static func + (lhs: TrivialField, rhs: TrivialField) -> TrivialField {
        TrivialField()
    }
    
}

final class TrivialFieldTesting: XCTestCase {

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

}
