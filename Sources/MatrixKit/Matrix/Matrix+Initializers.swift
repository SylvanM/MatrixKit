//
//  Matrix+Initializers.swift
//
//
//  Created by Sylvan Martin on 6/15/22.
//

import Foundation

public extension Matrix {

    // MARK: - Initializers

    /**
     * Creates a matrix from an array of rows
     *
     * - Parameter array: A 2D array of the elements of the matrix
     *
     * - Precondition: `array` is not empty, and `array.isRectangular`
     */
    init(_ array: [[Element]]) {
        flatmap = Array(array.joined())
        colCount = array.first!.count
        rowCount = flatmap.count / colCount
    }

    /**
     * Creates an empty matrix with specified dimension
     */
    init(rows: Int, cols: Int) {
        flatmap = [Element](repeating: 0, count: rows * cols)
        rowCount = rows
        colCount = cols
    }

    init(arrayLiteral elements: [Element]...) {
        self.init(elements)
    }

    /**
     * Creates a matrix from a one dimensional array of rows, back to back.
     *
     * - Parameter flatmap: An array of the elements of the matrix, from left to right across each row.
     * - Parameter cols: The number of columns in this matrix
     *
     * - Precondition: `flatmap.count % cols == 0`
     */
    init(flatmap: [Matrix.Element], cols: Int) {
        self.flatmap = flatmap
        self.colCount = cols
        self.rowCount = flatmap.count / cols
    }

}
