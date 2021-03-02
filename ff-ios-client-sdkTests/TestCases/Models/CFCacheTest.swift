//
//  CFCacheTests.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 1.2.21..
//

import XCTest
@testable import ff_ios_client_sdk

class CFCacheTest: XCTestCase {
	let key = "dummy-key"
	var sut: CFCache!
	
	override func setUp() {
		super.setUp()
		sut = CFCache()
	}
	
	override func tearDown() {
		sut = nil
		super.tearDown()
	}
	
	func testInit() {
		XCTAssertTrue(type(of: sut) === CFCache.self)
	}
	
	//MARK: Writing Tests
	func testSaveValueSuccess() {
		// Given
		let value: Evaluation = CacheMocks.createFlagMocks(count: 1).first!
		
		// When
		do {
			try sut.saveValue(value, key: key)
			let v = sut.cache[key] as? Evaluation
			
			// Then
			XCTAssertTrue(v!.flag.contains(value.flag))
		}catch {}
	}
	
	func testSaveValueFailure() {
		// Given
		let emptyKey = ""
		let value: Evaluation = CacheMocks.createFlagMocks(count: 1).first!
		
		// Then/When
		XCTAssertThrowsError(try sut.saveValue(value, key: emptyKey))
	}
	
	//MARK: Reading Tests
	func testReadValueSuccess() {
		// Given
		let insertValue: Evaluation = CacheMocks.createFlagMocks(count: 1).first!
		sut.cache = [key: insertValue]
		
		// When
		do {
			let dummy: Evaluation? = try sut.getValue(forKey: key)
			
			// Then
			XCTAssert(dummy!.flag.contains(insertValue.flag))
		}catch {}
	}
	
	func testReadNonExistentKeyFailure() {
		// Then/When
		XCTAssertThrowsError(try throwsErrorFunctionReadValue())
	}
	
	func testReadEmptyKeyFailure() {
		// Then/When
		XCTAssertThrowsError(try throwsErrorFunctionReadValue(key: ""))
	}
	
	func testReadDecodingFailure() {
		// Given
		let value = NonEvaluation(name: "NonName", value: "NonValue")
		let key = "invalidValueKey"
		try? sut.saveValue(value, key: key)
		sut.cache[key] = nil
		// Then/When
		XCTAssertThrowsError(try throwsErrorFunctionReadValue(key: key))
	}
	
	func testReadFromDisk() {
		// Given
		let key = "dummy-key"
		let value: Evaluation = CacheMocks.createFlagMocks(count: 1).first!
		
		// When
		try? sut.saveValue(value, key: key)
		sut.cache = [:]
		do {
			let dummy: DummyFlag? = try sut.getValue(forKey: key)
			
			// Then
			XCTAssert(dummy!.flag_id.contains(value.flag))
		}catch {}
	}
	
	func testReadingFromDiskFailed() {
		// Given
		let key = "dummy-key"
		let value: Evaluation = CacheMocks.createFlagMocks(count: 1).first!
		
		// When
		try? sut.saveValue(value, key: key)
		sut.cache = [:]
		
		// Then
		XCTAssertThrowsError(try throwsErrorFunctionReadValue())
	}
	
	//MARK: Removing Tests
	func testCleanupCache() {
		// When
		sut.cleanupCache()
		
		// Then
		XCTAssertTrue(sut.cache.isEmpty)
	}
	
	func testRemoveValueSuccess() {
		// Given
		let insertValue: Evaluation = CacheMocks.createFlagMocks(count: 1).first!
		sut.cache = [key: insertValue]
		
		// When
		try? sut.removeValue(forKey: key)
			
		// Then
		XCTAssertNil(sut.cache[key])
	}
	
	func testRemoveValueForEmptyURLPathFailure() {
		// Given
		let emptyKey = ""
		
		// Then/When
		XCTAssertThrowsError(try sut.removeValue(forKey: emptyKey))
	}
	
	func testRemoveValueForNonExistentURLPath() {
		// Given
		let randomKey = String.random(length: 12)
		
		// Then/When
		XCTAssertThrowsError(try sut.removeValue(forKey: randomKey))
	}
	
	//MARK: Helpers
	func throwsErrorFunctionReadValue(key: String = String.random(length: 5)) throws {
		do {
			let _ : Evaluation? = try sut.getValue(forKey: key)
		} catch {
			throw error
		}
	}
}
struct NonEvaluation: Codable {
	var name: String
	var value: String
}
