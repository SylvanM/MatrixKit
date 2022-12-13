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
        
        for k in 0..<32 {
            let n = Int(pow(2, Double(k)))
            
            let a = Matrix.random(rows: n, cols: n)

            let b = Matrix.random(rows: n, cols: n)
            
            let standard = a.defaultRightMultiply(onto: b)
            let strassen = Matrix.strassen(lhs: a, rhs: b, minimumSize: 2)
            
            let difference = (standard - strassen).magnitudeSquared
            XCTAssertLessThan(difference, 0.000001)
            
            print(k)
        }
    }
    
    func testStrassenMBlocks() {
        
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
        
        _ = Matrix.strassen(lhs: a, rhs: b, minimumSize: 2)
        
        print()
        
        print(
            Matrix([
                [6, 6],
                [5, 12]
            ]).rightMultiply(onto: Matrix([
                [10, 13],
                [8, 17]
            ]))
        )
        
        print(
            Matrix([
                [4, 12],
                [6, 14]
            ]).rightMultiply(onto: Matrix([
                [7, 5],
                [1, 8]
            ]))
        )
        
        print(
            Matrix([
                [5, 2],
                [0, 6]
            ]).rightMultiply(onto: Matrix([
                [5, -8],
                [-5, -3]
            ]))
        )
        
        print(
            Matrix([
                [2, 4],
                [5, 6]
            ]).rightMultiply(onto: Matrix([
                [2, -1],
                [4, -1]
            ]))
        )
        
        print(
            Matrix([
                [11, 3],
                [2, 6]
            ]).rightMultiply(onto: Matrix([
                [3, 8],
                [7, 9]
            ]))
        )
        
        print(
            Matrix([
                [-2, 6],
                [1, 2]
            ]).rightMultiply(onto: Matrix([
                [15, 5],
                [3, 14]
            ]))
        )
        
        print(
            Matrix([
                [5, -3],
                [-3, -6]
            ]).rightMultiply(onto: Matrix([
                [12, 12],
                [12, 12]
            ]))
        )
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
