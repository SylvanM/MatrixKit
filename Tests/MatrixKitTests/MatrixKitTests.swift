import XCTest
import MatrixKit
import MatrixKit
import Accelerate

final class MatrixKitTests: XCTestCase {
    
    let floatingPointAccuracy: Double = 0.0000001
    
    public static func makeRandomMatrix(rows: Int, cols: Int, range: ClosedRange<Double> = 0...1) -> Matrix {
        let flatmap = [Double](repeating: 0, count: rows * cols).lazy.map { _ in Double.random(in: range) }
        return Matrix(flatmap: [Double](flatmap), cols: cols)
    }
    
    func testReadWrite() throws {
        for _ in 1...100 {
            let matrix = MatrixKitTests.makeRandomMatrix(rows: Int.random(in: 1...100), cols: Int.random(in: 1...100))
            let buffer = matrix.encodedDataBuffer
            let decoded = Matrix(buffer: buffer)
            XCTAssertEqual(matrix, decoded)
        }
    }
    
    func testMagnitude() {
        
        for i in 1...100 {
            
            let zero = Matrix(vector: [Double](repeating: 0, count: i))
            XCTAssertEqual(zero.magnitudeSquared, 0)
            
            let theta = Double.random(in: -1000...1000)
            let x = cos(theta)
            let y = sin(theta)
            let vect = Matrix(vector: [x, y])
            XCTAssertEqual(vect.magnitudeSquared, 1, accuracy: floatingPointAccuracy)
        }
        
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
        
        let onesH = Matrix([1, 1])
        let onesV = Matrix(vector: [1, 1])
        let ozV = Matrix(vector: [0, 1])
        
        XCTAssertEqual(onesH * onesV, [[2]])
        XCTAssertEqual(onesH * ozV, [[1]])
        
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
        
        // test that identity is truly an identity, and that the zero matrix truly does zero everything
        for _ in 1...100 {
            
            // this loop takes a while
            
            let rows = Int.random(in: 10...100)
            let cols = Int.random(in: 10...100)
            let idenL = Matrix.identity(forDim: rows)
            let idenR = Matrix.identity(forDim: cols)
            let zeroL = Matrix(rows: Int.random(in: 10...100), cols: rows)
            let zeroR = Matrix(rows: cols, cols: Int.random(in: 10...100))
            let matrix = MatrixKitTests.makeRandomMatrix(rows: rows, cols: cols)
            
            XCTAssertEqual(idenL * matrix, matrix)
            XCTAssertEqual(matrix * idenR, matrix)
            
            XCTAssertEqual(zeroL * matrix, Matrix(rows: zeroL.rowCount, cols: matrix.colCount))
            XCTAssertEqual(matrix * zeroR, Matrix(rows: matrix.rowCount, cols: zeroR.colCount))
            
        }
        
        // test vector dot product, essentially.
        
        for _ in 1...100 {
            
            let length = Int.random(in: 10...1000)
            
            let randomElementsA = [Double](repeating: 0, count: length).map { _ in Double.random(in: -1000...1000) }
            let randomElementsB = [Double](repeating: 0, count: length).map { _ in Double.random(in: -1000...1000) }
            
            let ml = Matrix(randomElementsA)
            let mr = Matrix(vector: randomElementsB)
            
            let dot = (ml * mr)[0, 0]
            
            var sum: Double = 0
            
            for i in 0..<length {
                sum += randomElementsA[i] * randomElementsB[i]
            }
            
            // this fails, but only is off by negligible amounts where the values disagree on precision.
            XCTAssertEqual(dot, sum, accuracy: floatingPointAccuracy)
            
        }
        
    }
    
    func testRankComputation() {
        
        // identity is full rank
        for dim in 1...100 {
            XCTAssertEqual(Matrix.identity(forDim: dim).rank, dim)
        }
        
        // use some known-value tests that I got from https://www.cse.cuhk.edu.hk/~taoyf/course/1410/19-spr/ex/ex-matrix-rank-sol.pdf
        
        let m1: Matrix = [
            [0, 16, 8, 4],
            [2, 4, 8, 16],
            [16, 8, 4, 2],
            [4, 8, 16, 2]
        ]
        
        XCTAssertEqual(m1.rank, 4)
        
        let m2: Matrix = [
            [4, -6, 0],
            [-6, 0, 1],
            [0, 9, -1],
            [0, 1, 4]
        ]
        
        XCTAssertEqual(m2.rank, 3)
        
        let m3: Matrix = [
            [3, 0, 1, 2],
            [6, 1, 0, 0],
            [12, 1, 2, 4],
            [6, 0, 2, 4],
            [9, 0, 1, 2]
        ]
        
        XCTAssertEqual(m3.rank, 3)
        
        // test a little theorem
        
        for _ in 1...100 {
            let a = MatrixKitTests.makeRandomMatrix(rows: Int.random(in: 1...5), cols: Int.random(in: 1...5))
            let b = MatrixKitTests.makeRandomMatrix(rows: a.rowCount, cols: a.colCount)
            
            XCTAssertLessThanOrEqual((a + b).rank, a.rank + b.rank)
            
        }
        
    }
    
    func testHadamard() {
        let v1 = Matrix(vector: [1, 2, 3, 5])
        let v2 = Matrix(vector: [5, 3, 2, 1])
        let hproduct1 = v1.hadamard(with: v2)
        let hproduct2 = v2.hadamard(with: v1)
        
        XCTAssertEqual(hproduct1, hproduct2)
        XCTAssertEqual(hproduct1, Matrix(vector: [5, 6, 6, 5]))
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
        
        // Make sure that multiplying by the inverse gives an identity element
        for _ in 1...100 {
            var matrix: Matrix
            let size = Int.random(in: 1...10)
            
            repeat {
                matrix = MatrixKitTests.makeRandomMatrix(rows: size, cols: size)
            } while !matrix.isInvertible
            
            XCTAssertLessThan(Matrix.identity(forDim: size).distanceSquared(from: matrix.inverse * matrix), floatingPointAccuracy)
            XCTAssertLessThan(Matrix.identity(forDim: size).distanceSquared(from: matrix * matrix.inverse), floatingPointAccuracy)
            
                        
        }
    
    }
    
}
