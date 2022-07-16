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
     * Creates a random matrix of specified dimension, generating secure random bytes.
     *
     * - Warning: This does **not** guarantee that the elements willl be "friendly" `Double` bit patterns. Generating `nan` may occur.
     */
    static func secureRandom(rows: Int, cols: Int) -> Matrix {
        var rand = Matrix(rows: rows, cols: cols)
        rand.withMutableBaseAddress { basePtr in
            _ = SecRandomCopyBytes(kSecRandomDefault, MemoryLayout<Element>.size * (rows * cols), basePtr)
        }
        return rand
    }
    
    /**
     * Creates a random matrix
     *
     * - Parameter rows: The amount of rows in the random matrix
     * - Parameter cols: The amount of columns in the random matrix
     * - Parameter range: A closed range to guarantee all elements of the matrix are in. By default, this will generate numbers between 0 and 1.
     *
     * - Returns: A new, random matrix, with all elements in `range.`
     */
    static func random(rows: Int, cols: Int, range: ClosedRange<Element> = 0...1) -> Matrix {
        let randomFlatmap = [Element](repeating: 0, count: rows * cols).lazy.map { _ in Element.random(in: range) }
        return Matrix(flatmap: [Element](randomFlatmap), cols: cols)
    }
    
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
            
            let firstString = String(vect.first!)
            
            if vect.count == 1 {
                return firstString
            }
            
            return vect[1..<colCount].reduce(firstString) { partialResult, elem in
                partialResult + " & " + String(elem)
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
        rows.reduce("") { partialResult, row in
            partialResult + row.reduce("", { partialResult, elem in
                partialResult + String(elem) + " "
            }) + "\n"
        }
    }
    
    internal func makePrettyString() -> String {
        
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
        var newFlatmap = [Element](repeating: 0, count: flatmap.count - rowCount)
        
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
        var newFlatmap = [Element](repeating: 0, count: flatmap.count - colCount)
        
        newFlatmap[0..<(row * colCount)] = flatmap[0..<(row * colCount)]
        newFlatmap[(row * colCount)..<newFlatmap.count] = flatmap[((row + 1) * colCount)..<flatmap.count]
        
        return Matrix(flatmap: newFlatmap, cols: colCount)
    }
    
    /**
     * Computes the transpose of this matrix and stores the result in `result
     *
     * - Precondition: `result.colCount == self.rowCount && result.rowCount == self.colCount`
     */
    internal func computeTranspose(result: inout Matrix) {
        withBaseAddress { baseAddress in
            result.withMutableBaseAddress { resultAddress in
                vDSP_mtransD(baseAddress, 1, resultAddress, 1, UInt(colCount), UInt(rowCount))
            }
        }
    }
    
    /**
     * Sets every element of this matrix to zero
     */
    mutating func setToZero() {
        var new = flatmap
        
        new.withUnsafeMutableBufferPointer { buffer in
            vDSP_vclrD(buffer.baseAddress!, 1, UInt(count))
        }
        
        self.flatmap = new
    }
    
}
