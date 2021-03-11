//
//  CfTargetBuilderTest.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 9.3.21..
//

import XCTest
@testable import ff_ios_client_sdk
 
class CfTargetBuilderTest: XCTestCase {
	
	var sut: CfTargetBuilder!
	
	override func setUp() {
		super.setUp()
		sut = CfTargetBuilder()
	}
	
	override func tearDown() {
		sut = nil
		super.tearDown()
	}
	
	func testInit() {
		XCTAssertTrue(type(of: sut) === CfTargetBuilder.self)
	}
	
	func testBuild() {
		let target = sut.build()
		XCTAssertTrue(target.identifier == TargetMocks.identifier)
	}
	
	func testSetIdentifier() {
		let mockidentifier = "testIdentifier"
		sut = sut.setIdentifier(mockidentifier)
		let target = sut.build()
		XCTAssertEqual(target.identifier, mockidentifier)
	}
	
	func testSetName() {
		let mockName = "testName"
		sut = sut.setName(mockName)
		let target = sut.build()
		XCTAssertEqual(target.name, mockName)
	}
	
	func testSetAnonymousFalse() {
		let target = sut.build()
		sut = sut.setAnonymous(false)
		XCTAssertFalse(target.anonymous)
	}
	
	func testSetAnonymousTrue() {
		sut = sut.setAnonymous(true)
		let target = sut.build()
		XCTAssertTrue(target.anonymous)
	}
	
	func testAttributes() {
		let mockAttributes = ["testAttrOne":"testValueOne", "testAttrTwo":"testValueTwo"]
		sut = sut.setAttributes(mockAttributes)
		let target = sut.build()
		XCTAssertEqual(target.attributes, mockAttributes)
	}
	
	func testDefault() {
		let target = CfTarget.builder().build()
		XCTAssertTrue(target.identifier == TargetMocks.identifier)
		XCTAssertTrue(target.name == TargetMocks.name)
		XCTAssertTrue(target.anonymous == TargetMocks.anonymous)
		XCTAssertTrue(target.attributes == TargetMocks.attributes)

	}
	
}
