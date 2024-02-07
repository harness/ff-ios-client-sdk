import Foundation

class AnalyticsPublisherService {
  private static let log = SdkLog.get("io.harness.ff.sdk.ios.AnalyticsPublisherService")

  private let cluster: String
  private let environmentID: String
  private let config: CfConfiguration
  private let metricsApi: MetricsAPI

  private static let CLIENT: String = "client"
  private static let SDK_TYPE: String = "SDK_TYPE"
  private static let SDK_VERSION: String = "SDK_VERSION"
  private static let SDK_LANGUAGE: String = "SDK_LANGUAGE"
  private static let TARGET_ATTRIBUTE: String = "target"
  private static let FEATURE_NAME_ATTRIBUTE: String = "featureName"
  private static let VARIATION_IDENTIFIER_ATTRIBUTE: String = "variationIdentifier"

  init(

    cluster: String,
    environmentID: String,
    config: CfConfiguration,
    metricsApi: MetricsAPI

  ) {

    self.config = config
    self.cluster = cluster
    self.environmentID = environmentID
    self.metricsApi = metricsApi
  }

  func sendDataAndResetCache(cache: inout [String: AnalyticsWrapper]) {

    if cache.isEmpty {

      AnalyticsPublisherService.log.trace("Metrics data cache size: empty")
    } else {

      AnalyticsPublisherService.log.trace("Metrics data cache size: \(cache.count)")

      let metrics = prepareSummaryMetricsBody(cache: &cache)
      if let metricsData = metrics.metricsData {

        if !metricsData.isEmpty {

          metricsApi.postMetrics(

            environmentUUID: environmentID,
            cluster: cluster,
            metrics: metrics

          ) { (response, error) in

            var success = true

            if let errResp = error as? ErrorResponse {
              switch errResp {
              case .error(let statusCode, let data, let error):
                if statusCode != 200 {
                  let dataStr = data?.description ?? ""
                  let errorStr = error?.localizedDescription ?? ""
                  SdkCodes.warn_post_metrics_failed(
                    "HTTP status=\(statusCode) data=\(dataStr) error=\(errorStr)")
                  success = false
                }
              }
            }

            if success {
              AnalyticsPublisherService.log.trace("Metrics data: sending finished")
            }
          }
        } else {

          AnalyticsPublisherService.log.trace("Metrics data: no metrics data to send")
        }

        cache.removeAll(keepingCapacity: true)
        AnalyticsPublisherService.log.debug(
          "Metrics data cache is cleaned up, size: \(cache.count)")
      }
    }
  }

  private func prepareSummaryMetricsBody(cache: inout [String: AnalyticsWrapper]) -> Metrics {

    let data = [MetricsData]()
    let metrics = Metrics(metricsData: data)
    var summaryMetricsData = [SummaryMetrics: Int]()

    for (key:_, value:value) in cache {

      let summaryMetrics = prepareSummaryMetricsKey(key: value.analytics)
      let summaryCount = summaryMetricsData[summaryMetrics]

      if summaryCount == nil {

        summaryMetricsData[summaryMetrics] = value.count
      } else {

        if let count = summaryCount {

          summaryMetricsData[summaryMetrics] = count + value.count
        }
      }
    }

    for (key:key, value:value) in summaryMetricsData {

      var attributes = [KeyValue]()

      attributes.append(

        KeyValue(

          key: AnalyticsPublisherService.FEATURE_NAME_ATTRIBUTE,
          value: key.featureName
        )
      )
      attributes.append(

        KeyValue(

          key: AnalyticsPublisherService.VARIATION_IDENTIFIER_ATTRIBUTE,
          value: key.variationIdentifier
        )
      )
      attributes.append(

        KeyValue(

          key: AnalyticsPublisherService.TARGET_ATTRIBUTE,
          value: key.targetIdentifier
        )
      )
      attributes.append(

        KeyValue(

          key: AnalyticsPublisherService.SDK_TYPE,
          value: AnalyticsPublisherService.CLIENT
        )
      )
      attributes.append(

        KeyValue(

          key: AnalyticsPublisherService.SDK_LANGUAGE,
          value: "iOS"
        )
      )
      attributes.append(

        KeyValue(

          key: AnalyticsPublisherService.SDK_VERSION,
          value: Version.version
        )
      )

      let metricsData = MetricsData(

        timestamp: currentDateTimeInMiliseconds(),
        count: value,
        metricsType: "FFMETRICS",
        attributes: attributes
      )

      metrics.metricsData?.append(metricsData)
    }

    return metrics
  }

  private func prepareSummaryMetricsKey(key: Analytics) -> SummaryMetrics {

    return SummaryMetrics(

      featureName: key.variation.name,
      variationValue: key.variation.value,
      variationIdentifier: key.variation.identifier,
      targetIdentifier: key.target.identifier
    )
  }

  private func currentDateTimeInMiliseconds() -> Int64 {

    let currentDate = Date()
    let since1970 = currentDate.timeIntervalSince1970
    return Int64(since1970 * 1000)
  }
}
