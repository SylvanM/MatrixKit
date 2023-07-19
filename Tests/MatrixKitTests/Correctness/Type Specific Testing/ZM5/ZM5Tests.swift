//
//  ZM5Tests.swift
//  
//
//  Created by Sylvan Martin on 7/11/23.
//

import XCTest
import MatrixKit

final class ZM5Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLUDecomp() throws {
        let matrix: Matrix<ZM5> = [
            [0, 0, 4],
            [3, 3, 0],
            [4, 1, 2]
        ]
        
        let (_, permutation, lower, upper) = matrix.luDecomposition
        
        XCTAssertEqual(permutation * matrix, lower * upper)
    }

}
