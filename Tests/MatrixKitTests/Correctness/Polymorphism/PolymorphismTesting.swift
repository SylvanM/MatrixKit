//
//  PolymorphismTesting.swift
//  
//
//  Created by Sylvan Martin on 5/12/23.
//

import XCTest
import MatrixKit

/**
 * The integers mod 13
 */
struct ZM5: FieldElement, ExpressibleByIntegerLiteral {
    
    init(integerLiteral value: Int) {
        self.value = Int(value.magnitude % 5)
    }
    
    typealias IntegerLiteralType = Int
    
    static let zero: ZM5 = 0
    static let one: ZM5 = 1
    
    var value: Int
    
    var inverse: ZM5 {
        assert(value != 0, "zero does not have an inverse")
        // could do extgcd, but no
        switch value {
        case 1:
            return 1
        case 2:
            return 3
        case 3:
            return 2
        case 4:
            return 4
        default:
            assert(value != 0, "zero does not have an inverse")
            return -1
        }
    }
    
    static func * (lhs: ZM5, rhs: ZM5) -> ZM5 {
        ZM5(integerLiteral: (lhs.value * rhs.value) % 5)
    }
    
    static func + (lhs: ZM5, rhs: ZM5) -> ZM5 {
        ZM5(integerLiteral: (lhs.value + rhs.value) % 5)
    }
    
    static prefix func - (rhs: ZM5) -> ZM5 {
        ZM5(integerLiteral: 5 - rhs.value)
    }
    
    var description: String {
        value.description
    }
    
}

final class PolymorphismTesting: XCTestCase {
    
    typealias ZM = Matrix<ZM5>

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
        let rand = ZM(rows: 3, cols: 3) { _,_  in
            ZM5(integerLiteral: Int.random(in: 0..<5))
        }
        
        print(rand)
        print(rand + rand)
        
        print(rand.reducedRowEchelonForm)
        print(rand.inverse)
        print(rand.inverse * rand)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
