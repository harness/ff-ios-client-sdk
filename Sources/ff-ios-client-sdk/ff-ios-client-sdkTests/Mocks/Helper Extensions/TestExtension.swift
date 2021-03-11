//
//  TestExtension.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 20.2.21..
//

import XCTest
@testable import ff_ios_client_sdk

extension XCTestCase {
	func await<T>(_ function: (@escaping (Swift.Result<T, ff_ios_client_sdk.CFError>) -> ()) -> ()) -> T? {
		let expectation = self.expectation(description: "Async call")
		var result: T?
		
		function() { value in
			switch value {
				case .success(let val):
					result = val
					expectation.fulfill()
				case .failure(_):
					expectation.fulfill()
					result = nil
			}
		}
		
		waitForExpectations(timeout: 3)
		return result
	}
}
