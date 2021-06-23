import Foundation

class AnalyticsManager : Destroyable {
    
    private let environmentID: String
    private let cluster: String
    private let authToken: String
    private let config: CfConfiguration
    
    private var ready: Bool
    private var timer: Timer?
    private var cache: [Analytics:Int]
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
        self.cache = [Analytics:Int]()
        
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
        
        Logger.log("Pushing metrics")
        
        let analytics = Analytics(
        
            target: target,
            variation: variation,
            eventType: "METRICS",
            featureConfig: featureConfig
        )
        
        let count = cache[analytics]
        if count == nil {
            
            cache[analytics] = 1
        } else {
            
            if let c = count {
                
                cache[analytics] = c + 1
            }
        }
        
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
}
