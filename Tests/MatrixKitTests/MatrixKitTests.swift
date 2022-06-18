import XCTest
@testable import MatrixKit
import Accelerate

final class MatrixKitTests: XCTestCase {
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
    }
    
    // MARK: Initializer Tests
    
    func testSubscriptAndInitializerTest() {
        
        let a: Matrix = [
            [0, 2, 3, 5],
            [1, 1, 6, 7],
            [0, 0, 0, 2]
        ]
        
        XCTAssertEqual(a[0, 0], 0)
        XCTAssertEqual(a[2, 3], 2)
        XCTAssertEqual(a[0][0], 0)
        XCTAssertEqual(a[2][3], 2)
        XCTAssertEqual(a[0, 3], 5)
        
        XCTAssertEqual(a[col: 3], [5, 7, 2])
        XCTAssertEqual(a[col: 0], [0, 1, 0])
        
        XCTAssertEqual(a.rows, [
            [0, 2, 3, 5],
            [1, 1, 6, 7],
            [0, 0, 0, 2]
        ])
        
        XCTAssertEqual(a.columns, [
            [0, 1, 0],
            [2, 1, 0],
            [3, 6, 0],
            [5, 7, 2]
        ])
        
        XCTAssertEqual(a.count, 12)
        
    }
    
    func testBasicArithmetic() {
        
        var identity = Matrix.identity(forDim: 4)
        
        identity *= 5
        
        for i in 0..<4 {
            XCTAssertEqual(identity[i, i], 5)
        }
        
        identity += [
            [-5, 0, 0, 1],
            [0, -5, 0, 0],
            [0, 5, -4, 0],
            [0, 0, 0, -5]
        ]
        
        XCTAssertEqual(identity, [
            [0, 0, 0, 1],
            [0, 0, 0, 0],
            [0, 5, 1, 0],
            [0, 0, 0, 0]
        ])
        
    }
    
    func testMatrixMath() {
        
        for dim in 1...10 {
            let scalar = Double.random(in: 0...10)
            XCTAssertEqual(scalar * Matrix.identity(forDim: dim).determinant, scalar)
        }
        
        let a: Matrix = [
            [0, 2, 3, 5],
            [1, 1, 6, 7],
            [0, 0, 0, 2]
        ]
        
        XCTAssertEqual(a.applying(rowOperation: .scale(index: 0, by: 2)), [
            [0, 4, 6, 10],
            [1, 1, 6, 7],
            [0, 0, 0, 2]
        ])
        
        XCTAssertEqual(a.applying(rowOperation: .swap(1, 2)), [
            [0, 2, 3, 5],
            [0, 0, 0, 2],
            [1, 1, 6, 7]
        ])
        
        XCTAssertEqual(a.applying(rowOperation: .add(scalar: 5, index: 1, toIndex: 2)), [
            [0, 2, 3, 5],
            [1, 1, 6, 7],
            [5, 5, 30, 37]
        ])
        
        let b: Matrix = [
            [1, 3],
            [3, 3],
            [6, 7],
            [1, 0]
        ]
        
        let product: Matrix = [
            [29, 27],
            [47, 48],
            [2, 0]
        ]
        
        XCTAssertEqual(a * b, product)
        
    }
    
    func testRowReduction() {
        
        let echelonFormA: Matrix = [
            [4, 0, 2, 4, 1],
            [0, 0, 1, 9, 1],
            [0, 0, 0, 4, 0]
        ]
        
        let reducedA: Matrix = [
            [1, 0, 0, 0, -0.25],
            [0, 0, 1, 0, 1],
            [0, 0, 0, 1, 0]
        ]
        
        XCTAssertFalse(echelonFormA.isReducedRowEchelonForm)
        XCTAssertTrue(echelonFormA.isRowEchelonForm)
        XCTAssertEqual(echelonFormA.rowEchelonForm, echelonFormA)
        XCTAssertEqual(echelonFormA.reducedRowEchelonForm, reducedA)
        
        let matrixB: Matrix = [
            [1, 5, 1],
            [2, 11, 5],
            [8, 6, 2],
            [0, 88, -10],
            [4, 2, 1]
        ]
        
        print(matrixB.rowEchelonForm)
        
        let rrefB: Matrix = [
            [1, 0, 0],
            [0, 1, 0],
            [0, 0, 1],
            [0, 0, 0],
            [0, 0, 0]
        ]
        
        XCTAssertFalse(matrixB.isRowEchelonForm)
        XCTAssertFalse(matrixB.isReducedRowEchelonForm)
        
        XCTAssertTrue(rrefB.isReducedRowEchelonForm)
        
        XCTAssertEqual(matrixB.reducedRowEchelonForm, rrefB)
        
        XCTAssertTrue(matrixB.reducedRowEchelonForm.isReducedRowEchelonForm)
        
    }
    
}
