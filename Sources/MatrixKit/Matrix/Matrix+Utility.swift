//
//  Matrix+Utility.swift
//  
//
//  Created by Sylvan Martin on 6/15/22.
//

import Foundation
import Security
import Accelerate

public extension Matrix {
    
    // MARK: Creation
    
    
    
    /**
     * Decodes a matrix from the base address of a buffer of data that encodes this matrix, and updates the base address to point to the next
     * byte after this buffer
     *
     * - Parameter baseAddress: `UnsafeRawPointer` pointing to the beginning of a byte buffer that encodes a matrix, which
     * will be incremented
     */
    static func unsafeRead(from baseAddress: inout UnsafeRawPointer) -> Matrix {
        let dimensionDecoder = baseAddress.bindMemory(to: Int.self, capacity: 2)
        let rows = dimensionDecoder.pointee
        let cols = dimensionDecoder.advanced(by: 1).pointee
        
        return dimensionDecoder.advanced(by: 2).withMemoryRebound(to: Element.self, capacity: rows * cols) { flatmapPointer -> Matrix in
            let buffer = UnsafeBufferPointer(start: flatmapPointer, count: rows * cols)
            let flatmap = Array(buffer)
            
            baseAddress = UnsafeRawPointer(flatmapPointer.advanced(by: rows * cols))
            return Matrix(flatmap: flatmap, cols: cols)
        }
    }
    
    /**
     * Writes all the necessary data of this matrix to a stream of bytes, given the base address
     *
     * - Precondition: The memory referenced is properly initialized
     *
     * - Parameter address: The base address to write data to, which is then set equal to the next base address after the matrix in memory
     */
    func unsafeWrite(to address: inout UnsafeMutableRawPointer) {
        let dimensionEncoder = address.bindMemory(to: Int.self, capacity: 2)
        dimensionEncoder.pointee = rowCount
        dimensionEncoder.advanced(by: 1).pointee = colCount
        
        let flatmapWriteAddress = UnsafeMutableRawPointer(dimensionEncoder.advanced(by: 2))
        
        let bufferSize = MemoryLayout<Element>.size * flatmap.count
        let writeBuffer = UnsafeMutableRawBufferPointer(start: flatmapWriteAddress, count: bufferSize)
        
        flatmap.withUnsafeBytes {
            $0.copyBytes(to: writeBuffer)
            address = writeBuffer.baseAddress!.advanced(by: bufferSize)
        }
    }
    
    // MARK: String Conversion
    
    internal func makeLatexString() -> String {
        
        func makeRowString(_ vect: [Element]) -> String {
            
            let firstString = vect.first!.description
            
            if vect.count == 1 {
                return firstString
            }
            
            return vect[1..<colCount].reduce(firstString) { partialResult, elem in
                partialResult + " & " + elem.description
            }

        }
        
        let colheader = "{" + ("c" * colCount) + "}"
        
        let beginBracket = "\\left["
        let endBracket = "\\right["
        
        let beginning = beginBracket + "\\begin{array}" + colheader
        let ending = "\\end{array}" + endBracket
        
        let rowStrings: String = {
            let firstString = makeRowString(self[row: 0])
            
            if rowCount == 1 {
                return firstString
            }
            
            return rows[1..<rowCount].reduce(firstString) { partalResult, row in
                partalResult + "\\\\" + makeRowString(row)
            }
        }()
        
        return beginning + rowStrings + ending
    }
    
    internal func makeRawString() -> String {
        var string = ""
        for r in 0..<rowCount {
            for c in 0..<colCount {
                string += self[r, c].description + " "
            }
            string += "\n"
        }
        return string
    }
    
    internal func makePrettyString() -> String {
        
        let stringNumbers = rows.map { $0.map { $0.description } }
        
        let entryLengths = columns.map { column in
            column.map { element in
                element.description.count
            }.max()!
        }
        
        var string = ""
        
        for r in 0..<rowCount {
            
            if rowCount == 0 {
                return "[]"
            }
            
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
    
    // MARK: Element Manipulation
    
    /**
     * Applies a function to each element of this matrix, in place.
     *
     * This method does **not** guarantee that each element is accessed in any particular order, nor does it
     * guarantee that each element is affected in the same thread.
     */
    mutating func applyToAll(_ closure: (inout Element) -> ()) {
        for i in 0..<flatmap.count {
            closure(&flatmap[i])
        }
    }
    
    /**
     * Returns a new matrix with each element being the result of a function applied to the corresponding
     * element of this matrix.
     *
     * This method does **not** guarantee that each element is accessed in any particular order, nor does it
     * guarantee that each element is affected in the same thread.
     */
    func applyingToAll(_ closure: (Element) -> Element) -> Matrix {
        Matrix(flatmap: flatmap.map(closure), cols: colCount)
    }
    
    /**
     * Returns a new matrix which is identical to `self` with a certain column omitted
     */
    func omitting(col: Int) -> Matrix {
        var newFlatmap = [Element](repeating: .zero, count: flatmap.count - rowCount)
        
        var i = 0
        var j = 0
        
        while i < flatmap.count {
            
            if i % colCount == col {
                i += 1
                
                if i == flatmap.count {
                    break
                }
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
        var newFlatmap = [Element](repeating: .zero, count: flatmap.count - colCount)
        
        newFlatmap[0..<(row * colCount)] = flatmap[0..<(row * colCount)]
        newFlatmap[(row * colCount)..<newFlatmap.count] = flatmap[((row + 1) * colCount)..<flatmap.count]
        
        return Matrix(flatmap: newFlatmap, cols: colCount)
    }
    
    /**
     * Sets every element of this matrix to zero
     */
    mutating func setToZero() {
        for i in 0..<flatmap.count {
            flatmap[i] = .zero
        }
    }
    
    // MARK: Matrix Concatenation
    
    /**
     * Concatenates another matrix to the right of this matrix.
     *
     * Given `A` a `n` by `m` matrix, and `B` a `n` by `p` matrix,
     * `A.sideContatenating(B)` returns a `n` by `m + p` matrix of the form `[ A | B ]`
     */
    func sideConcatenating(_ other: Matrix) -> Matrix {
        assert(self.rowCount == other.rowCount)

        var concatted = Matrix(rows: self.rowCount, cols: self.colCount + other.colCount)
        
        concatted[0..<rowCount, 0..<colCount] = self
        concatted[0..<rowCount, colCount..<concatted.colCount] = other
        
        return concatted
    }
    
    /**
     * Concatenates another matrix to the bottom of this matrix.
     *
     * Given `A` a `n` by `m` matrix, and `B` a `p` by `m` matrix,
     * `A.sideContatenating(B)` returns a `n + p` by `m` matrix of the form
     *
     * ```
     * ┌ A ┐
     * | - |
     * └ B ┘
     * ```
     */
    func bottomConcatenating(_ other: Matrix) -> Matrix {
        assert(self.colCount == other.colCount)
        
        var concatted = Matrix(rows: self.rowCount + other.rowCount, cols: self.colCount)
        
        concatted[0..<rowCount, 0..<colCount] = self
        concatted[rowCount..<concatted.rowCount, 0..<colCount] = other
        
        return concatted
    }
    
}
