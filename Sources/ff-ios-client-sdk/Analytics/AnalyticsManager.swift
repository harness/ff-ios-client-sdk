import Foundation

class AnalyticsManager : Destroyable {
    
    private let environmentID: String
    private let cluster: String
    private let authToken: String
    private let config: CfConfiguration
    
    private var ready: Bool
    private var timer: Timer?
    private var cache: [String:AnalyticsWrapper]
    
    init (
    
        environmentID: String,
        cluster: String,
        authToken: String,
        config: CfConfiguration,
        cache: inout [String:AnalyticsWrapper]
        
    ) {
        
        self.environmentID = environmentID
        self.cluster = cluster
        self.authToken = authToken
        self.config = config
        self.cache = cache
        self.ready = true
    }
    
    @objc func send() {
        
        Logger.log("Sending metrics")
        
        let analyticsPublisherService = AnalyticsPublisherService(
        
            cluster: self.cluster,
            environmentID: self.environmentID,
            config: self.config,
            cache: &self.cache
        )
        
        analyticsPublisherService.sendDataAndResetCache()
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
        
        let analyticsKey = getAnalyticsCacheKey(target: target, featureConfig: featureConfig)
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
            
            Logger.log("Metrics data appended [1], \(featureConfig.feature) has count of: 1")
        } else {
            
            wrapper?.count += 1
            if let w = wrapper {
                
                Logger.log("Metrics data appended [2], \(featureConfig.feature) has count of: \(w.count)")
            } else {
                
                Logger.log("Metrics data appended [3], \(featureConfig.feature) has count of: ERROR")
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
    
    private func getAnalyticsCacheKey(
    
        target: CfTarget,
        featureConfig: FeatureConfig
    ) -> String {
        
        let key = "\(target.identifier)_\(featureConfig.project)_\(featureConfig.environment)_\(featureConfig.feature)"
        Logger.log("Analytics cache key: \(key)")
        return key
    }
}
