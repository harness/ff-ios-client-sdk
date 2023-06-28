//
//  EventStreamParserTest.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 22.2.21..
//

import XCTest

@testable import ff_ios_client_sdk

class EventStreamParserTest: XCTestCase {
  let eventStreamParser = EventStreamParser()

  override func setUp() {
    super.setUp()

  }

  override func tearDown() {
    super.tearDown()
  }

  func testAppend() {
    // Given
    let eventsString = """
      				id: event-id-1
      				data: event-data-first\n
      				id: event-id-2
      				data: event-data-second\n
      				id: event-id-3
      				data: event-data-third\n\n
      				"""
    let data = eventsString.data(using: .utf8)

    // When
    let result = eventStreamParser.append(data: data)

    // Then
    XCTAssertEqual(result[0].id, "event-id-1")
    XCTAssertEqual(result[0].data, "event-data-first")
    XCTAssertNil(result[0].event)
    XCTAssertNil(result[0].retryTime)
    XCTAssertFalse(result[0].onlyRetryEvent!)
  }

  func testAppendSame() {
    // Given
    let eventsString = """
      				id: event-id-1
      				id: event-id-1\n
      				id: event-id-1
      				data: event-id-1\n
      				id: event-id-3
      				data: event-data-third\n\n
      				"""
    let data = eventsString.data(using: .utf8)

    // When
    let result = eventStreamParser.append(data: data)

    // Then
    XCTAssertEqual(result[0].id, "event-id-1\nevent-id-1")
    XCTAssertNil(result[0].event)
    XCTAssertNil(result[0].retryTime)
    XCTAssertFalse(result[0].onlyRetryEvent!)
  }

  func testAppendDataNil() {
    // Given
    let eventsString = """
      				\n
      				\n
      				\n\n
      				"""
    let data = eventsString.data(using: .utf8)

    // When
    let result = eventStreamParser.append(data: data)

    // Then
    XCTAssertNil(result[0].id)
    XCTAssertNil(result[0].data)
    XCTAssertNil(result[0].event)
    XCTAssertNil(result[0].retryTime)
    XCTAssertFalse(result[0].onlyRetryEvent!)
  }

  func testAppendPrefix() {
    // Given
    let eventsString = """
      				:id: event-id-1
      				data: event-data-first\n
      				id: event-id-2
      				data: event-data-second\n
      				id: event-id-3
      				data: event-data-third\n\n
      				"""
    let data = eventsString.data(using: .utf8)

    // When
    let result = eventStreamParser.append(data: data)

    // Then
    XCTAssertEqual(result[1].id, "event-id-3")
    XCTAssertEqual(result[1].data, "event-data-third")
    XCTAssertNil(result[1].event)
    XCTAssertNil(result[1].retryTime)
    XCTAssertFalse(result[1].onlyRetryEvent!)
  }

  func testAppendCorrectTime() {
    // Given
    let eventsString = """
      				id: event-id-1
      				data: event-data-first\n
      				id: event-id-2
      				data: event-data-second\n
      				id: event-id-3
      				retry: 8000
      				data: event-data-third\n\n
      				"""
    let data = eventsString.data(using: .utf8)

    // When
    let result = eventStreamParser.append(data: data)

    // Then
    XCTAssertEqual(result[2].id, "event-id-3")
    XCTAssertEqual(result[2].data, "event-data-third")
    XCTAssertNil(result[2].event)
    XCTAssertEqual(result[2].retryTime, 8000)
    XCTAssertFalse(result[2].onlyRetryEvent!)
  }

  func testAppendIncorrectTime() {
    // Given
    let eventsString = """
      				id: event-id-1
      				data: event-data-first\n
      				id: event-id-2
      				data: event-data-second\n
      				id: event-id-3
      				retry: sometime
      				data: event-data-third\n\n
      				"""
    let data = eventsString.data(using: .utf8)

    // When
    let result = eventStreamParser.append(data: data)

    // Then
    XCTAssertEqual(result[2].id, "event-id-3")
    XCTAssertEqual(result[2].data, "event-data-third")
    XCTAssertNil(result[2].event)
    XCTAssertEqual(result[2].retryTime, nil)
    XCTAssertFalse(result[2].onlyRetryEvent!)
  }

  func testAppendOnlyRetry() {
    // Given
    let eventsString = """
      				retry: 6000\n\n
      				"""
    let data = eventsString.data(using: .utf8)

    // When
    let result = eventStreamParser.append(data: data)

    // Then
    XCTAssertEqual(result[0].id, nil)
    XCTAssertEqual(result[0].data, nil)
    XCTAssertNil(result[0].event)
    XCTAssertEqual(result[0].retryTime, 6000)
    XCTAssertTrue(result[0].onlyRetryEvent!)
  }
}
