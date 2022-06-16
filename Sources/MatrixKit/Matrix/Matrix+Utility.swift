//
//  Matrix+Utility.swift
//  
//
//  Created by Sylvan Martin on 6/15/22.
//

import Foundation

public extension Matrix {
    
    internal func makeStringDescription() -> String {
        
        let stringNumbers = rows.map { $0.map { $0.description } }
        
        let entryLengths = columns.map { column in
            column.map { element in
                String(element).count
            }.max()!
        }
        
        var string = ""
        
        for r in 0..<rowCount {
            
            if rowCount == 0 {
                return "[]"
            }
            
            // I could probably just make a check at the beginning to see if it's a 1-row matrix
            
            if rowCount == 1 {
                string += "[ "
            } else {
                string += r == 0 ? "┌ " : r == rowCount - 1 ? "└ " : "│ "
            }
            
            for c in 0..<colCount {
                string += stringNumbers[r][c] + String(repeating: " ", count: entryLengths[c] - stringNumbers[r][c].count + (c == colCount - 1 ? 1 : 2) )
            }
            
            if rowCount == 1 {
                string += "]"
            } else {
                string += r == 0 ? "┐" : r == rowCount - 1 ? "┘" : "│"
            }
            
            if r < rowCount - 1 { string += "\n" }
        }
        
        return string
    }
    
    /**
     * Applies a function to each element of this matrix, in place
     */
    mutating func applyToAll(_ closure: (inout Element) -> ()) {
        for i in 0..<flatmap.count {
            closure(&flatmap[i])
        }
    }
    
    /**
     * Returns a new matrix with each element being the result of a function applied to the corresponding
     * element of this matrix.
     */
    func applyingToAll(_ closure: (Element) -> Element) -> Matrix {
        Matrix(flatmap: flatmap.map(closure), cols: colCount)
    }
    
    /**
     * Returns a new matrix which is identical to `self` with a certain column omitted
     */
    func omitting(col: Int) -> Matrix {
        var newFlatmap = [Element](repeating: 0, count: flatmap.count - rowCount)
        
        var i = 0
        var j = 0
        
        while i < flatmap.count {
            if i % colCount == col {
                i += 1
            }
            
            newFlatmap[j] = flatmap[i]
            
            i += 1
            j += 1
        }
        
        return Matrix(flatmap: newFlatmap, cols: colCount - 1)
    }
    
    /**
     * Returns a new matrix which is identical to `self` with a certain row omitted
     */
    func omitting(row: Int) -> Matrix {
        var newFlatmap = [Element](repeating: 0, count: flatmap.count - colCount)
        
        newFlatmap[0..<(row * colCount)] = flatmap[0..<(row * colCount)]
        newFlatmap[(row * colCount)..<newFlatmap.count] = flatmap[((row + 1) * colCount)..<flatmap.count]
        
        return Matrix(flatmap: newFlatmap, cols: colCount)
    }
    
}
