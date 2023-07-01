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
        MatrixKitTests<ZMP>().run()
        MatrixKitTests<SillyDouble>().run()
    }
    
}

protocol MKTestSuite {
    
    associatedtype Element: TestableFieldElement
    
}


class MatrixKitTests<Element: TestableFieldElement> : XCTest, MKTestSuite {
    
    override func run() {
        let _ = [ZMP](repeating: .zero, count: 1073741824)
//        var a: ZMP
//        for i in 1...100000000000 {
//            a = ZMP.zero
//            if i % 10000000 == 0 {
//                print(i / 10000000)
//            }
//        }
        print("Running MatrixKitTests with Element = \(Element.self)")
        InitializerTests<Element>().run()
        OperatorTests<Element>().run()
        MathPropertiesTests<Element>().run()
        print("\n")
    }

}
