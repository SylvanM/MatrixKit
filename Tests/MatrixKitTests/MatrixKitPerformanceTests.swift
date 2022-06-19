//
//  MatrixKitPerformanceTests.swift
//  
//
//  Created by Sylvan Martin on 6/18/22.
//

import XCTest
import MatrixKit

class MatrixKitPerformanceTests: XCTestCase {

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
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testMultiplcationSpeed() {
        // generate random matrices and multiply them
        self.measure {
            for r in 1...1000 {
                for c in 1...1000 {
                    let matrixA = MatrixKitTests.makeRandomMatrix(rows: r, cols: c, range: -10...10)
                    let matrixB = MatrixKitTests.makeRandomMatrix(rows: matrixA.colCount, cols: Int.random(in: 1...1000))
                    _ = matrixA * matrixB
                }
            }
        }
    }
    
    func testMatrixRowOpSpeed() {
        // generate random row operations and perform them on random matrices
        self.measure {
            for r in 2...1000 {
                for c in 2...1000 {
                    var matrix = MatrixKitTests.makeRandomMatrix(rows: r, cols: c, range: -10...10)
                    var op: Matrix.ElementaryOperation
                    
                    let opcode = Int.random(in: 1...3)
                    
                    switch opcode {
                    case 1:
                        
                        let row1 = Int.random(in: 0..<r)
                        var row2: Int
                        
                        repeat {
                            row2 = Int.random(in: 0..<r)
                        } while row1 == row2
                        
                        op = .swap(row1, row2)
                        
                    case 2:
                        
                        let row = Int.random(in: 0..<r)
                        let scalar = Double.random(in: -10..<0) * [-1, 1].randomElement()!
                        
                        op = .scale(index: row, by: scalar)
                        
                    default:
                        
                        let row1 = Int.random(in: 0..<r)
                        var row2: Int
                        
                        let scalar = Double.random(in: -10..<0) * [-1, 1].randomElement()!
                        
                        repeat {
                            row2 = Int.random(in: 0..<r)
                        } while row1 == row2
                        
                        op = .add(scalar: scalar, index: row1, toIndex: row2)
                    }
                    
                    matrix.apply(rowOperation: op)
                }
            }
        }
    }

}
