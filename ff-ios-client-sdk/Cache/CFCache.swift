//
//  CFCache.swift
//  CFiOSClient
//
//  Created by Dusan Juranovic on 28.1.21..
//

import Foundation
import UIKit

public protocol StorageRepositoryProtocol {
	///Implementation of this method will `save` Codable value to cache and/or storage. Default implementation is CFCache.
	func saveValue<Value:Codable>(_ value:Value, key:String) throws
	///Implementation of this method will `get` Codable value from cache and/or storage. Default implementation is CFCache.
	func getValue<Value:Codable>(forKey key: String) throws -> Value?
	///Implementation of this method will `remove` Codable value from cache and/or storage. Default implementation is CFCache.
	func removeValue(forKey key: String) throws
}

public final class CFCache: StorageRepositoryProtocol {
	///In-memory cache
	var cache = [String:Any]()
	public init(){
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(cleanupCache), name: UIApplication.didEnterBackgroundNotification, object: nil)
	}
	
	public func saveValue<Value:Codable>(_ value: Value, key: String) throws {
		cache[key] = value
		Logger.log("Saved to CACHE at key: \(key)", spaceBelow: 0, enabled: false)
		do {
			try saveToDisk(value, withName: key)
		} catch {
			throw error
		}
		Logger.log("Saved to DISK at key: \(key)", enabled: false)
	}
	
	public func getValue<Value:Codable>(forKey key: String) throws -> Value? {
		guard let entry = cache[key] else {
			do {
				let val:Value? = try readFromDisk(key)
				Logger.log("Fetched from DISK & updated CACHE for key: \(key)")
				cache[key] = val
				return val
			} catch {
				throw error
			}
		}
		Logger.log("Fetched from CACHE for key: \(key)")
		return entry as? Value
	}
	
	public func removeValue(forKey key: String) throws {
		cache.removeValue(forKey: key)
		do {
			try removeFromDisk(key)
		} catch {
			throw CFError.cacheError(.readingFromDiskFailed)
		}
	}
	
	//MARK: - Private methods -
	//Called when the host app enters background in order to empty in-memory cache
	@objc func cleanupCache() {
		cache = [:]
	}
	
	private func saveToDisk<Value:Codable>(_ feature: Value, withName name: String, using fileManager: FileManager = .default) throws {
		guard let url = makeURL(forFileNamed: name) else {
			throw CFError.cacheError(.invalidDirectory)
		}
		do {
			let data = try JSONEncoder().encode(feature)
			try data.write(to: url, options: .atomic)
		} catch {
			throw error
		}
	}
	
	private func readFromDisk<Value:Codable>(_ name: String, using fileManager: FileManager = .default) throws -> Value? {
		guard let url = makeURL(forFileNamed: name) else {
			throw CFError.cacheError(.invalidDirectory)
		}
		guard fileManager.fileExists(atPath: url.path) else {
			throw CFError.cacheError(.fileDoesNotExist)
		}
		do {
			let fileContents = try Data(contentsOf: url)
			let decoded = try JSONDecoder().decode(Value.self, from: fileContents)
			return decoded
		} catch {
			throw error
		}
	}
	
	private func removeFromDisk(_ name: String, using fileManager: FileManager = .default) throws {
		guard let dirPath = makeURL(forFileNamed: name) else {
			throw CFError.cacheError(.invalidDirectory)
		}
		do {
			try fileManager.removeItem(at: dirPath)
		} catch {
			throw error
		}
	}
	
	private func makeURL(forFileNamed fileName: String, using fileManager: FileManager = .default) -> URL? {
		guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first, !fileName.isEmpty else {
			return nil
		}
		return url.appendingPathComponent(fileName)
	}
}
