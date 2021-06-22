import Foundation

class AnalyticsPublisherService {
    
    private let cluster: String
    private let environmentID: String
    private let config: CfConfiguration
    private let cache: [Analytics:Int]
    
    private static let CLIENT: String = "client"
    private static let SDK_TYPE: String = "SDK_TYPE"
    private static let SDK_VERSION: String = "SDK_VERSION"
    private static let SDK_LANGUAGE: String = "SDK_LANGUAGE"
    private static let GLOBAL_TARGET: String = "__global__cf_target"
    private static let TARGET_ATTRIBUTE: String = "target"
    private static let FEATURE_NAME_ATTRIBUTE: String = "featureName"
    private static let VARIATION_IDENTIFIER_ATTRIBUTE: String = "variationIdentifier"
    
    init(
    
        cluster: String,
        environmentID: String,
        config: CfConfiguration,
        cache: [Analytics:Int]
    
    ) {
        
        self.cluster = cluster
        self.environmentID = environmentID
        self.config = config
        self.cache = cache
    }
    
    func sendDataAndResetCache() {
    
        Logger.log("Reading from queue and building cache")
        if (!cache.isEmpty) {
            
            let metrics = prepareSummaryMetricsBody()
            if let metricsData = metrics.metricsData {
                
                if (!metricsData.isEmpty) {
                    
                    
                }
                
                Logger.log("Successfully sent analytics data to the server")
                cache.removeAll()
            }
        }
    }
    
    private func prepareSummaryMetricsBody() -> Metrics {
        
        let metrics = Metrics()
        
        
        return metrics
    }
}
