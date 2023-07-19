//
//  TestHandler.swift
//  
//
//  Created by Sylvan Martin on 6/1/23.
//

import XCTest
import MatrixKit

final class MatrixKitTestHandler: XCTestCase {

    func testMatrixKit() throws {
        MatrixKitTests<TrivialField>().run()
        MatrixKitTests<ZM5>().run()
        MatrixKitTests<SillyDouble>().run()
    }
    
}

protocol MKTestSuite {
    
    associatedtype Element: TestableFieldElement
    
}


class MatrixKitTests<Element: TestableFieldElement> : XCTest, MKTestSuite {
    
    override func run() {
        print("Running MatrixKitTests with Element = \(Element.self)")
        InitializerTests<Element>().run()
        OperatorTests<Element>().run()
        MathPropertiesTests<Element>().run()
        CollectionTests<Element>().run()
        UtilityTests<Element>().run()
        print("\n")
    }

}
