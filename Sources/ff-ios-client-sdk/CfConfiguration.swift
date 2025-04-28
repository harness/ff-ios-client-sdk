import Foundation

/// `CfConfiguration` is `required` in order to [intialize](x-source-tag://initialize) the SDK.
/// # Defaults: #
/// - `configUrl`:  "https://config.ff.harness.io/api/1.0"
/// - `streamUrl`:  "https://config.ff.harness.io/api/1.0/stream"
/// - `eventUrl`:  "https://events.ff.harness.io/api/1.0"
/// - `streamEnabled`: `false`
/// - `analyticsEnabled`: `true`
/// - `pollingInterval`: `60` seconds
public struct CfConfiguration {

  static var MIN_ANALYTICS_FREQUENCY: Int = 60

  var configUrl: String
  var streamUrl: String
  var eventUrl: String
  var streamEnabled: Bool
  var analyticsEnabled: Bool
  var pollingInterval: TimeInterval
  var environmentId: String
  var analyticsFrequency: Int
  var tlsTrustedCAs: [String]
  var loggerFactory: SdkLoggerFactory?
  var debug: Bool
  var failFastOnInit: Bool

  internal init(

    configUrl: String,
    streamUrl: String,
    eventUrl: String,
    streamEnabled: Bool,
    analyticsEnabled: Bool,
    pollingInterval: TimeInterval,
    environmentId: String,
    tlsTrustedCAs: [String],
    loggerFactory: SdkLoggerFactory?,
    debug: Bool,
    failFastOnInit: Bool = false
  ) {

    self.configUrl = configUrl
    self.streamUrl = streamUrl
    self.eventUrl = eventUrl
    self.streamEnabled = streamEnabled
    self.analyticsEnabled = analyticsEnabled
    self.pollingInterval = pollingInterval
    self.environmentId = environmentId
    self.analyticsFrequency = CfConfiguration.MIN_ANALYTICS_FREQUENCY
    self.tlsTrustedCAs = tlsTrustedCAs
    self.loggerFactory = loggerFactory
    self.debug = debug
    self.failFastOnInit = failFastOnInit
  }

  public static func builder() -> CfConfigurationBuilder {

    return CfConfigurationBuilder()
  }
}
