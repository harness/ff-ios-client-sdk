import Foundation

class AnalyticsManager: Destroyable {

  private static let log = SdkLog.get("io.harness.ff.sdk.ios.AnalyticsManager")

  private let environmentID: String
  private let cluster: String
  private let authToken: String
  private let config: CfConfiguration
  private let metricsApi: MetricsAPI

  private var ready: Bool
  private var timer: Timer?
  private var cache: [String: AnalyticsWrapper]

  init(

    environmentID: String,
    cluster: String,
    authToken: String,
    config: CfConfiguration,
    cache: inout [String: AnalyticsWrapper],
    metricsApi: MetricsAPI = MetricsAPI()

  ) {

    self.environmentID = environmentID
    self.cluster = cluster
    self.authToken = authToken
    self.config = config
    self.metricsApi = metricsApi
    self.cache = cache
    self.ready = true

    SdkCodes.info_metrics_thread_started()
  }

  @objc func send() {

    AnalyticsManager.log.info("Sending metrics")

    let analyticsPublisherService = AnalyticsPublisherService(

      cluster: self.cluster,
      environmentID: self.environmentID,
      config: self.config,
      metricsApi: self.metricsApi
    )

    analyticsPublisherService.sendDataAndResetCache(cache: &self.cache)
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

      wrapper?.count += 1
      if let w = wrapper {

        AnalyticsManager.log.trace(
          "Metrics data appended [2], \(variation.name) has count of: \(w.count)")
      } else {

        AnalyticsManager.log.trace(
          "Metrics data appended [3], \(variation.name) has count of: ERROR")
      }
    }

    if self.timer == nil {

      AnalyticsManager.log.debug("Scheduling metrics timer")

      self.timer = Timer.scheduledTimer(

        timeInterval: TimeInterval(config.analyticsFrequency),
        target: self,
        selector: #selector(send),
        userInfo: nil,
        repeats: true
      )
    } else {

      AnalyticsManager.log.trace("Scheduling metrics timer SKIPPED")
    }
  }

  func destroy() {

    SdkCodes.info_metrics_thread_exited()

    ready = false
    self.timer?.invalidate()
    self.timer = nil
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
