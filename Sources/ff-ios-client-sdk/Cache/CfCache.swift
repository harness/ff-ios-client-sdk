//
//  CfCache.swift
//  ff-ios-client-sdk
//
//  Created by Dusan Juranovic on 28.1.21..
//

import Foundation
import UIKit

public protocol StorageRepositoryProtocol {
  ///Implementation of this method will `save` Codable value to cache and/or storage. Default implementation is CfCache.
  func saveValue<Value: Codable>(_ value: Value, key: String) throws
  ///Implementation of this method will `get` Codable value from cache and/or storage. Default implementation is CfCache.
  func getValue<Value: Codable>(forKey key: String) throws -> Value?
  ///Implementation of this method will `remove` Codable value from cache and/or storage. Default implementation is CfCache.
  func removeValue(forKey key: String) throws
}

public final class CfCache: StorageRepositoryProtocol {
  static let log = SdkLog.get("io.harness.ff.sdk.ios.CfCache")

  ///In-memory cache
  var cache = [String: Any]()

  private let diskWriteQueue = DispatchQueue(label: "DiskWriteQueue")

  public init() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(
      self, selector: #selector(cleanupCache), name: UIApplication.didEnterBackgroundNotification,
      object: nil)
  }

  public func saveValue<Value: Codable>(_ value: Value, key: String) throws {
    cache[key] = value
    CfCache.log.trace("Saved to CACHE at key: \(key)")
    do {
      try saveToDisk(value, withName: key)
    } catch {
      CfCache.log.warn("ERROR: Failed to save value for key \(key): \(error)")
      throw error
    }
    CfCache.log.trace("Saved to DISK at key: \(key)")
  }

  public func getValue<Value: Codable>(forKey key: String) throws -> Value? {
    guard let entry = cache[key] else {
      do {
        let val: Value? = try readFromDisk(key)
        CfCache.log.trace("Fetched from DISK & updated CACHE for key: \(key)")
        cache[key] = val
        return val
      } catch CFError.cacheError(let error) {
        if error != .fileDoesNotExist {
          CfCache.log.warn("CACHE ERROR: \(error)")
        }

        throw error
      } catch {
        CfCache.log.warn("ERROR: Failed to get value for key \(key): \(error)")
        throw error
      }
    }
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

  private func saveToDisk<Value: Codable>(
    _ feature: Value, withName name: String, using fileManager: FileManager = .default
  ) throws {
    guard let url = makeURL(forFileNamed: name) else {
      throw CFError.cacheError(.invalidDirectory)
    }

    diskWriteQueue.async{
        do {
          let data = try! JSONEncoder().encode(feature)
          try data.write(to: url, options: .atomic)
        } catch {
          CfCache.log.warn("ERROR: Failed to write to disk path: \(url.path)")
        }

    }
  }

  private func readFromDisk<Value: Codable>(
    _ name: String, using fileManager: FileManager = .default
  ) throws -> Value? {
    guard let url = makeURL(forFileNamed: name) else {
      throw CFError.cacheError(.invalidDirectory)
    }
    guard fileManager.fileExists(atPath: url.path) else {
      CfCache.log.trace("WARN: Failed to read from disk path: \(url.path)")
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

  private func makeURL(forFileNamed fileName: String, using fileManager: FileManager = .default)
    -> URL?
  {
    guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
      !fileName.isEmpty
    else {
      return nil
    }
    return url.appendingPathComponent(fileName)
  }
}
