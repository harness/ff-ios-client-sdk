//
//  CfConfigurationBuilderTests.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 4.2.21..
//

import XCTest
@testable import ff_ios_client_sdk

class CfConfigurationBuilderTest: XCTestCase {
    
    var sut: CfConfigurationBuilder!
    
    override func setUp() {
        super.setUp()
        sut = CfConfigurationBuilder()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testInit() {
        XCTAssertTrue(type(of: sut) === CfConfigurationBuilder.self)
    }
    
    func testBuild() {
        let config = sut.build()
        XCTAssertTrue(config.configUrl == ConfigurationMocks.baseUrl)
    }
	
    func testAttachBaseUrl() {
        let mockBaseUrl = "https://www.base-url"
        sut = sut.setConfigUrl(mockBaseUrl)
        let config = sut.build()
        XCTAssert(config.configUrl.contains(mockBaseUrl))
    }
	
	func testAttachEventUrl() {
		let mockEventUrl = "https://www.event-url"
		sut = sut.setEventUrl(mockEventUrl)
		let config = sut.build()
		XCTAssert(config.eventUrl.contains(mockEventUrl))
	}
    
	func testStreamEnabledDefault() {
		let config = sut.build()
		XCTAssertFalse(config.streamEnabled)
	}
	
    func testStreamEnabled() {
        let streamEnabled = true
        sut = sut.setStreamEnabled(streamEnabled)
        let config = sut.build()
        XCTAssert(config.streamEnabled == streamEnabled)
    }
	
	func testAnalyticsEnabledDefault() {
		let config = sut.build()
		XCTAssert(config.analyticsEnabled)
	}
	
	func testAnalyticsEnabled() {
		let analyticsEnabled = true
		sut = sut.setStreamEnabled(analyticsEnabled)
		let config = sut.build()
		XCTAssert(config.analyticsEnabled == analyticsEnabled)
	}
	
	func testAnalyticsDisabled() {
		let analyticsEnabled = false
		sut = sut.setAnalyticsEnabled(analyticsEnabled)
		let config = sut.build()
		XCTAssert(config.analyticsEnabled == analyticsEnabled)
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
		let config = CfConfiguration.builder().build()
        XCTAssertTrue(config.configUrl == ConfigurationMocks.baseUrl)

    }
    
}
