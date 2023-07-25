//
//  GenericPerformanceTests.swift
//  
//
//  Created by Sylvan Martin on 7/2/23.
//

import XCTest
import MatrixKit

struct OperationCounter: Field {
    
    var inverse: OperationCounter {
        OperationCounter.inversions += 1
        return OperationCounter()
    }
    
    static let zero = OperationCounter()
    
    static let one = OperationCounter()
    
    static func * (lhs: OperationCounter, rhs: OperationCounter) -> OperationCounter {
        OperationCounter.multiplications += 1
        return OperationCounter()
    }
    
    static prefix func - (rhs: OperationCounter) -> OperationCounter {
        OperationCounter.negations += 1
        return OperationCounter()
    }
    
    static func + (lhs: OperationCounter, rhs: OperationCounter) -> OperationCounter {
        OperationCounter.additions += 1
        return OperationCounter()
    }
    
    var description: String { "Dummy value" }
    
    var squareRoot: OperationCounter {
        OperationCounter()
    }
    
    static var negations: UInt = 0
    static var additions: UInt = 0
    static var subtractions: UInt = 0
    static var multiplications: UInt = 0
    static var inversions: UInt = 0
    
    static func printStats() {
        print("In current runtime, this type has witnessed:")
        print("\(negations) negations")
        print("\(additions) additions")
        print("\(subtractions) subtractions")
        print("\(multiplications) multiplications")
        print("\(inversions) inversions")
    }
    
}

final class GenericPerformanceTests_2: XCTestCase {

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
        
        let n = 100
        
        let a = Matrix<OperationCounter>(rows: n, cols: n)
        
        _ = a * a
        
        OperationCounter.printStats()
    }

}
