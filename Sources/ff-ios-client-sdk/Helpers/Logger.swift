
import os.log

protocol SdkLogger {
    func trace(_ msg:String)
    func debug(_ msg:String)
    func info(_ msg:String)
    func warn(_ msg:String)
    func error(_ msg:String)
}

protocol SdkLoggerFactory {
    func createSdkLogger(_ label:String) -> SdkLogger
}

internal class DefaultSdkLogger : SdkLogger {
    private let label : String
    
    init(_ label:String) {
        self.label = label
    }
    
    func trace(_ msg:String) {
        os_log("TRACE: %@ %@", type: .debug, label, msg)
    }
    
    func debug(_ msg:String) {
        os_log("DEBUG: %@ %@", type: .debug, label, msg)
    }
    
    func info(_ msg:String) {
        os_log("INFO: %@ %@", type: .info, label, msg)
    }
    
    func warn(_ msg:String) {
        os_log("WARN: %@ %@", type: .error, label, msg)
    }
    
    func error(_ msg:String) {
        os_log("ERROR: %@ %@", type: .error, label, msg)
    }

}

internal class DefaultSdkLoggerFactory : SdkLoggerFactory {
    func createSdkLogger(_ label:String) -> SdkLogger {
        return DefaultSdkLogger(label)
    }
}

internal class SdkLog {
    
    internal static var logger = DefaultSdkLoggerFactory()
    
    static internal func get(_ label:String) -> SdkLogger {
        return logger.createSdkLogger(label)
    }
}


