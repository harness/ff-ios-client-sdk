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
            config: self.config
        )
        
        analyticsPublisherService.sendDataAndResetCache(cache: &self.cache)
    }
    
    func push(
    
        target: CfTarget,
        variation: Variation
    
    ) {
        
        if (!ready) {
            return
        }
        
        Logger.log("Metrics data appending")
        
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
            
            Logger.log("Metrics data appended [1], \(variation.name) has count of: 1")
        } else {
            
            wrapper?.count += 1
            if let w = wrapper {
                
                Logger.log("Metrics data appended [2], \(variation.name) has count of: \(w.count)")
            } else {
                
                Logger.log("Metrics data appended [3], \(variation.name) has count of: ERROR")
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
        identifier: String
        
    ) -> String {
        
        let key = "\(target.identifier)_\(identifier)"
        Logger.log("Analytics cache key: \(key)")
        return key
    }
}
