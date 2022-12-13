//
//  StrassenTests.swift
//  
//
//  Created by Sylvan Martin on 12/12/22.
//

import XCTest
@testable import MatrixKit

final class StrassenTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
        let k = 2 //Int.random(in: 2...10)
        let n = Int(pow(2, Double(k)))
        
        let a: Matrix = [
            [5, 2, 6, 1],
            [0, 6, 2, 0],
            [3, 8, 1, 4],
            [1, 8, 5, 6]
        ]
        
        let b: Matrix = [
            [7, 5, 8, 0],
            [1, 8, 2, 6],
            [9, 4, 3, 8],
            [5, 3, 7, 9]
        ]
        
        let standard = a.defaultRightMultiply(onto: b)
        let strassen = Matrix.strassen(lhs: a, rhs: b, minimumSize: 2)
        
        print(strassen)
        print()
        print(standard)
        
        let difference = (standard - strassen).magnitudeSquared
        
        print(difference)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
