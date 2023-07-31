//
//  MathPropertiesTests.swift
//  
//
//  Created by Sylvan Martin on 6/3/23.
//

import Foundation
import MatrixKit
import XCTest

class MathPropertiesTests<Element: TestableFieldElement>: XCTest, MKTestSuite {
    
    override func run() {
        print("Running MathPropertiesTests with Element = \(Element.self)")
        testIsSquare()
        testTranspose()
        testIsZero()
        testTriangularity()
        testGaussianElimination()
        testRank()
        testInverse()
        testEigenvectors()
        testLUDecomp()
        testDeterminant()
        testKernel()
        testLinearOperation()
    }
    
    // MARK: Math Tests
    
    func testIsSquare() {
        print("Running isSquare tests")
        
        let n = Int.random(in: 1...100)
        var m = 0
        
        repeat {
            m = Int.random(in: 1...100)
        } while m == n;
        
        for _ in 1...100 {
            let square = Matrix<Element>.random(rows: n, cols: n)
            let rect = Matrix<Element>.random(rows: n, cols: m)
            XCTAssert(square.isSquare)
            XCTAssertFalse(rect.isSquare)
        }
        
    }
    
    func testTranspose() {
        print("Running transpose tests")
        
        for _ in 1...100 {
            let n = Int.random(in: 1...100)
            let m = Int.random(in: 1...100)
            let matrix = Matrix<Element>.random(rows: n, cols: m)
            let transpose = matrix.transpose
            XCTAssertEqual(matrix.rowCount, transpose.colCount)
            XCTAssertEqual(matrix.colCount, transpose.rowCount)
            for r in 0..<n {
                for c in 0..<m {
                    XCTAssertEqual(matrix[r, c], transpose[c, r])
                }
            }
        }
    }
    
    func testIsZero() {
        print("Running isZero tests")
        
        for _ in 1...10 {
            let zero = Matrix<Element>.zero(rows: .random(in: 1...100), cols: .random(in: 1...100))
            XCTAssert(zero.isZero)
        }
        
        for _ in 1...10 {
            let probablyNotZero = Matrix<Element>.random(rows: .random(in: 1...100), cols: .random(in: 1...100))
            
            var turnsOutThisIsActuallyZeroByChance = true
            probablyNotZero.forEach {
                if $0 != .zero {
                    turnsOutThisIsActuallyZeroByChance = false
                }
            }
            
            if turnsOutThisIsActuallyZeroByChance {
                XCTAssert(probablyNotZero.isZero)
            } else {
                XCTAssertFalse(probablyNotZero.isZero)
            }
        }
    }
    
    func testTriangularity() {
        if Element.one == Element.zero {
            print("Skipping Triangularity Tests (1 = 0)")
            return
        } else {
            print("Running Triangularity tests")
        }
        
        for _ in 1...1 {
            let n = Int.random(in: 1...100)
            let upperTriangular = Matrix<Element>(rows: n, cols: n) { r, c in
                if r > c {
                    return Element.zero
                } else {
                    return Element.random()
                }
            }
            
            XCTAssert(upperTriangular.isUpperTriangular)
        }
        
        for _ in 1...1 {
            let n = Int.random(in: 1...100)
            let lowerTriangular = Matrix<Element>(rows: n, cols: n) { r, c in
                if r < c {
                    return Element.zero
                } else {
                    return Element.random()
                }
            }
            
            if lowerTriangular.triangularity != .lower {
                print(lowerTriangular)
            }
            
            XCTAssertEqual(lowerTriangular.triangularity, .lower)
            XCTAssert(lowerTriangular.isLowerTriangular)
        }
        
        for _ in 1...50 {
            let n = Int.random(in: 1...100)
            let lowerTriangular = Matrix(rows: n, cols: n) { r, c in
                if r != c {
                    return Element.zero
                } else {
                    return Element.random()
                }
            }
            
            XCTAssertEqual(lowerTriangular.triangularity, .diagonal)
            XCTAssert(lowerTriangular.isDiagonal)
            XCTAssert(lowerTriangular.isUpperTriangular)
            XCTAssert(lowerTriangular.isLowerTriangular)
        }
        
        for _ in 1...50 {
            let n = Int.random(in: 3...3)
            var lowerTriangular = Matrix<Element>.random(rows: n, cols: n)
            
            lowerTriangular[0, lowerTriangular.colCount - 1] = Element.one
            lowerTriangular[lowerTriangular.rowCount - 1, 0] = Element.one
            
            if lowerTriangular.triangularity != .none {
                print(lowerTriangular)
            }
            XCTAssertEqual(lowerTriangular.triangularity, .none)
            
            XCTAssertFalse(lowerTriangular.isDiagonal)
            XCTAssertFalse(lowerTriangular.isUpperTriangular)
            XCTAssertFalse(lowerTriangular.isLowerTriangular)
        }
    }
    
    func testGaussianElimination() {
#warning("Unimplemented")
    }
    
    func testRank() {
#warning("Unimplemented")
    }
    
    func testInverse() {
        for _ in 1...100 {
            let n = Int.random(in: 1...100)
            let matrix = Matrix<Element>.random(rows: n, cols: n)
            
            if matrix.determinant == .zero {
                XCTAssertFalse(matrix.isInvertible)
            } else {
                XCTAssertTrue(matrix.isInvertible)
                let inverse = matrix.inverse
                XCTAssertEqual(matrix * inverse, .identity(forDim: n))
                XCTAssertEqual(inverse * matrix, .identity(forDim: n))
            }
        }
    }
    
    func testEigenvectors() {
        
        // if in this field 1 == 0, then let's avoid some infinite loops.
        if Element.one == Element.zero {
            print("Skipping Eigenvector Tests (1 = 0)")
            return
        } else {
            print("Running Eigenvector tests")
        }
        
        for _ in 1...10 {
            let iden = Matrix<Element>.identity(forDim: .random(in: 1...100))
            let vect = Matrix<Element>.random(rows: iden.rowCount, cols: 1)
            XCTAssert(iden.isEigenvector(vect))
        }
        
        // this is my way of generating eigenvector-matrix "pairs"
        
        for _ in 1...1 {
            let n = Int.random(in: 1...100)
            var P: Matrix<Element>
            
            repeat {
                P = .random(rows: n, cols: n)
            } while !P.isInvertible;
            
            let D = Matrix<Element>(rows: n, cols: n) { r, c in
                if r != c {
                    return .zero
                } else {
                    var eigenvalue = Element.zero
                    repeat {
                        eigenvalue = Element.random()
                    } while eigenvalue == .zero
                    return eigenvalue
                }
            }
            
            let A = P * D * P.inverse
            
            for c in 0..<n {
                let v = P[rows: 0..<A.rowCount, cols: c...c]
                let lambda = D[c, c]
                
                XCTAssertEqual(A * v, lambda * v)
                XCTAssert(A.isEigenvector(v))
            }
        }
        
    }
    
    func testLUDecomp() {
        print("Running LU Decomposition tests")
        for _ in 1...20 {
            let n = Int.random(in: 1...3)
            let matrix = Matrix<Element>.random(rows: n, cols: n)
            let (_, p, lower, upper) = matrix.luDecomposition
            
            if lower * upper != p * matrix {
                XCTAssertEqual(lower * upper, p * matrix, "L * U = matrix")
                print("FAILED Test, here's some information.")
                print("Swaps:")
                print(p)
                print()
                
                print("Matrix:")
                print(matrix)
                print()
                
                print("Lower:")
                print(lower)
                print()
                
                print("Upper:")
                print(upper)
                print()
            }
            
            // lower should be lower-triangular
            XCTAssert(lower.isLowerTriangular, "L is lower-triangular")

            for i in 0..<n {
                XCTAssert(lower[i, i] == .one || lower[i, i] == .zero, "L is not proper form")
            }
            
            // upper should be upper triangular, and in reduced echelon form.
            XCTAssert(upper.isRowEchelonForm)
        }
    }
    
    func testDeterminant() {
        print("Running determinant tests")
        for _ in 1...10 {
            let n = Int.random(in: 1...100)
            let zeroMatrix = Matrix<Element>(rows: n, cols: n)
            XCTAssertEqual(zeroMatrix.determinant, .zero, "The zero matrix should have det = 0")
        }
        
        for _ in 1...10 {
            let n = Int.random(in: 1...100)
            XCTAssertEqual(Matrix<Element>.identity(forDim: n).determinant, .one, "The identity matrix should have det = 1")
        }
        
        for _ in 1...10 {
            let n = Int.random(in: 1...100)
            let iden = Matrix<Element>.identity(forDim: n)
            let scalar = Element.random()
            XCTAssertEqual((scalar * iden).determinant, scalar.pow(n))
        }
    }
    
    func testLinearOperation() {
        print("Running linear operation tests")
        // If a matrix A truly is a linear operation, then we expect, for any a, b, V, U
        for _ in 1...10 {
            let A = Matrix<Element>.random(rows: .random(in: 1...100), cols: .random(in: 1...100))
            let a = Element.random()
            let b = Element.random()
            let V = Matrix<Element>.random(rows: A.colCount, cols: 1)
            let U = Matrix<Element>.random(rows: A.colCount, cols: 1)
            
            XCTAssertEqual(
                A * ( (a * V) + (b * U) ),
                (a * (A * V)) + (b * (A * U))
            )
        }
    }
    
    func testKernel() {
        
        print("Running kernel tests")
        
        // generate a matrix, generate its kernel, and make sure everything goes to zero.
        
        for _ in 1...100 {
            let matrix = Matrix<Element>.random(rows: Int.random(in: 1...100), cols: Int.random(in: 1...100))
            let kernel = matrix.kernel
            let result = matrix * kernel
            XCTAssert(result.isZero)
            if !result.isZero {
                print(result)
            }
        }
        
    }
    
}
