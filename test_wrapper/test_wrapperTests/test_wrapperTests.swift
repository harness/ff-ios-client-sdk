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
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(1 == 1)
        NSLog("Test completed")
    }

    func testPerformanceExample() throws {
        
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
