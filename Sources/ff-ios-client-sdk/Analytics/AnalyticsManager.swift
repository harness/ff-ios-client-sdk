import Foundation

class AnalyticsManager : Destroyable {
    
    private let environmentID: String
    private let cluster: String
    private let authToken: String
    private let config: CfConfiguration
    
    private var ready: Bool
    private var timer: Timer?
    private var cache: [String:AnalyticsWrapper]
    private var analyticsPublisherService: AnalyticsPublisherService?
    
    init (
    
        environmentID: String,
        cluster: String,
        authToken: String,
        config: CfConfiguration
        
    ) {
        
        self.environmentID = environmentID
        self.cluster = cluster
        self.authToken = authToken
        self.config = config
        self.cache = [String:AnalyticsWrapper]()
        
        analyticsPublisherService = AnalyticsPublisherService(
        
            cluster: cluster,
            environmentID: environmentID,
            config: config,
            cache: cache
        )
        
        ready = true
    }
    
    @objc func send() {
        
        Logger.log("Sending metrics")
        analyticsPublisherService?.sendDataAndResetCache()
    }
    
    func push(
    
        target: CfTarget,
        featureConfig: FeatureConfig,
        variation: Variation
    
    ) {
        
        if (!ready) {
            return
        }
        
        Logger.log("Metrics data appending")
        
        let analyticsKey = getAnalyticsKey(target: target, featureConfig: featureConfig)
        var wrapper = cache[analyticsKey]
        
        if wrapper == nil {
            
            let analytics = Analytics(
            
                target: target,
                variation: variation,
                eventType: "METRICS",
                featureConfig: featureConfig
            )
            
            wrapper = AnalyticsWrapper(analytics: analytics, count: 1)
            cache[analyticsKey] = wrapper
            
            Logger.log("Metrics data appended, \(featureConfig.feature) has count of: 1")
        } else {
            
            if let w = wrapper {
                
                let count = w.count
                wrapper?.count = w.count + 1
                Logger.log("Metrics data appended, \(featureConfig.feature) has count of: \(count)")
            }
        }
        
        Logger.log("Metrics data total count: \(cache.count)")
        
        if (self.timer == nil) {
            
            Logger.log("Scheduling metrics timer")
            
            self.timer = Timer.scheduledTimer(
                
                timeInterval: TimeInterval(config.analyticsFrequency),
                target: self,
                selector: #selector(send),
                userInfo: nil,
                repeats: true
            )
        } else {
            
            Logger.log("Scheduling metrics timer SKIPPED")
        }
    }
    
    func destroy() {
        
        ready = false
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private func getAnalyticsKey(
    
        target: CfTarget,
        featureConfig: FeatureConfig
    ) -> String {
        
        return "\(target.identifier)_\(featureConfig.project)_\(featureConfig.environment)_\(featureConfig.feature)"
    }
}
