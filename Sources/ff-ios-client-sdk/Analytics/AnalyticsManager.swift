import Foundation
import SwiftConcurrentCollections

class AnalyticsManager: Destroyable {

  private static let log = SdkLog.get("io.harness.ff.sdk.ios.AnalyticsManager")

  private let environmentID: String
  private let cluster: String
  private let authToken: String
  private let config: CfConfiguration
  private let metricsApi: MetricsAPI
  private let analyticsPublisherService: AnalyticsPublisherService

  private var ready: Bool
  private var timer: Timer?
  private var cache: ConcurrentDictionary<String, AnalyticsWrapper>

  init(
    environmentID: String,
    cluster: String,
    authToken: String,
    config: CfConfiguration,
    cache: inout ConcurrentDictionary<String, AnalyticsWrapper>,
    metricsApi: MetricsAPI = MetricsAPI()
  ) {

    self.environmentID = environmentID
    self.cluster = cluster
    self.authToken = authToken
    self.config = config
    self.metricsApi = metricsApi
    self.cache = cache
    self.ready = true

    self.analyticsPublisherService = AnalyticsPublisherService(
      cluster: self.cluster,
      environmentID: self.environmentID,
      config: self.config,
      metricsApi: self.metricsApi
    )

    self.timer = Timer.scheduledTimer( withTimeInterval: TimeInterval(config.analyticsFrequency), repeats: true) { timer in
      AnalyticsManager.send(self.analyticsPublisherService, self.cache);
    }

    AnalyticsManager.log.debug("Scheduled metrics timer")
    SdkCodes.info_metrics_thread_started()
  }

  class func send(_ service: AnalyticsPublisherService, _ cache: ConcurrentDictionary<String, AnalyticsWrapper>) {
    // Create a working snapshot of the cache so it doesn't get modified underneath us
    var cacheSnapshot = [String: AnalyticsWrapper]()
    for key in cache.keys {
      if let v = cache.remove(key) {
        cacheSnapshot[key] = v
      }
    }
    AnalyticsManager.log.info("Sending metrics")
    service.sendDataAndResetCache(cache: cacheSnapshot)
  }

  func push(

    target: CfTarget,
    variation: Variation

  ) {

    if !ready {
      return
    }

    AnalyticsManager.log.trace("Metrics data appending")

    let analyticsKey = getAnalyticsCacheKey(target: target, identifier: variation.name)
    var wrapper = cache[analyticsKey]

    if wrapper == nil {

      let analytics = Analytics(

        target: target,
        variation: variation,
        eventType: "METRICS"
      )

      wrapper = AnalyticsWrapper(analytics: analytics, count: 1)
      cache[analyticsKey] = wrapper

      AnalyticsManager.log.trace("Metrics data appended [1], \(variation.name) has count of: 1")
    } else {

      wrapper?.increment()
      if let w = wrapper {

        AnalyticsManager.log.trace(
          "Metrics data appended [2], \(variation.name) has count of: \(w.count())")
      } else {

        AnalyticsManager.log.trace(
          "Metrics data appended [3], \(variation.name) has count of: ERROR")
      }
    }
  }

  func destroy() {

    SdkCodes.info_metrics_thread_exited()

    ready = false
    self.timer?.invalidate()
  }

  private func getAnalyticsCacheKey(

    target: CfTarget,
    identifier: String

  ) -> String {

    let key = "\(target.identifier)_\(identifier)"
    AnalyticsManager.log.trace("Analytics cache key: \(key)")
    return key
  }
}
