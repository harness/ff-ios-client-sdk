//
//  CFProjectTest.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 6.2.21..
//

import XCTest
@testable import ff_ios_client_sdk

class CFProjectTest: XCTestCase {
    
    var sut: CFProject!
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInit() {
        sut = .init(dict: CFProjectMocks.projectInitDict)
        XCTAssertNotNil(sut)
    }
}



