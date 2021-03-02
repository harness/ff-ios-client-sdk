//
//  EvaluationTest.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 4.2.21..
//

import XCTest
@testable import ff_ios_client_sdk


class EvaluationTest: XCTestCase {
    
    var sut: Evaluation!
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitStringEvaluation() {
		// Given
        let flag  = "flag-mock"
		let value = ValueType.string("test-value")
        
		// When
        let evaluation = Evaluation(flag: flag, value: value)
        
		// Then
		XCTAssertEqual(evaluation.flag == flag, evaluation.value.stringValue == value.stringValue)
		XCTAssertNil(evaluation.value.boolValue)
		XCTAssertNil(evaluation.value.intValue)
		XCTAssertNil(evaluation.value.objectValue)
    }
	
	func testInitBoolEvaluation() {
		// Given
		let flag  = "flag-mock"
		let value = ValueType.bool(true)
		
		// When
		let evaluation = Evaluation(flag: flag, value: value)
		
		// Then
		XCTAssertEqual(evaluation.flag == flag, evaluation.value.boolValue == value.boolValue)
		XCTAssertNil(evaluation.value.stringValue)
		XCTAssertNil(evaluation.value.intValue)
		XCTAssertNil(evaluation.value.objectValue)
	}
	
	func testInitIntEvaluation() {
		// Given
		let flag  = "flag-mock"
		let value = ValueType.int(5)
		
		// When
		let evaluation = Evaluation(flag: flag, value: value)
		
		// Then
		XCTAssertEqual(evaluation.flag == flag, evaluation.value.intValue == value.intValue)
		XCTAssertNil(evaluation.value.stringValue)
		XCTAssertNil(evaluation.value.boolValue)
		XCTAssertNil(evaluation.value.objectValue)
	}
	
	func testInitObjectEvaluation() {
		// Given
		let flag = "flag-mock"
		let value = ValueType.object(ValueType.Value(dictionaryLiteral: ("testKey", .string("testValue"))))
		
		// Then
		let evaluation = Evaluation(flag: flag, value: value)
		
		// Then
		XCTAssertEqual(evaluation.flag == flag, evaluation.value.objectValue == value.objectValue)
		XCTAssertNil(evaluation.value.stringValue)
		XCTAssertNil(evaluation.value.boolValue)
		XCTAssertNil(evaluation.value.intValue)
	}
	
	func testInitUnsupportedEvaluation() {
		// Given
		let flag = "flag-mock"
		let value = ValueType.unsupported
		
		// Then
		let evaluation = Evaluation(flag: flag, value: value)
		
		// Then
		XCTAssertEqual(evaluation.flag == flag, evaluation.value == value)
		XCTAssertNil(evaluation.value.stringValue)
		XCTAssertNil(evaluation.value.boolValue)
		XCTAssertNil(evaluation.value.intValue)
		XCTAssertNil(evaluation.value.objectValue)
	}
	
	func testDecodedEvaluationsSuccess() {
		let evaluations = CacheMocks.createAllTypeFlagMocks()
		
		for eval in evaluations {
			let encoded = try? JSONEncoder().encode(eval)
			let decoded = try? JSONDecoder().decode(Evaluation.self, from: encoded!)
			XCTAssertNotNil(decoded)
		}
	}
	
	func testDecodedEvaluationsFailure() {
		let evaluation = NonEvaluation(name: "Non-flag", value: "Non-value")
		XCTAssertThrowsError(try throwsErrorFunctionDecode(evaluation))
	}
	
	//MARK: Helpers
	func throwsErrorFunctionDecode(_ evaluation:NonEvaluation) throws {
		do {
			let encoded = try JSONEncoder().encode(evaluation)
			let _ = try JSONDecoder().decode(Evaluation.self, from: encoded)
		} catch {
			throw error
		}
	}
}
