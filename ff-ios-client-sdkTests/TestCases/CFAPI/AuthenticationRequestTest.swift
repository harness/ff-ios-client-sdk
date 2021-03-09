//
//  AuthenticationRequestTest.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 16.2.21..
//

import XCTest
@testable import ff_ios_client_sdk

class AuthenticationRequestTest: XCTestCase {
    
	let cfClient = CfClient.sharedInstance
	let mockCache = MockStorageSource() //storage that does not save and throws an error
    override func setUp() {
        super.setUp()
		let mockAuthManager = AuthenticationManagerMock()
		let mockAPIManager = DefaultAPIManagerMock()
		let mockEventSourceManager = EventSourceManagerMock()
		
		cfClient.authenticationManager = mockAuthManager
		cfClient.eventSourceManager = mockEventSourceManager
		let config = CfConfiguration.builder().build()
		
		let repository = FeatureRepository(token: "someToken", storageSource: mockCache, config: config, defaultAPIManager: mockAPIManager)
		cfClient.featureRepository = repository
    }
    
    override func tearDown() {
        super.tearDown()
    }
	
	func testAuthorizationSuccess() {
		// Given
		let exp = XCTestExpectation(description: #function)
		let configuration = CfConfiguration.builder().setTarget("success").build()
		let target = CfTarget.builder().build()
		
		// When
		cfClient.initialize(apiKey: "someSuccessApiKey", configuration: configuration, target: target, cache: mockCache) { (result) in
			switch result {
				case .failure(let error):
					// Then
					XCTAssertNotNil(error)
					exp.fulfill()
				case .success():
					// Then
					XCTAssert(true)
					exp.fulfill()
			}
		}
		self.wait(for: [exp], timeout: 5)
	}
	
	func testAuthorizationSuccessFailedStorage() {
		// Given
		let exp = XCTestExpectation(description: #function)
		let configuration = CfConfiguration.builder().setTarget("success").build()
		let target = CfTarget.builder().build()
		
		// When
		cfClient.initialize(apiKey: "someSuccessApiKey", configuration: configuration, target: target, cache: mockCache) { (result) in
			switch result {
				case .failure(let error):
					// Then
					XCTAssertNotNil(error)
					exp.fulfill()
				case .success():
					// Then
					XCTAssert(true)
					exp.fulfill()
			}
		}
		self.wait(for: [exp], timeout: 5)
	}
	
	func testAuthorizationFailure() {
		// Given
		let exp = XCTestExpectation(description: #function)
		let configuration = CfConfiguration.builder().setTarget("failure").build()
		let target = CfTarget.builder().build()
		
		// When
		cfClient.initialize(apiKey: "someFailureApiKey", configuration: configuration, target: target, cache: mockCache) { (result) in
			switch result {
				case .failure(let error):
					// Then
					XCTAssertNotNil(error)
					exp.fulfill()
				case .success:
					// Then
					XCTAssert(true)
					exp.fulfill()
			}
		}
		self.wait(for: [exp], timeout: 5)
	}
	
	func testProperURLsFromSetConfiguration() {
		// Given
		let exp = XCTestExpectation(description: #function)
		let config = CfConfiguration.builder().setConfigUrl("https://testBaseURL.com").setTarget("success").build()
		let target = CfTarget.builder().build()
		
		// When
		cfClient.initialize(apiKey: "someSuccessApiKey", configuration: config, target: target, cache: mockCache) { (result) in
			switch result {
				case .failure(let error):
					// Then
					XCTAssertNotNil(error)
					exp.fulfill()
				case .success:
					// Then
					XCTAssertEqual(OpenAPIClientAPI.configPath, "https://testBaseURL.com")
					exp.fulfill()
			}
		}
		self.wait(for: [exp], timeout: 5)
	}
	
	func testGetEvaluationByIdSuccessString() {
		// Given
		let exp = XCTestExpectation(description: #function)
		let eval = CacheMocks.createFlagMocks(.string("stringTestFlagKey"), count: 1).first!
		var resultEval: Evaluation?
		
		// When
		var config = CfConfiguration.builder().build()
		config.environmentId = "c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d"
		config.target = "success"
		cfClient.featureRepository.config = config
		let key = CfConstants.Persistance.feature(config.environmentId, config.target, eval.flag).value
		try? cfClient.featureRepository.storageSource.saveValue(eval, key: key)
		cfClient.stringVariation(evaluationId: eval.flag, target: config.target, defaultValue: "defaultString") { (evaluation) in
			resultEval = evaluation
			exp.fulfill()
		}
		
		// Then
		wait(for: [exp], timeout: 2)
		XCTAssertEqual(resultEval?.flag, eval.flag)
		XCTAssertEqual(resultEval?.value, eval.value)
	}
	
	func testGetEvaluationByIdSuccessBool() {
		// Given
		let exp = XCTestExpectation(description: #function)
		let eval = CacheMocks.createFlagMocks(.bool(true), count: 1).first!
		var resultEval: Evaluation?
		
		// When
		var config = CfConfiguration.builder().build()
		config.environmentId = "c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d"
		config.target = "success"
		cfClient.featureRepository.config = config
		let key = CfConstants.Persistance.feature(config.environmentId, config.target, eval.flag).value
		try? cfClient.featureRepository.storageSource.saveValue(eval, key: key)
		cfClient.boolVariation(evaluationId: eval.flag, target: config.target, defaultValue: false) { (evaluation) in
			resultEval = evaluation
			exp.fulfill()
		}
		
		// Then
		wait(for: [exp], timeout: 2)
		XCTAssertEqual(resultEval?.flag, eval.flag)
		XCTAssertEqual(resultEval?.value, eval.value)
	}
	
	func testGetEvaluationByIdSuccessNumber() {
		// Given
		let exp = XCTestExpectation(description: #function)
		let eval = CacheMocks.createFlagMocks(.int(5), count: 1).first!
		var config = CfConfiguration.builder().build()
		config.environmentId = "c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d"
		config.target = "success"
		cfClient.featureRepository.config = config
		let key = CfConstants.Persistance.feature(config.environmentId, config.target, eval.flag).value
		try? cfClient.featureRepository.storageSource.saveValue(eval, key: key)
		var resultEval: Evaluation?

		// When
		cfClient.numberVariation(evaluationId: eval.flag, target: config.target, defaultValue: 1) { (evaluation) in
			resultEval = evaluation
			exp.fulfill()
		}
		
		// Then
		wait(for: [exp], timeout: 2)
		XCTAssertEqual(resultEval?.flag, eval.flag)
		XCTAssertEqual(resultEval?.value, eval.value)
	}
	
	func testGetEvaluationByIdSuccessObject() {
		// Given
		let exp = XCTestExpectation(description: #function)
		let eval = CacheMocks.createFlagMocks(.object(["objectKey":.int(5)]), count: 1).first!
		var config = CfConfiguration.builder().build()
		config.environmentId = "c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d"
		config.target = "success"
		cfClient.featureRepository.config = config
		let key = CfConstants.Persistance.feature(config.environmentId, config.target, eval.flag).value
		try? cfClient.featureRepository.storageSource.saveValue(eval, key: key)
		var resultEval: Evaluation?

		// When
		cfClient.jsonVariation(evaluationId: eval.flag, target: config.target, defaultValue: ["defaultObjKey":.bool(false)]) { (evaluation) in
			resultEval = evaluation
			exp.fulfill()
		}
		
		// Then
		wait(for: [exp], timeout: 2)
		XCTAssertEqual(resultEval?.flag, eval.flag)
		XCTAssertEqual(resultEval?.value, eval.value)
	}
	
	func testGetEvaluationByIdFailureDefaultStringValue() {
		// Given
		let exp = XCTestExpectation(description: #function)
		let eval = CacheMocks.createFlagMocks(.string("stringVal"), count: 1).first!
		var config = CfConfiguration.builder().build()
		config.environmentId = "c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d"
		config.target = "success"
		cfClient.featureRepository.config = config
		let key = CfConstants.Persistance.feature(config.environmentId, config.target, eval.flag).value
		try? cfClient.featureRepository.storageSource.saveValue(eval, key: key)
		var resultEval: Evaluation?
		
		// When
		cfClient.stringVariation(evaluationId: "randomString", target: config.target, defaultValue: "defaultString") { (evaluation) in
			resultEval = evaluation
			exp.fulfill()
		}
		
		// Then
		wait(for: [exp], timeout: 2)
		XCTAssertEqual(resultEval?.flag, "randomString")
		XCTAssertEqual(resultEval?.value.stringValue, "defaultString")
	}
	
	func testGetEvaluationByIdFailureDefaultBoolValue() {
		// Given
		let exp = XCTestExpectation(description: #function)
		let eval = CacheMocks.createFlagMocks(.bool(true), count: 1).first!
		var config = CfConfiguration.builder().build()
		config.environmentId = "c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d"
		config.target = "success"
		cfClient.featureRepository.config = config
		let key = CfConstants.Persistance.feature(config.environmentId, config.target, eval.flag).value
		try? cfClient.featureRepository.storageSource.saveValue(eval, key: key)
		var resultEval: Evaluation?
		
		// When
		cfClient.boolVariation(evaluationId: "randomBool", target: config.target, defaultValue: false) { (evaluation) in
			resultEval = evaluation
			exp.fulfill()
		}
		
		// Then
		wait(for: [exp], timeout: 2)
		XCTAssertEqual(resultEval?.flag, "randomBool")
		XCTAssertEqual(resultEval?.value.boolValue, false)
	}
	
	func testGetEvaluationByIdFailureDefaultNumberValue() {
		// Given
		let exp = XCTestExpectation(description: #function)
		let eval = CacheMocks.createFlagMocks(.int(5), count: 1).first!
		var config = CfConfiguration.builder().build()
		config.environmentId = "c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d"
		config.target = "success"
		cfClient.featureRepository.config = config
		let key = CfConstants.Persistance.feature(config.environmentId, config.target, eval.flag).value
		try? cfClient.featureRepository.storageSource.saveValue(eval, key: key)
		var resultEval: Evaluation?
		
		// When
		cfClient.numberVariation(evaluationId: "randomInt", target: config.target, defaultValue: 1) { (evaluation) in
			resultEval = evaluation
			exp.fulfill()
		}
		
		// Then
		wait(for: [exp], timeout: 2)
		XCTAssertEqual(resultEval?.flag, "randomInt")
		XCTAssertEqual(resultEval?.value.intValue, 1)
	}
	
	func testGetEvaluationByIdFailureDefaultObjectValue() {
		// Given
		let exp = XCTestExpectation(description: #function)
		let eval = CacheMocks.createFlagMocks(.object(["objectKey":.bool(false)]), count: 1).first!
		var config = CfConfiguration.builder().build()
		config.environmentId = "c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d"
		config.target = "success"
		cfClient.featureRepository.config = config
		let key = CfConstants.Persistance.feature(config.environmentId, config.target, eval.flag).value
		try? cfClient.featureRepository.storageSource.saveValue(eval, key: key)
		var resultEval: Evaluation?
		
		// When
		cfClient.jsonVariation(evaluationId: "randomObject", target: config.target, defaultValue: ["defaultObjKey":.bool(false)]) { (evaluation) in
			resultEval = evaluation
			exp.fulfill()
		}
		
		// Then
		wait(for: [exp], timeout: 2)
		XCTAssertEqual(resultEval?.flag, "randomObject")
		XCTAssertEqual(resultEval?.value.objectValue, ["defaultObjKey":.bool(false)])
	}
	
	func testGetEvaluationByIdFailureNilDefaultStringValue() {
		// Given
		let exp = XCTestExpectation(description: #function)
		let eval = CacheMocks.createFlagMocks(count: 1).first!
		var config = CfConfiguration.builder().build()
		config.environmentId = "c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d"
		config.target = "success"
		cfClient.featureRepository.config = config
		let key = CfConstants.Persistance.feature(config.environmentId, config.target, eval.flag).value
		try? cfClient.featureRepository.storageSource.saveValue(eval, key: key)
		var resultEval: Evaluation?

		// When
		cfClient.stringVariation(evaluationId: "non-existentKey_forcing_failure", target: config.target, defaultValue: nil) { (evaluation) in
			resultEval = evaluation
			exp.fulfill()
		}
		
		// Then
		wait(for: [exp], timeout: 2)
		XCTAssertNil(resultEval)
	}
	
	func testGetEvaluationByIdFailureNilDefaultBoolValue() {
		// Given
		let exp = XCTestExpectation(description: #function)
		let eval = CacheMocks.createFlagMocks(count: 1).first!
		var config = CfConfiguration.builder().build()
		config.environmentId = "c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d"
		config.target = "success"
		cfClient.featureRepository.config = config
		let key = CfConstants.Persistance.feature(config.environmentId, config.target, eval.flag).value
		try? cfClient.featureRepository.storageSource.saveValue(eval, key: key)
		var resultEval: Evaluation?

		// When
		cfClient.boolVariation(evaluationId: "non-existentKey_forcing_failure", target: config.target, defaultValue: nil) { (evaluation) in
			resultEval = evaluation
			exp.fulfill()
		}
		
		// Then
		wait(for: [exp], timeout: 2)
		XCTAssertNil(resultEval)
	}
	
	func testGetEvaluationByIdFailureNilDefaultNumberValue() {
		// Given
		let exp = XCTestExpectation(description: #function)
		let eval = CacheMocks.createFlagMocks(count: 1).first!
		var config = CfConfiguration.builder().build()
		config.environmentId = "c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d"
		config.target = "success"
		cfClient.featureRepository.config = config
		let key = CfConstants.Persistance.feature(config.environmentId, config.target, eval.flag).value
		try? cfClient.featureRepository.storageSource.saveValue(eval, key: key)
		var resultEval: Evaluation?
		
		// When
		cfClient.numberVariation(evaluationId: "non-existentKey_forcing_failure", target: config.target, defaultValue: nil) { (evaluation) in
			resultEval = evaluation
			exp.fulfill()
		}
		
		// Then
		wait(for: [exp], timeout: 2)
		XCTAssertNil(resultEval)
	}
	
	func testGetEvaluationByIdFailureNilDefaultObjectValue() {
		// Given
		let exp = XCTestExpectation(description: #function)
		let eval = CacheMocks.createFlagMocks(count: 1).first!
		var config = CfConfiguration.builder().build()
		config.environmentId = "c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d"
		config.target = "success"
		cfClient.featureRepository.config = config
		let key = CfConstants.Persistance.feature(config.environmentId, config.target, eval.flag).value
		try? cfClient.featureRepository.storageSource.saveValue(eval, key: key)
		var resultEval: Evaluation?

		// When
		cfClient.jsonVariation(evaluationId: "non-existentKey_forcing_failure", target: config.target, defaultValue: nil) { (evaluation) in
			resultEval = evaluation
			exp.fulfill()
		}
		
		// Then
		wait(for: [exp], timeout: 2)
		XCTAssertNil(resultEval)
	}
	
	func testSaveUnsupportedValue() {
		// Given
		var config = CfConfiguration.builder().build()
		config.environmentId = "c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d"
		let eval = CacheMocks.createEvalForStringType(CacheMocks.TestFlagValue.unsupported(.unsupported).key)
		try? cfClient.featureRepository.storageSource.saveValue(eval, key: eval!.flag)
		
		// When
		cfClient.stringVariation(evaluationId: eval!.flag, target: config.target, { (evaluation) in
			// Then
			XCTAssertNil(evaluation)
		})
	}
}
