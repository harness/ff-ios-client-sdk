//
//  DestroyReinitializeTest.swift
//  ff-ios-client-sdkTests
//
//  FFM-13064: initialize() after destroy() must fire its completion callback.
//

import XCTest

@testable import ff_ios_client_sdk

class DestroyReinitializeTest: XCTestCase {

  let cfClient = CfClient.sharedInstance
  let mockCache = CfCache()

  override func setUp() {
    super.setUp()
    CfClient.makeDefaultAPIManager = { DefaultAPIManagerMock() }

    let mockAuthManager = AuthenticationManagerMock()
    let mockAPIManager = DefaultAPIManagerMock()
    let mockEventSourceManager = EventSourceManagerMock()

    cfClient.authenticationManager = mockAuthManager
    cfClient.eventSourceManager = mockEventSourceManager

    let config = CfConfiguration.builder().build()
    let target = CfTarget.builder().setIdentifier("success").build()

    let repository = FeatureRepository(
      token: "someToken",
      cluster: "1",
      storageSource: mockCache,
      config: config,
      target: target,
      defaultAPIManager: mockAPIManager
    )
    cfClient.featureRepository = repository
    cfClient.configuration = config
  }

  override func tearDown() {
    CfClient.makeDefaultAPIManager = { DefaultAPIManager() }
    super.tearDown()
  }

  func testInitializeAfterDestroyCompletesSuccessfully() {
    let firstInit = XCTestExpectation(description: "first initialize succeeds")
    let destroyed = XCTestExpectation(description: "destroy succeeds")
    // FFM-13064: without the fix this expectation times out (callback never fires).
    let secondInit = XCTestExpectation(description: "second initialize succeeds")

    let configuration = CfConfiguration.builder().setStreamEnabled(false).build()
    let target = CfTarget.builder().setIdentifier("success").build()

    cfClient.initialize(
      apiKey: "someSuccessApiKey",
      configuration: configuration,
      target: target,
      cache: mockCache
    ) { result in
      switch result {
      case .success:
        firstInit.fulfill()
      case .failure(let error):
        XCTFail("first initialize failed: \(error)")
        firstInit.fulfill()
      }
    }
    wait(for: [firstInit], timeout: 5)

    XCTAssertNotNil(
      cfClient.featureRepository.defaultAPIManager,
      "API manager should exist after first initialize"
    )

    cfClient.destroy { result in
      switch result {
      case .success:
        destroyed.fulfill()
      case .failure(let reason):
        XCTFail("destroy failed: \(reason)")
        destroyed.fulfill()
      }
    }
    wait(for: [destroyed], timeout: 5)

    XCTAssertNil(
      cfClient.featureRepository.defaultAPIManager,
      "destroy() should nil defaultAPIManager"
    )

    cfClient.initialize(
      apiKey: "someSuccessApiKey",
      configuration: configuration,
      target: target,
      cache: mockCache
    ) { result in
      switch result {
      case .success:
        secondInit.fulfill()
      case .failure(let error):
        XCTFail("second initialize failed: \(error)")
        secondInit.fulfill()
      }
    }

    wait(for: [secondInit], timeout: 5)

    XCTAssertNotNil(
      cfClient.featureRepository.defaultAPIManager,
      "API manager should be restored after re-initialize"
    )
  }
}
