//
//  test_wrapperTests.swift
//  test_wrapperTests
//
//  Created by Milos Vasic on 12.8.21..
//

import XCTest

@testable import test_wrapper

class test_wrapperTests: XCTestCase {

    override func setUpWithError() throws {
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
        let server = WrapperServer()
        XCTAssert(1 == 1)
        NSLog("Test completed")
    }
}
