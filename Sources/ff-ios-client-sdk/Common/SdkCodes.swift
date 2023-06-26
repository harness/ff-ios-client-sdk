import os

class SdkCodes {

  private static let logger = SdkLog.get("io.harness.ff.sdk.ios.SdkCodes")

  // MARK: SDK_INIT_1xxx

  static func info_sdk_init_ok() {
    logger.info("\(prefix(1000)): The SDK has successfully initialized")
  }

  static func warn_sdk_auth_error(_ reason: String) {
    logger.warn(
      "\(prefix(1001)): The SDK has failed to initialize due to the following authentication error: \(reason)"
    )
  }

  static func warn_sdk_init_ok() {
    logger.warn(
      "\(prefix(1002)): The SDK has failed to initialize due to a missing or empty API key")
  }

  static func warn_sdk_invalid_tls_cert() {
    logger.warn("\(prefix(1004)): TLS: Server presented an invalid certificate")
  }

  static func warn_sdk_invalid_tls_cert_hostname() {
    logger.warn("\(prefix(1005)): TLS: Server hostname mismatch in certificate")
  }

  static func warn_sdk_invalid_tls_cert_missing_intermediate_ca() {
    logger.warn("\(prefix(1006)): TLS: missing intermediate CA in trust store")
  }

  // MARK: SDK_AUTH_2xxx

  static func info_sdk_auth_ok() {
    logger.info("\(prefix(2000)): Authenticated ok")
  }

  static func warn_auth_failed() {
    logger.warn(
      "\(prefix(2001)): Authentication failed with a non-recoverable error - defaults will be served"
    )
  }

  static func warn_auth_failed_missing_token() {
    logger.warn(
      "\(prefix(2001)): Authentication failed with a non-recoverable error (missing token) - defaults will be served"
    )
  }

  static func error_auth_retying(_ attempt: Int) {
    logger.warn("\(prefix(2003)): Retrying to authenticate, attempt #\(attempt)")
  }

  // MARK: SDK_POLL_4xxx

  static func info_poll_started(_ durationSec: Int) {
    let durationMs = durationSec * 1000
    logger.info("\(prefix(4000)): Polling started, intervalMs: \(durationMs)")
  }

  static func info_polling_stopped() {
    logger.info("\(prefix(4001)): Polling stopped")
  }

  // MARK: SDK_STREAM_5xxx

  static func info_stream_connected() {
    logger.info("\(prefix(5000)): SSE stream connected ok")
  }

  static func warn_stream_disconnected(_ reason: String) {
    logger.warn("\(prefix(5001)): SSE stream disconnected, reason: \(reason)")
  }

  static func info_stream_event_received(_ eventJson: String) {
    logger.info("\(prefix(5002)): SSE event received: \(eventJson)")
  }

  static func info_stream_retrying(_ durationMs: Int) {
    logger.info("\(prefix(5003)): SSE retrying to connect in: \(durationMs)ms")
  }

  // MARK: SDK_METRICS_7xxx

  static func info_metrics_thread_started() {
    logger.info("\(prefix(7000)): Metrics thread started")
  }

  static func info_metrics_thread_exited() {
    logger.info("\(prefix(7001)): Metrics thread exited")
  }

  static func warn_post_metrics_failed(_ reason: String) {
    logger.warn("\(prefix(7002)): Posting metrics failed, reason: \(reason)")
  }

  // MARK: SDK_EVAL_6xxx

  static func warn_default_variation_served(
    identifier: String, target: CfTarget, defaultValue: String
  ) {
    logger.warn(
      "\(prefix(6001)): Default variation was served, identifier=\(identifier), target=\(target.identifier), default=\(defaultValue)"
    )
  }

  // MARK: private methods

  private static func prefix(_ sdkCode: Int) -> String {
    return String(format: "SDKCODE(%@:%d)", getErrClass(sdkCode), sdkCode)
  }

  private static func getErrClass(_ errorCode: Int) -> String {
    switch errorCode {
    case 1000...1999: return "init"
    case 2000...2999: return "auth"
    case 4000...4999: return "poll"
    case 5000...5999: return "stream"
    case 6000...6999: return "eval"
    case 7000...7999: return "metric"
    default: return ""
    }
  }
}
