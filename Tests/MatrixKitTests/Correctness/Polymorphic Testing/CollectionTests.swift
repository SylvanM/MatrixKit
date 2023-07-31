//
//  CollectionTests.swift
//
//
//  Created by Sylvan Martin on 7/5/23.
//

import Foundation
import MatrixKit
import XCTest

class CollectionTests<Element: TestableFieldElement>: XCTest, MKTestSuite {
    
    override func run() {
        print("Running CollectionTests with Element = \(Element.self)")
        
        testIterator()
    }
    
    // MARK: Collection Testing
    
    func testIterator() {
        print("Running Iterator Tests")
        
        for _ in 1...100 {
            let n = Int.random(in: 1...100)
            let m = Int.random(in: 1...100)
            
            let matrix = Matrix<Element>.zero(rows: n, cols: m)
            
            for a in matrix {
                XCTAssert(a == .zero)
            }
        }
    }

}
