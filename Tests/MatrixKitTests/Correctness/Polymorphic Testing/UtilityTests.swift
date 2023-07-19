//
//  UtilityTests.swift
//
//
//  Created by Sylvan Martin on 7/5/23.
//

import Foundation
import MatrixKit
import XCTest

class UtilityTests<Element: TestableFieldElement>: XCTest, MKTestSuite {
    
    override func run() {
        print("Running UtilityTests with Element = \(Element.self)")
        
        testReadWrite()
        testApplyToAll()
        testOmiting()
        testSetToZero()
        testConcatenating()
    }
    
    // MARK: Utility Testing
    
    func testReadWrite() {
#warning("Unimplemented")
    }
    
    func testApplyToAll() {
#warning("Unimplemented")
    }
    
    func testOmiting() {
#warning("Unimplemented")
    }
    
    func testSetToZero() {
#warning("Unimplemented")
    }
    
    func testConcatenating() {
#warning("Unimplemented")
    }

}
