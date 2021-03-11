//
//  JSONEncodingHelperTest.swift
//  
//
//  Created by Dusan Juranovic on 26.2.21..
//

import XCTest
@testable import ff_ios_client_sdk

class JSONEncodingHelperTest: XCTestCase {
	var sut = JSONEncodingHelper()
	
	override func setUp() {
		super.setUp()
		
	}
	override func tearDown() {
		super.tearDown()

	}
	
	
	func testEncodingParametersGenericSuccess() {
		let eval = ["someParamKey":"SOME_PARAM_VALUE"]
		let params = JSONEncodingHelper.encodingParameters(forEncodableObject: eval)
		let data = params?.first?.value as! Data
		let decoded = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:String]
		XCTAssertEqual(eval["someParamKey"], decoded["someParamKey"])
	}
	
	func testEncodingParametersGenericFailure() {
		let encodable = NonEvaluation(name: "TestEncodableName", value: "testVal")
		let params = JSONEncodingHelper.encodingParameters(forEncodableObject: encodable)
		let data = params?.first?.value as! Data
		let decoded = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:String]
		XCTAssertEqual(encodable.name, decoded["name"])
		XCTAssertEqual(encodable.value, decoded["value"])
	}
	
	func testEncodingParameters() {
		let eval = NonEncodable(name: "TestNonEncodableName", value: 3)
		let params = JSONEncodingHelper.encodingParameters(forEncodableObject: eval)
		let data = params?.first?.value as! Data
		let decoded = try! JSONDecoder().decode(NonEncodable.self, from: data)
		XCTAssertEqual(eval.name, decoded.name)
		XCTAssertEqual(eval.value, decoded.value)
	}
}

struct NonEncodable: Codable {
	var name: String
	var value: Int
}
