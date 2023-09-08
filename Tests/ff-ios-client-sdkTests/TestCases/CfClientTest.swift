//
//  CfClientTest.swift
//  ff-ios-client-sdkTests
//
//  Created by Andrew Bell on 08/09/2023.
//

import XCTest

@testable import ff_ios_client_sdk

final class CfClientTest: XCTestCase {

    func testShouldNotThrowFatalErrorIfTargetIsNull() throws {
      let client = CfClient()

      client.fetchIfReady(evaluationId: "flag", defaultValue: "defaultValue", { (eval) in
        print("fetchIfReady returns: \(eval!)")
      })
    }

}
