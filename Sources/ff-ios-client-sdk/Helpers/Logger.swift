import os.log

public protocol SdkLogger {
  func trace(_ msg: String)
  func debug(_ msg: String)
  func info(_ msg: String)
  func warn(_ msg: String)
  func error(_ msg: String)
}

public protocol SdkLoggerFactory {
  func createSdkLogger(_ label: String) -> SdkLogger
}

internal enum SdkLogLevel: Int {
  case Trace = 1
  case Debug = 2
  case Info = 3
  case Warn = 4
  case Error = 5
}

internal class DefaultSdkLogger: SdkLogger {
  private let label: String
  private static var logLevel: SdkLogLevel = SdkLogLevel.Info

  init(_ label: String) {
    self.label = label
  }

  static func setLogLevel(_ logLevel: SdkLogLevel) {
    DefaultSdkLogger.logLevel = logLevel
  }

  func trace(_ msg: String) {
    if SdkLogLevel.Trace.rawValue >= DefaultSdkLogger.logLevel.rawValue {
      os_log("TRACE: %@ %@", type: .debug, label, msg)
    }
  }

  func debug(_ msg: String) {
    if SdkLogLevel.Debug.rawValue >= DefaultSdkLogger.logLevel.rawValue {
      os_log("DEBUG: %@ %@", type: .debug, label, msg)
    }
  }

  func info(_ msg: String) {
    if SdkLogLevel.Info.rawValue >= DefaultSdkLogger.logLevel.rawValue {
      os_log("INFO: %@ %@", type: .info, label, msg)
    }
  }

  func warn(_ msg: String) {
    if SdkLogLevel.Warn.rawValue >= DefaultSdkLogger.logLevel.rawValue {
      os_log("WARN: %@ %@", type: .error, label, msg)
    }
  }

  func error(_ msg: String) {
    if SdkLogLevel.Error.rawValue >= DefaultSdkLogger.logLevel.rawValue {
      os_log("ERROR: %@ %@", type: .error, label, msg)
    }
  }
}

internal class DefaultSdkLoggerFactory: SdkLoggerFactory {
  func createSdkLogger(_ label: String) -> SdkLogger {
    return DefaultSdkLogger(label)
  }
}

internal class SdkLog {

  internal static var loggerFactory: SdkLoggerFactory = DefaultSdkLoggerFactory()

  static internal func get(_ label: String) -> SdkLogger {
    return loggerFactory.createSdkLogger(label)
  }

  static internal func setLoggerFactory(_ factory: SdkLoggerFactory) {
    SdkLog.loggerFactory = factory
  }
}
