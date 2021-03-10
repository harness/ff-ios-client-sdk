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
	
	func testInitStringIntConvertableEvaluation() {
		// Given
		let flag  = "flag-mock"
		let value = ValueType.string("30")
		
		// When
		let evaluation = Evaluation(flag: flag, value: value)
		
		// Then
		XCTAssertEqual(evaluation.flag == flag, evaluation.value.stringValue == value.stringValue)
		XCTAssertNil(evaluation.value.boolValue)
		XCTAssertEqual(evaluation.value.intValue, 30)
		XCTAssertNil(evaluation.value.objectValue)
	}
	
	func testInitStringBoolConvertableEvaluationTrue() {
		// Given
		let flag  = "flag-mock"
		let value = ValueType.string("true")
		
		// When
		let evaluation = Evaluation(flag: flag, value: value)
		
		// Then
		XCTAssertEqual(evaluation.flag == flag, evaluation.value.stringValue == value.stringValue)
		XCTAssertEqual(evaluation.value.boolValue, true)
		XCTAssertNil(evaluation.value.intValue)
		XCTAssertNil(evaluation.value.objectValue)
	}
	
	func testInitStringBoolConvertableEvaluationFalse() {
		// Given
		let flag  = "flag-mock"
		let value = ValueType.string("false")
		
		// When
		let evaluation = Evaluation(flag: flag, value: value)
		
		// Then
		XCTAssertEqual(evaluation.flag == flag, evaluation.value.stringValue == value.stringValue)
		XCTAssertEqual(evaluation.value.boolValue, false)
		XCTAssertNil(evaluation.value.intValue)
		XCTAssertNil(evaluation.value.objectValue)
	}
	
	func testInitStringNotConvertableObjectEvaluation() {
		// Given
		let flag  = "flag-mock"
		let value = ValueType.string("{key:value}")
		
		// When
		let evaluation = Evaluation(flag: flag, value: value)
		
		// Then
		XCTAssertEqual(evaluation.flag == flag, evaluation.value.stringValue == value.stringValue)
		XCTAssertNil(evaluation.value.boolValue)
		XCTAssertNil(evaluation.value.intValue)
		XCTAssertNil(evaluation.value.objectValue)
	}
	
	
	func testInitIntEvaluationOne() {
		// Given
		let flag  = "flag-mock"
		let value = ValueType.int(1)
		
		// When
		let evaluation = Evaluation(flag: flag, value: value)
		
		// Then
		XCTAssertEqual(evaluation.flag == flag, evaluation.value.intValue == value.intValue)
		XCTAssertEqual(evaluation.value.stringValue, "1")
		XCTAssertEqual(evaluation.value.boolValue, true)
		XCTAssertNil(evaluation.value.objectValue)
	}
	
	func testInitIntEvaluationZero() {
		// Given
		let flag  = "flag-mock"
		let value = ValueType.int(0)
		
		// When
		let evaluation = Evaluation(flag: flag, value: value)
		
		// Then
		XCTAssertEqual(evaluation.flag == flag, evaluation.value.intValue == value.intValue)
		XCTAssertEqual(evaluation.value.stringValue, "0")
		XCTAssertEqual(evaluation.value.boolValue, false)
		XCTAssertNil(evaluation.value.objectValue)
	}
	
	func testInitBoolConvertableEvaluationTrue() {
		// Given
		let flag  = "flag-mock"
		let value = ValueType.bool(true)
		
		// When
		let evaluation = Evaluation(flag: flag, value: value)
		
		// Then
		XCTAssertEqual(evaluation.flag == flag, evaluation.value.boolValue == value.boolValue)
		XCTAssertEqual(evaluation.value.stringValue, "true")
		XCTAssertEqual(evaluation.value.intValue, 1)
		XCTAssertNil(evaluation.value.objectValue)
	}
	
	func testInitBoolConvertableEvaluationFalse() {
		// Given
		let flag  = "flag-mock"
		let value = ValueType.bool(false)
		
		// When
		let evaluation = Evaluation(flag: flag, value: value)
		
		// Then
		XCTAssertEqual(evaluation.flag == flag, evaluation.value.boolValue == value.boolValue)
		XCTAssertEqual(evaluation.value.stringValue, "false")
		XCTAssertEqual(evaluation.value.intValue, 0)
		XCTAssertNil(evaluation.value.objectValue)
	}
	
	func testInitIntNonConvertableBoolEvaluation() {
		// Given
		let flag  = "flag-mock"
		let value = ValueType.int(5)
		
		// When
		let evaluation = Evaluation(flag: flag, value: value)
		
		// Then
		XCTAssertEqual(evaluation.flag == flag, evaluation.value.intValue == value.intValue)
		XCTAssertEqual(evaluation.value.stringValue, "5")
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
		XCTAssertEqual(evaluation.value.stringValue, "\(value)")
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
