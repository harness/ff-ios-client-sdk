//
//  ConcurrentDictionary.swift
//  ff-ios-client-sdk
//
//  Created by Andrew Bell on 08/02/2024.
//

import Foundation

final class PThread_RWLock {
  private final var lock: pthread_rwlock_t

  deinit {
    pthread_rwlock_destroy(&lock)
  }

  @inline(__always)
  init() {
    lock = pthread_rwlock_t()
    pthread_rwlock_init(&lock, nil)
  }

  @inline(__always)
  func readLock() {
      pthread_rwlock_rdlock(&lock)
  }

  @inline(__always)
  func writeLock() {
      pthread_rwlock_wrlock(&lock)
  }

  @inline(__always)
  func unlock() {
      pthread_rwlock_unlock(&lock)
  }
}

final class ConcurrentDictionary<Key: Hashable, Value> {

  private var dict: [Key: Value] = [:]
  private let lock = PThread_RWLock()

  func set(value: Value, forKey key: Key) {
    lock.writeLock()
    self.dict[key] = value
    lock.unlock()
  }

  func remove(_ key: Key) -> Value? {
    let result: Value?
    lock.writeLock()
    result = rem(key)
    lock.unlock()
    return result
  }

  func value(forKey key: Key) -> Value? {
    let result: Value?
    lock.readLock()
    result = dict[key]
    lock.unlock()
    return result
  }

  subscript(key: Key) -> Value? {
    set {
      lock.writeLock()
      defer {
        lock.unlock()
      }
      guard let newValue = newValue else {
        rem(key)
        return
      }

      self.dict[key] = newValue
    }

    get {
      return value(forKey: key)
    }
  }

  var keys: [Key] {
    let result: [Key]
    lock.readLock()
    result = Array(dict.keys)
    lock.unlock()
    return result
  }

  var values: [Value] {
    let result: [Value]
    lock.readLock()
    result = Array(dict.values)
    lock.unlock()
    return result
  }

  @discardableResult
  private func rem(_ key: Key) -> Value? {
    guard let index = dict.index(forKey: key) else { return nil }
    return dict.remove(at: index).value
  }
}
