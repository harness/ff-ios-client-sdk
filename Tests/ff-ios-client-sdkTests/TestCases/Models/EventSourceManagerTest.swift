//
//  CFEventSourceTest.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 4.2.21..
//

import XCTest

@testable import ff_ios_client_sdk

class EventSourceManagerTest: XCTestCase {

  var sut: EventSourceManagerProtocol!
  var expectation: XCTestExpectation!

  override func setUp() {
    super.setUp()
    sut = EventSourceManagerMock()
    expectation = XCTestExpectation(description: #function)
  }
  override func tearDown() {
    super.tearDown()
    sut = nil
  }

  func testShared() {
    XCTAssertNotNil(sut)
  }

  func testStreamReady() {
    sut.connect(lastEventId: "event-id")
    XCTAssertTrue(sut.streamReady)
  }
  func testStreamNotReady() {
    sut.disconnect()
    XCTAssertFalse(sut.streamReady)
  }

  func testAddEventListenerSuccess() {
    // Given
    var callbackCalled = false
    let id = "someId"
    let event = "event-success"
    let data = """
      					{\"version\":3000,\"event\":\"someEvent\",\"identifier\":\"success\",\"domain\":\"someDomain\"}
      					"""

    var resultID = ""
    var resultEvent = ""
    var resultData = ""

    // When
    sut.addEventListener(event) { (id, event, data) in
      callbackCalled = true
      resultID = id!
      resultEvent = event!
      resultData = data!
      self.expectation.fulfill()
    }

    // Then
    self.wait(for: [expectation], timeout: 2)
    XCTAssertTrue(callbackCalled)
    XCTAssertEqual(id, resultID)
    XCTAssertEqual(event, resultEvent)

    do {
      if let expectedJson = try JSONSerialization.jsonObject(with: Data(data.utf8), options: []) as? [String: Any],
         let actualJson = try JSONSerialization.jsonObject(with: Data(resultData.utf8), options: []) as? [String: Any] {

        XCTAssertEqual(expectedJson["version"] as? Int, actualJson["version"] as? Int)
        XCTAssertEqual(expectedJson["event"] as? String, actualJson["event"] as? String)
        XCTAssertEqual(expectedJson["identifier"] as? String, actualJson["identifier"] as? String)
        XCTAssertEqual(expectedJson["domain"] as? String, actualJson["domain"] as? String)
      } else {
        XCTFail("JSONSerialization failed")
      }
    } catch let error as NSError {
      XCTFail(error.description)
    }
  }

  func testAddEventListenerFailure() {
    // Given
    var callbackCalled = false
    let event = "event-failure"

    var resultID: String?
    var resultEvent: String?
    var resultData: String?

    // When
    sut.addEventListener(event) { (id, event, data) in
      callbackCalled = true
      resultID = id
      resultEvent = event
      resultData = data
      self.expectation.fulfill()
    }

    // Then
    self.wait(for: [expectation], timeout: 2)
    XCTAssertTrue(callbackCalled)
    XCTAssertNil(resultID)
    XCTAssertNil(resultEvent)
    XCTAssertNil(resultData)
  }
  func testOnOpen() {
    // Given
    var callbackCalled = false

    // When
    sut.onOpen {
      callbackCalled = true
      self.expectation.fulfill()
    }

    // Then
    self.wait(for: [expectation], timeout: 2)
    XCTAssertTrue(callbackCalled)
  }

  func testOnMessage() {
    // Given
    var callbackCalled = false

    // When
    sut.onMessage { (id, event, data) in
      callbackCalled = true
      self.expectation.fulfill()
    }

    // Then
    self.wait(for: [expectation], timeout: 2)
    XCTAssertTrue(callbackCalled)
  }

  func testOnCompleted() {
    // Given
    var callbackCalled = false

    // When
    sut.onComplete { (code, retry, error) in
      callbackCalled = true
      self.expectation.fulfill()
    }

    // Then
    self.wait(for: [expectation], timeout: 2)
    XCTAssertTrue(callbackCalled)
  }

}
