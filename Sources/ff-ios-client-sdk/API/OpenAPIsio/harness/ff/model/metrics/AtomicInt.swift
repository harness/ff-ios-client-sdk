//
//  AtomicInt.swift
//
//
//  Created by Andrew Bell on 08/02/2024.
//

import Foundation

class AtomicInt {
  private var value: Int
  private let lock = PThread_RWLock()

  init(_ initialValue: Int) {
    lock.writeLock()
    self.value = initialValue
    lock.unlock()
  }

  func increment() {
    lock.writeLock()
    self.value += 1
    lock.unlock()
  }

  func get() -> Int {
    var result = 0
    lock.readLock()
    result = self.value
    lock.unlock()
    return result
  }

}
