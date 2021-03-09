//
//  RegisterForEventsTest.swift
//  ff-ios-client-sdkTests
//
//  Created by Dusan Juranovic on 20.2.21..
//

import XCTest
@testable import ff_ios_client_sdk

class RegisterForEventsTest: XCTestCase {
	
	let cfClient = CfClient.sharedInstance
	let mockCache = MockStorageSource()
	override func setUp() {
		super.setUp()
		let authManager = AuthenticationManagerMock()
		cfClient.authenticationManager = authManager
		
		var config = CfConfiguration.builder().build()
		config.environmentId = "someId"
		
		let target = CfTarget.builder().build()
		
		let defaultAPIManager = DefaultAPIManagerMock()
		let repository = FeatureRepository(token: "someToken", storageSource: mockCache, config: config, target: target, defaultAPIManager: defaultAPIManager)

		cfClient.featureRepository = repository
		cfClient.configuration = config
		cfClient.isInitialized = true
		cfClient.eventSourceManager = EventSourceManagerMock.shared()
	}
	
	override func tearDown() {
		super.tearDown()

	}
	
	func testRegisterForEventsFailure() {
		// Given
		var config = CfConfiguration.builder().setStreamEnabled(true).build()
		config.environmentId = "failID"
		cfClient.configuration = config
		var callbackCalled = false
		
		// When
		cfClient.registerEventsListener { (result) in
			switch result {
				case .failure(let error):
					// Then
					callbackCalled = true
					XCTAssertNotNil(error)
				case .success(let eventType):
					// Then
					callbackCalled = true
					XCTAssertNotNil(eventType)
			}
		}
		
		// Then
		XCTAssertTrue(callbackCalled)
	}
	
	func testNetworkAvailable() {
		// Given
		cfClient.networkInfoProvider = NetworkInfoProviderMock()
		
		// When
		cfClient.networkInfoProvider?.networkStatus({ (reachable) in
			// Then
			XCTAssertTrue(reachable)
		})
		cfClient.networkInfoProvider?.startNotifier()
	}
	
	func testNetworkUnavailable() {
		// Given
		cfClient.networkInfoProvider = NetworkInfoProviderMock()
		
		// When
		cfClient.networkInfoProvider?.networkStatus({ (reachable) in
			//Then
			XCTAssertFalse(reachable)
		})
		cfClient.networkInfoProvider?.stopNotifier()
	}
	
	func testRegisterForEventsSuccess() {
		// Given
		let exp = XCTestExpectation(description: #function)
		var config = CfConfiguration.builder().setStreamEnabled(true).build()
		let eval = Evaluation(flag: "testRegisterEventSuccessFlag", value: .bool(true))
		try? cfClient.featureRepository.storageSource.saveValue(eval, key: "SODOD")
		config.environmentId = "successID"
		cfClient.configuration = config
		var callbackCalled = false
		
		// When
		cfClient.registerEventsListener(["event-success"]) { (result) in
			switch result {
				case .failure(let error):
					// Then
					callbackCalled = true
					XCTAssertNotNil(error)
					exp.fulfill()
				case .success(let eventType):
					switch eventType {
						case .onOpen:
							// Then
							callbackCalled = true
							XCTAssertEqual(eventType, EventType.onOpen)
							exp.fulfill()
						case .onComplete:
							// Then
							callbackCalled = true
							XCTAssertEqual(eventType, EventType.onComplete)
							exp.fulfill()
						case .onMessage:
							// Then
							callbackCalled = true
							XCTAssertEqual(eventType.comparableType, EventType.ComparableType.onMessage)
							exp.fulfill()
						case .onPolling:
							// Then
							callbackCalled = true
							XCTAssertEqual(eventType.comparableType, EventType.ComparableType.onPolling)
							exp.fulfill()
						case .onEventListener:
							// Then
							callbackCalled = true
							XCTAssertEqual(eventType.comparableType, EventType.ComparableType.onEventListener)
							exp.fulfill()
					}
			}
		}
		
		wait(for: [exp], timeout: 5)
		// Then
		XCTAssertTrue(callbackCalled)
	}
	
	func testRegisterPollingCallbackSuccess() {
		// Given
		let exp = expectation(description: #function)
		let evals = CacheMocks.createAllTypeFlagMocks()
		var callbackCalled = false
		
		// When
		cfClient.registerEventsListener { (result) in
			switch result {
				case .failure(_): break //Not used in this test
				case .success(let eventType):
					switch eventType {
						case .onPolling(let evaluations):
							// Then
							callbackCalled = true
							XCTAssertEqual(evaluations?.count, 5)
							exp.fulfill()
						default: break
					}
			}
		}
		cfClient.onPollingResultCallback?(.success(EventType.onPolling(evals)))
		wait(for: [exp], timeout: 5)
		// Then
		XCTAssertTrue(callbackCalled)
	}
	
	func testRegisterPollingCallbackFailure() {
		// Given
		let exp = expectation(description: #function)
		var callbackCalled = false
		
		// When
		cfClient.registerEventsListener { (result) in
			switch result {
				case .failure(let error):
					// Then
					callbackCalled = true
					XCTAssertNotNil(error)
					exp.fulfill()
				case .success(_): break //Not used in this test
			}
		}
		cfClient.onPollingResultCallback?(.failure(ff_ios_client_sdk.CFError.noDataError))
		
		wait(for: [exp], timeout: 3)
		
		// Then
		XCTAssertTrue(callbackCalled)
	}
	
	func testForceDisconnected() {
		// Given
		cfClient.eventSourceManager.forceDisconnected = true
		cfClient.configuration.streamEnabled = true
		let target = CfTarget.builder().setIdentifier("testTarget").build()
		
		cfClient.target = target
		var callbackCalled = false
		
		// When
		cfClient.registerEventsListener { (result) in
			switch result {
				case .failure(let error):
					//Then
					callbackCalled = true
					XCTAssertNotNil(error)
				case .success(let eventType):
					switch eventType {
						case .onComplete:
							callbackCalled = true
						default: break
					}
			}
		}
		
		// Then
		XCTAssertTrue(callbackCalled)
	}
	
	func testDestroy() {
		// Given
		cfClient.configuration.streamEnabled = true
		cfClient.isInitialized = true
		cfClient.onPollingResultCallback = {(result) in
			// Then pre destroy
			XCTAssertNotNil(result)
		}
		
		// When
		cfClient.onPollingResultCallback?(.success(.onOpen))
		cfClient.destroy()
		
		// Then
		XCTAssertFalse(cfClient.configuration.streamEnabled)
		XCTAssertFalse(cfClient.isInitialized)
		XCTAssertNil(cfClient.onPollingResultCallback)
	}
}
