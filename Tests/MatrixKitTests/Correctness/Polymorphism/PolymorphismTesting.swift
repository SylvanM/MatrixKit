//
//  PolymorphismTesting.swift
//  
//
//  Created by Sylvan Martin on 5/12/23.
//

import XCTest
import MatrixKit

/**
 * The integers mod 2
 */
struct ZM2: FieldElement, ExpressibleByIntegerLiteral {
    
    init(integerLiteral value: Int) {
        self.value = Int(value.magnitude % 2)
    }
    
    typealias IntegerLiteralType = Int
    
    static let zero: ZM2 = 0
    static let one: ZM2 = 1
    
    var value: Int
    
    var inverse: ZM2 {
        assert(value != 0, "zero does not have an inverse")
        return 1
    }
    
    static func * (lhs: ZM2, rhs: ZM2) -> ZM2 {
        ZM2(integerLiteral: lhs.value * rhs.value)
    }
    
    static func + (lhs: ZM2, rhs: ZM2) -> ZM2 {
        ZM2(integerLiteral: (lhs.value + rhs.value) % 2)
    }
    
    static prefix func - (rhs: ZM2) -> ZM2 {
        rhs + 1
    }
    
    var description: String {
        value.description
    }
    
}

final class PolymorphismTesting: XCTestCase {
    
    typealias ZM = Matrix<ZM2>

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
        let iden = ZM.identity(forDim: 5)
        print(iden + iden)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
