//
//  FeatureRepositoryTest.swift
//  ff-ios-client-sdkTests
//
//  Created by Dusan Juranovic on 7.2.21..
//

import XCTest
@testable import ff_ios_client_sdk

class FeatureRepositoryTest: XCTestCase {
    
	var sut: FeatureRepository?
	let mockCache = CfCache()
	var expectation: XCTestExpectation!
    override func setUp() {
        super.setUp()
		var config = CfConfiguration.builder().build()
		config.environmentId = "c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d"
		let target = CfTarget.builder().build()
        sut = FeatureRepository(token: nil, cluster: "1", storageSource: mockCache, config: config, target: target)
		sut!.defaultAPIManager = DefaultAPIManagerMock()
		expectation = XCTestExpectation(description: #function)
    }
    
    override func tearDown() {
		super.tearDown()
		
    }
    
    func testInitDefaultRepository() {
		// Given
		let token = "SomeTestToken"
		let config = CfConfiguration.builder().build()
		let target = CfTarget.builder().setIdentifier("testID").build()
		
		// When
        let defaultRepo = FeatureRepository(token: token, cluster: "1", storageSource: mockCache, config: config, target: target)
		
		// Then
		XCTAssertEqual(defaultRepo.token, token)
		XCTAssertEqual(defaultRepo.config.configUrl, config.configUrl)
		XCTAssertEqual(defaultRepo.config.environmentId, config.environmentId)
		XCTAssertEqual(defaultRepo.target.identifier, target.identifier)
		XCTAssertEqual(defaultRepo.config.pollingInterval, config.pollingInterval)
		XCTAssertEqual(defaultRepo.config.streamEnabled, config.streamEnabled)
		XCTAssertNotNil(defaultRepo.storageSource)
    }
    
    func testGetEvaluationSuccess() {
		// Given
		sut?.target.identifier = "success"
		
		// When
        sut!.getEvaluations(onCompletion:) { result in
            // Then
            XCTAssertNotNil(result)
            XCTAssertEqual(try? result.get().count, 4, "Expected count == 4")
        }
    }
	
	func testGetEvaluationFailure() {
		// Given
		sut?.target.identifier = "failure"
		
		// When
        sut!.getEvaluations(onCompletion:) { result in
            // Then
            XCTAssertNil(result)
        }
		

	}
	
	func testGetEvaluationByIdSuccessReplaceSuccess() {
		// Given
		let exp = expectation(description: #function)
		let replaceExp = expectation(description: #function)
		let operation = sut
		let manager = operation?.defaultAPIManager as! DefaultAPIManagerMock
		manager.replacementEnabled = true
		sut?.target.identifier = "success"
		let allKey = CfConstants.Persistance.features("c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d", "success").value
		let initialEvals = CacheMocks.createAllTypeFlagMocks()
		var callbackCalled = false
		var fetchedEval: Evaluation?
		
		// When
		try? operation?.storageSource.saveValue(initialEvals, key: allKey)
		
		operation?.getEvaluationById("boolTestFlagKey", target: "success", onCompletion: { (result) in
			switch result {
				case .failure(let error):
					// Then
					callbackCalled = true
					XCTAssertNotNil(error)
					exp.fulfill()
				case .success(let evaluation):
					// Then
					fetchedEval = evaluation
					callbackCalled = true
					XCTAssertNotNil(evaluation)
					XCTAssertEqual(evaluation.flag, fetchedEval?.flag)
					XCTAssertEqual(evaluation.value, fetchedEval?.value)
					exp.fulfill()
			}
		})
		
		
		// When
		let evals: [Evaluation]? = try? operation!.storageSource.getValue(forKey:"c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d_success_features")
		for eval in evals! {
			if eval.flag == fetchedEval!.flag {
				// Then
				XCTAssertEqual(eval.value, fetchedEval!.value)
				replaceExp.fulfill()
			}
		}
		wait(for: [exp, replaceExp], timeout: 5)
		// Then
		XCTAssertTrue(callbackCalled)
	}
	
	func testGetEvaluationByIdCloudSuccess() {
		// Given
		let exp = expectation(description: #function)
		let operation = sut
		let eval = CacheMocks.createFlagMocks(count: 1).first!
		let target = "success"
		var callbackCalled = false
		let key = CfConstants.Persistance.feature("c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d", target, eval.flag).value
		try? operation!.storageSource.saveValue(eval, key: key)
		
		// When
		operation?.getEvaluationById(eval.flag, target: target, onCompletion: { (result) in
			switch result {
				case .failure(let error):
					// Then
					XCTAssertNotNil(error)
					callbackCalled = true
					exp.fulfill()
				case .success(let evaluation):
					// Then
					XCTAssertNotNil(evaluation)
					XCTAssertEqual(evaluation.flag, eval.flag)
					XCTAssertEqual(evaluation.value, eval.value)
					callbackCalled = true
					exp.fulfill()
			}
		})
		wait(for: [exp], timeout: 5)
		// Then
		XCTAssertTrue(callbackCalled)
	}
	
	func testGetEvaluationByIdCloudFailureCacheFailure() {
		// Given
		let exp = expectation(description: #function)
		let operation = sut
		let key = "testStringFlagKey"
		var callbackCalled = false
		
		// When
		operation?.getEvaluationById(key, target: "cloud_failure_cache_failure", onCompletion: { (result) in
			switch result {
				case .failure(let error):
					// Then
					XCTAssertNotNil(error)
					callbackCalled = true
					exp.fulfill()
				case .success(let evaluation):
					// Then
					callbackCalled = true
					XCTAssertNil(evaluation)
					exp.fulfill()
			}
		})
		wait(for: [exp], timeout: 3)
		// Then
		XCTAssertTrue(callbackCalled)
	}
	
	func testGetEvaluationByIdCloudFailureCacheSuccess() {
		// Given
		let exp = expectation(description: #function)
		var callbackCalled = false
		let operation = sut
		let eval = CacheMocks.createEvalForStringType(CacheMocks.TestFlagValue(.string).key)!
		operation?.target.identifier = "cloud_failure_cache_failure"
		let key = CfConstants.Persistance.feature("c34fb8b9-9479-4e13-b4cc-d43c8f6b1a5d", "cloud_failure_cache_failure", eval.flag).value
		try? operation?.storageSource.saveValue(eval, key: key)
		
		// When
		operation?.getEvaluationById(eval.flag, target: "cloud_failure_cache_failure", onCompletion: { (result) in
			switch result {
				case .failure(let error):
					// Then
					XCTAssertNotNil(error)
					callbackCalled = true
					exp.fulfill()
				case .success(let evaluation):
					// Then
					callbackCalled = true
					XCTAssertNotNil(evaluation)
					XCTAssertEqual(eval.flag, evaluation.flag)
					XCTAssertEqual(eval.value, evaluation.value)
					exp.fulfill()
			}
		})
		
		wait(for: [exp], timeout: 3)
		// Then
		XCTAssertTrue(callbackCalled)
	}
}
