//
//  test_wrapperTests.swift
//  test_wrapperTests
//
//  Created by Milos Vasic on 12.8.21..
//

import XCTest

@testable import test_wrapper
@testable import ff_ios_client_sdk

class test_wrapperTests: XCTestCase {

    override func setUpWithError() throws {
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
        let _ = WrapperServer(
        
            port: 0,
            apiKey: "",
            target: CfTarget(identifier: "", name: "", anonymous: false, attributes: [:]),
            configuration: CfConfiguration(configUrl: "", streamUrl: "", eventUrl: "", streamEnabled: true, analyticsEnabled: true, pollingInterval: 60, environmentId: "")
        )
        
        XCTAssert(1 == 1)
        NSLog("Test completed")
    }
}
