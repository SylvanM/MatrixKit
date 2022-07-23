//
//  UtilityPerformance.swift
//  
//
//  Created by Sylvan Martin on 7/22/22.
//

import XCTest
import MatrixKit
import Accelerate

class UtilityPerformance: XCTestCase {

    func testSubmatrixSubscript() throws {
        
        measure {
            
            let bigM = Int.random(in: 1...10000)
            let bigN = Int.random(in: 1...10000)
            
            var matrix = Matrix.random(rows: bigM, cols: bigN)
            
            let startRow = Int.random(in: 1..<(bigM - 1))
            let startCol = Int.random(in: 1..<(bigN - 1))
            
            let endRow = Int.random(in: (startRow + 1)..<bigM)
            let endCol = Int.random(in: (startCol + 1)..<bigN)
            
            let rowRange = startRow..<endRow
            let colRange = startCol..<endCol
            
            let extracted = matrix[rowRange, colRange]
            
            matrix[rowRange, colRange] = extracted
            
        }
        
    }
    
    func testConcatPerformance() {
        
        measure {
            
            // randomly concatenate a bunch of big matrices
            
            for m in 95...100 {
                for n in 95...100 {
                    for p in 95...100 {
                        let baseMatrix = Matrix.random(rows: m, cols: n)
                        let sideConCat = Matrix.random(rows: m, cols: p)
                        let downConCat = Matrix.random(rows: p, cols: n)
                        
                        _ = baseMatrix.sideConcatenating(sideConCat)
                        _ = baseMatrix.bottomConcatenating(downConCat)
                    }
                }
            }
            
        }
        
    }

}
