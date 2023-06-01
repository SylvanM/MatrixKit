//
//  RealNumber.swift
//  
//
//  Created by Sylvan Martin on 5/15/23.
//

import Foundation

/**
 * Any type isomorphic to a Double (up to precision error)
 */
public protocol RealNumber {
    
    var asDouble: Double { get }
    
    init(fromDouble: Double)
    
}
