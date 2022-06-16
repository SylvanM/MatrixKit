import XCTest
@testable import MatrixKit

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
        
        print(a)
        
    }
    
}
