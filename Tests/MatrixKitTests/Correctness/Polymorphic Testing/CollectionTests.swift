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
        testIndices()
        testSubscripts()
        testOnAll()
    }
    
    // MARK: Collection Testing
    
    func testIterator() {
        #warning("Unimplemented")
    }
    
    func testIndices() {
        #warning("Unimplemented")
    }
    
    func testSubscripts() {
        #warning("Unimplemented")
    }
    
    func testOnAll() {
        #warning("Unimplemented")
    }

}
