//
//  JWTDecoderTests.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 3.2.21..
//

import XCTest
@testable import ff_ios_client_sdk


class JWTDecoderTest: XCTestCase {
    
    var sut: JWTDecoder!
    
    override func setUp() {
        super.setUp()
        sut = JWTDecoder()
    }
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testInit() {
        XCTAssertTrue(type(of: sut) === JWTDecoder.self)
    }
    
    func testBase64UrlDecode() {
        let mock = JWTMocks.stringMock.components(separatedBy: ".").first

        let base64data = sut.base64UrlDecode(mock!)!
        XCTAssert(base64data.base64EncodedString() == mock)
    }
    
    func testDecode() {
        let mock = JWTMocks.stringMock
        let givenKey = "name"
        let givenValue = "John Doe"

		let decoded = sut.decode(jwtToken: mock)
        XCTAssertTrue(decoded![givenKey] as! String == givenValue)
    }
	
	func testDecodeWrongJWT() {
		let mock = "RandomNoDotsString"
		
		let decoded = sut.decode(jwtToken: mock)
		XCTAssertNil(decoded)
	}
	
	func testDecodeNonBase64Failure() {
		let mock = "JWTMocks.stringMock.test"
		
		let decoded = sut.decode(jwtToken: mock)
		
		XCTAssertNil(decoded)
	}
}
