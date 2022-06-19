//
//  File.swift
//  
//
//  Created by Sylvan Martin on 6/18/22.
//

import Foundation

public extension String {
    
    /**
     * Repeats a string
     */
    static func * (lhs: String, rhs: Int) -> String {
        var rep = ""
        for _ in 0..<rhs {
            rep += lhs
        }
        return rep
    }
    
    /**
     * Repeats a string
     */
    static func * (lhs: Int, rhs: String) -> String {
        var rep = ""
        for _ in 0..<lhs {
            rep += rhs
        }
        return rep
    }
    
}

