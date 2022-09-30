//
//  MatrixPropertiesTest.swift
//  
//
//  Created by Sylvan Martin on 9/9/22.
//

import XCTest
import MatrixKit

class MatrixPropertiesTest: XCTestCase {

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
    
    func testDiagonal() throws {
        
        let upper: Matrix = [
            [1, 0, 0, 0],
            [0, 3, 1, 4],
            [0, 0, -2, 1],
            [0, 0, 0, 1]
        ]
        
        let lower = upper.transpose
        
        let diagonal = upper.hadamard(with: lower)
        
        XCTAssertEqual(upper.triangularity, .upper)
        XCTAssertEqual(lower.triangularity, .lower)
        XCTAssertEqual(diagonal.triangularity, .diagonal)
        
    }
    
    func testKnownKernel() throws {
        
        let mat: Matrix = [
            [1, 0, -3, 0, 2, -8],
            [0, 1, 5, 0, -1, 4],
            [0, 0, 0, 1, 7, -9],
            [0, 0, 0, 0, 0, 0]
        ]
        
        let kern = mat.kernel.columns
        
        let knownKernBasis: [[Double]] = [
            [3, -5, 1, 0, 0, 0],
            [-2, 1, 0, -7, 1, 0],
            [8, -4, 0, 9, 0, 1]
        ]
        
        XCTAssertEqual(kern.count, 3) // should have 3 basis vectors
        
        XCTAssertTrue(kern.contains(knownKernBasis[0]))
        XCTAssertTrue(kern.contains(knownKernBasis[1]))
        XCTAssertTrue(kern.contains(knownKernBasis[2]))
        
        XCTAssertTrue((mat * mat.kernel).allSatisfy { $0.isZero })
        
        let a: Matrix = [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9]
        ]
        
        XCTAssertEqual(a.kernel, Matrix(vector: [1, -2, 1]))
        
    }
    
    func testKernelDim() throws {
        for _ in 1...1 {
            let rand = Matrix.random(rows: .random(in: 1...10), cols: .random(in: 1...10))
            let kernel = rand.kernel
            XCTAssertEqual(kernel.rowCount, rand.colCount)
            XCTAssertEqual(kernel.colCount, rand.rowCount - rand.rank)
        }
    }
    
    func testZeroKernel() throws {
        
        for _ in 1...1000 {
            let rand = Matrix.random(rows: .random(in: 1...5), cols: .random(in: 1...5)) {
                Double(Int.random(in: 1...100))
            }
            let kernel = rand.kernel
            let zero = rand * kernel
            
            // I think that floating point imprecision is what is causing it to not always be exactly zero
            XCTAssertTrue(zero.allSatisfy { $0.magnitude < 1e-8 })
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
