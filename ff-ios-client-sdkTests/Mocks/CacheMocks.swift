//
//  CacheMocks.swift
//  ff_ios_client_sdkTests
//
//  Created by Dusan Juranovic on 2.2.21..
//

import Foundation
@testable import ff_ios_client_sdk

struct CacheMocks {
	enum TestFlagValue {
		case string(ValueType)
		case bool(ValueType)
		case int(ValueType)
		case object(ValueType)
		case unsupported(ValueType)
		
		enum RawValue: Int, CaseIterable {
			case string
			case bool
			case int
			case object
			case unsupported
		}
		
		
		init(_ rawValue: RawValue) {
			switch rawValue {
				case .string: self = .string(.string("stringTestFlagValue"))
				case .bool: self = .bool(.bool(true))
				case .int: self = .int(.int(5))
				case .object: self = .object(.object(["objectTestFlagKey":.string("objectTestFlagValue")]))
				case .unsupported: self = .unsupported(.unsupported)
			}
		}
		
		var key: String {
			switch self {
				case .string: return "stringTestFlagKey"
				case .bool: return "boolTestFlagKey"
				case .int: return "intTestFlagKey"
				case .object: return "objectTestFlagKey"
				case .unsupported: return "unsupportedTestFlagKey"
			}
		}
		
		var value: ValueType {
			switch self {
				case .string(let val): return val
				case .bool(let val): return val
				case .int(let val): return val
				case .object(let val): return val
				case .unsupported(let val): return val
			}
		}
	}
	static func createFlagMocks(_ type: ValueType? = nil, count: Int) -> [Evaluation]  {
		var mocks = [Evaluation]()
		for _ in 0..<count  {
			if let type = type {
				switch type {
					case .string(let stringVal): mocks.append(.init(flag: TestFlagValue(.string).key, value: ValueType.string(stringVal)))
					case .bool(let boolVal): mocks.append(.init(flag: TestFlagValue(.bool).key, value: ValueType.bool(boolVal)))
					case .int(let intVal): mocks.append(.init(flag: TestFlagValue(.int).key, value: ValueType.int(intVal)))
					case .object(let objectVal): mocks.append(.init(flag: TestFlagValue(.object).key, value: ValueType.object(objectVal)))
					case .unsupported: mocks.append(.init(flag: TestFlagValue(.unsupported).key, value: ValueType.unsupported))
				}
			} else {
				let random = Int(arc4random_uniform(UInt32(TestFlagValue.RawValue.allCases.count)))
				let randomValueType = TestFlagValue(TestFlagValue.RawValue(rawValue: random)!)
				mocks.append(.init(flag: randomValueType.key, value: randomValueType.value))
			}
		}
        return mocks
    }
	
	static func createEvalForStringType(_ string: String) -> Evaluation? {
		switch string {
			case "stringTestFlagKey": return createFlagMocks(.string("stringTestFlagValue"), count: 1).first!
			case "boolTestFlagKey": return createFlagMocks(.bool(true), count: 1).first!
			case "intTestFlagKey": return createFlagMocks(.int(5), count: 1).first!
			case "objectTestFlagKey": return createFlagMocks(.object(["objectTestFlagKey":.string("objectTestFlagValue")]), count: 1).first!
			case "unsupportedTestFlagKey": return createFlagMocks(.unsupported, count: 1).first!
			default: return nil
		}
	}
	
	static func createAllTypeFlagMocks() -> [Evaluation]  {
		var mocks = [Evaluation]()
		while mocks.count != 5 {
			let random = Int(arc4random_uniform(UInt32(TestFlagValue.RawValue.allCases.count)))
			let randomValueType = TestFlagValue(TestFlagValue.RawValue(rawValue: random)!)
			if !mocks.contains(where: {$0.value == randomValueType.value}) {
				mocks.append(.init(flag: randomValueType.key, value: randomValueType.value))
			}
		}
		return mocks
	}
}

class MockStorageSource: StorageRepositoryProtocol {
	var cache = [String:Any]()
	func saveValue<Value>(_ value: Value, key: String) throws where Value : Decodable, Value : Encodable {
		print("saving...")
		if key == CacheMocks.TestFlagValue.unsupported(.unsupported).key {
			throw ff_ios_client_sdk.CFError.cacheError(CFCacheError.writingToCacheFailed)
		}
		cache[key] = value
	}
	
	func getValue<Value>(forKey key: String) throws -> Value? where Value : Decodable, Value : Encodable {
		print("getting...")
		guard let entry = cache[key] else {
			throw ff_ios_client_sdk.CFError.cacheError(CFCacheError.readingFromCacheFailed)
		}
		return entry as? Value
	}
	
	func removeValue(forKey key: String) throws {
		print("removing...")
		cache = [:]
	}
}
