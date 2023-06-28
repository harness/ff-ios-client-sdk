//
//  JSONDataEncodingTest.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 4.2.21..
//

import XCTest

@testable import ff_ios_client_sdk

class JSONDataEncodingTest: XCTestCase {

  var sut: JSONDataEncoding!

  override func setUp() {
    super.setUp()
    sut = JSONDataEncoding()
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }

  func testEncode() {
    let url = URL(string: "https://mock.com")!
    let key = "jsonData"
    let data = "somedataobject".data(using: .utf8)
    let bodyDict: [String: Any] = [key: data!]
    let req = URLRequest(url: url)

    let reqWithBody = sut.encode(req, with: bodyDict)

    XCTAssertNotNil(reqWithBody.httpBody)
  }
  func testEncodeEmptyBody() {
    let url = URL(string: "https://mock.com")!
    let bodyDict: [String: Any] = [:]
    let req = URLRequest(url: url)

    let reqWithBody = sut.encode(req, with: bodyDict)

    XCTAssertNil(reqWithBody.httpBody)
  }

  func testEncodeInvalidKey() {
    let url = URL(string: "https://mock.com")!
    let req = URLRequest(url: url)
    let reqWithBody = sut.encode(req, with: nil)
    XCTAssertNotNil(reqWithBody.url)
  }
}
