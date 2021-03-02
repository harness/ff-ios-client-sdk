//
//  CFConfigurationBuilderTests.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 4.2.21..
//

import XCTest
@testable import ff_ios_client_sdk

 
class CFConfigurationBuilderTest: XCTestCase {
    
    var sut: CFConfigurationBuilder!
    
    override func setUp() {
        super.setUp()
        sut = CFConfigurationBuilder()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testInit() {
        XCTAssertTrue(type(of: sut) === CFConfigurationBuilder.self)
    }
    
    func testBuild() {
        let config = sut.build()
        XCTAssertTrue(config.baseUrl == ConfigurationMocks.baseUrl)
    }
    func testAttachBaseUrl() {
        let mockBaseUrl = "https://www.base-url"
        sut = sut.setBaseUrl(mockBaseUrl)
        let config = sut.build()
        XCTAssert(config.baseUrl.contains(mockBaseUrl))
    }
    
    func testStreamEnabled() {
        let streamEnabled = true
        sut = sut.setStreamEnabled(streamEnabled)
        let config = sut.build()
        XCTAssert(config.streamEnabled == streamEnabled)
    }
    
    func testTarget() {
        let target = "target-test"
        sut = sut.setTarget(target)
        let config = sut.build()
        XCTAssert(config.target == target)
    }
    
    func testPollingInterval() {
        let interval = TimeInterval(100)
        sut = sut.setPollingInterval(interval)
        let confing = sut.build()
        XCTAssertTrue(confing.pollingInterval == interval)
    }
    
    func testMinimumPollingInterval() {
        let interval = TimeInterval(10)
        sut = sut.setPollingInterval(interval)
        let confing = sut.build()
        XCTAssertTrue(confing.pollingInterval == 60)

    }
    
    func testDefault() {
		let config = CFConfiguration.builder().build()
        XCTAssertTrue(config.baseUrl == ConfigurationMocks.baseUrl)

    }
    
}
