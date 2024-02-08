//
//  AnalyticsManagerTest.swift
//
//
//  Created by Andrew Bell on 07/02/2024.
//

import Foundation

import XCTest
import SwiftConcurrentCollections

@testable import ff_ios_client_sdk

class EvalThread : Thread {
  let latch = DispatchGroup()
  let analyticsManager: AnalyticsManager
  let target = CfTarget.builder().setIdentifier("Dummy").build()

  init(_ analyticsManager: AnalyticsManager) {
    self.analyticsManager = analyticsManager
  }

  override func start() {
    print("start thread: ", self.debugDescription)
    latch.enter()
    super.start()
  }

  override func main() {
    print("run thread:", self.debugDescription)

    let variation = Variation(identifier: "id", value: "val", name: "name")

    for _ in 1...100 {
      analyticsManager.push(target: target, variation: variation)
    }

    latch.leave()
  }

  func join() {
    latch.wait()
    print("joined thread released:", self.debugDescription)
  }
}

class DummyMetricsApi : MetricsAPI {
  override func postMetrics(environmentUUID: String, cluster: String, metrics: Metrics, apiResponseQueue: DispatchQueue = OpenAPIClientAPI.apiResponseQueue, completion: @escaping ((EmptyResponse?, Error?) -> Void)) {
    print("postMetrics called")
  }
}

/*
 * This test uses several threads to concurrently update the metrics map to force out any critical regions that aren't protected.
 * In particular the metrics dictionary.
 */
final class AnalyticsManagerTest: XCTestCase {
  func testConcurrentMetricsMapModifications() throws {

    let config = CfConfiguration.builder().build()
    var cache = ConcurrentDictionary<String, AnalyticsWrapper>()
    let analyticsManager = AnalyticsManager(
      environmentID: "dummy",
      cluster: "dummy",
      authToken: "dummy",
      config: config,
      cache: &cache,
      metricsApi: DummyMetricsApi()
    )

    var threads: Array<EvalThread> = Array()

    for _ in 1...20 {
      threads.append(EvalThread(analyticsManager))

    }

    for thread in threads {
      thread.start()
    }

    for thread in threads {
      thread.join()
    }

  }
}
